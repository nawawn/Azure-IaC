<#
.Synopsis
   Deploy VMs on the Azure IaaS platform
.DESCRIPTION
   This script deploys VM on the Azure environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   Deploy-AzureVM.ps1 -ConfigFile ".\WindowsVM-Config.psd1"
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    $ConfigFile	
)
#requires -Modules Az

Function Test-AzPSSession{
    return($null -ne (Get-AzContext))
}

Function Test-PSDataFile{
    [CmdletBinding()]
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$FilePath
    )
    process{         
        return ([IO.Path]::GetExtension($FilePath) -eq ".psd1")
    }
}

Function Test-ResourceGroup{
    [CmdletBinding()]    
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$ResourceGroup
    )
    process{         
        return ($null -ne (Get-AzResourceGroup -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue))
    }
}

Function Test-StorageAccount{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroup,    
        [Parameter(Mandatory)][String]$Name
        
    )
    process{         
        return ($null -ne (Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue))
    }
}

Function Test-VirtualNetwork{
    [OutputType([Bool])]
    Param(        
        [Parameter(Mandatory)][String]$ResourceGroup,
        [Parameter(Mandatory)][String]$Name
    )
    process{         
        return ($null -ne (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue))
    }
}

Function Test-VirtualNIC{
    [CmdletBinding()]    
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$Name
    )
    process{         
        return ($null -ne (Get-AzNetworkInterface -Name $Name -ErrorAction SilentlyContinue))
    }
}
Function Test-VirtualMachine{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroup,
        [Parameter(Mandatory)][String]$Name        
    )
    process{         
        return ($null -ne (Get-AzVM -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue))
    }
}

function Base64{
    Param([String]$Text)      
    return ([system.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Text)))   
}

Function New-VMCredential{
    [OutputType([PSCredential])]
    Param(
        [Parameter(Mandatory)][string]$UserName,
        [Parameter(Mandatory)][string]$Base64            
    )    
    Return (New-Object -TypeName System.Management.Automation.PSCredential($UserName,(Base64 $Base64 | ConvertTo-SecureString -AsPlainText -Force)))
}

#region Deployment
Write-Verbose "[*] Checking Azure PowerShell Session..."
If(-Not(Test-AzPSSession)){
    Connect-AzAccount    
}

Write-Verbose "[*] Checking Config File..."
If((Test-Path $ConfigFile -PathType Leaf) -and (Test-PSDataFile $ConfigFile)){
    $Config = Import-PowerShellDataFile -Path $ConfigFile
}
Else {
    Write-Warning "$ConfigFile : File not found or incorrect format"
    return
}

Write-Verbose "[*] Checking the Resource Group..."
If (-Not(Test-ResourceGroup -ResourceGroup $Config.ResourceGroup)){
    Write-Verbose " - Creating Resource Group: $($Config.ResourceGroup)"
    New-AzResourceGroup -Name $Config.ResourceGroup -Location $Config.Location
}

Write-Verbose "[*] Checking the Storage Account..."
If(-Not(Test-StorageAccount -ResourceGroup $Config.ResourceGroup -Name $Config.StorageAccount)){
    Write-Verbose " - Creating Storage Account: $($Config.StorageAccount)"
    New-AzStorageAccount -Name $Config.StorageAccount -Type $Config.Type -ResourceGroupName $Config.ResourceGroup -Location $Config.Location
}

Write-Verbose "[*] Checking the Virtual Network..."
If(-Not(Test-VirtualNetwork -ResourceGroup $Config.ResourceGroup -Name $Config.Vnet.VNetName)){
    Write-Verbose " - Creating Virtual Network: $($Config.Vnet.VNetName)"
    $VnetAddr = $Config.Vnet.VNetAddr
    $SubnetName = $Config.Vnet.SubnetName
    $SubnetAddr = $Config.Vnet.SubnetAddr
    $Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddr
    $Vnet = New-AzVirtualNetwork -Name $Config.Vnet.VNetName -ResourceGroupName $Config.ResourceGroup -Location $Config.Locaion -AddressPrefix $VnetAddr -Subnet $Subnet
}

Write-Verbose "[*] Checking the Virtual Network Interface..."
If(-Not(Test-VirtualNIC -Name $Config.Vnet.VNicName)){
    Write-Verbose " - Creating Virtual NIC: $($Config.Vnet.VNicName)"
    $PublicIP = New-AzPublicIpAddress -Name $Config.Vnet.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -AllocationMethod $Config.Vent.AllocationMethod
    $VNic = New-AzNetworkInterface -Name $Config.Vnet.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PublicIP.Id
    Write-Verbose " - Public IP Address: $($PublicIP.IPAddress)"
}

Write-Verbose "[*] Checking the Virtual Machine..."
If (-Not(Test-VirtualMachine -ResourceGroup $Config.ResourceGroup -Name $Config.VM.VMName)){
    Write-Verbose " - Provisioning the Virtual Machine Configuration..."    
    $VMCred  = New-VMCredential -UserName $Config.VM.VMUser -Password $Config.VM.VMPass

    $VMConfig = New-AzVMConfig -VMName $Config.VM.VMName -VMSize $Config.VM.VMSize    
    $VMConfig = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $Config.VM.VMName -Credential $VMCred -ProvisionVMAgent -EnableAutoUpdate
    $VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName $Config.VM.PublisherName -Offer $Config.VM.Offer -Skus $Config.VM.Skus -Version $Config.VM.Version
    $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $VNic.Id

    $VhdName = $Config.VM.VhdName
    $StorageAcc = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorAccName

    #CreateOption = FromImage | Attach | Empty
    $OsDiskUri = $StorageAcc.PrimaryEndpoints.Blob.ToString() + "VHDs/" + $VhdName
    $VMConfig = Set-AzVMOSDisk -VM $VMConfig -Name $VhdName -VhdUri $OsDiskUri -CreateOption FromImage

    Write-Verbose "[*]Deploying the Virtual Machine..."
    New-AzVM -ResourceGroupName $Config.ResourceGroup -Location $Config.Locaion -VM $VmConfig    
}
#endregion Deployment