<#
.Synopsis
   Deploy VMs using Managed Disk on the Azure IaaS platform
.DESCRIPTION
   This script deploys VM on the Azure environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
.Example
   Deploy-AzManagedDiskVM.ps1 -ConfigFile ".\WindowsVM-Config.psd1"
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

Function Base64{
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

Function New-PSVirtualMachine{
    [OutputType([PSVirtualMachine])]
    Param(
        [Parameter(Mandatory)]           
        [String]$VMName,
        [String]$VMSize,        
        [Parameter(Mandatory)]
        [PSCredential]$VMCred,
        [ValidateSet("Windows", "Linux")]
        [String]$OSType = 'Windows',
        [Parameter(Mandatory)]       
        [String]$VMNicId,        
        [Parameter(Mandatory)]
        [String]$VhdName,        
        [Parameter(Mandatory)]
        [String]$PublisherName,
        [String]$Offer,
        [String]$Skus,
        [String]$Version        
    )

    $VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VMConfig = If ($OSType -eq 'Windows') { 
                    Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMName -Credential $VMCred
                }
                Else { 
                    Set-AzVMOperatingSystem -VM $VMConfig -Linux -ComputerName $VMName -Credential $VMCred
                }
    $VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $Skus -Version $Version
    $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $VMNicId
    $VMConfig = Set-AzVMOSDisk -VM $VMConfig -Name $VhdName -CreateOption 'FromImage'
    $VMConfig = Set-AzVMBootDiagnostics -Disable

    return $VMConfig
}

#region VM Deployment

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

Write-Verbose "[*] Generating new credential for VM..."
$VMCred  = New-VMCredential -UserName $Config.VM.VMUser -Password (Base64 -Text "$($Config.VM.VMPass)")

Write-Verbose "[*] Checking the Virtual Network Interface..."
If(-Not(Test-VirtualNIC -Name $Config.Vnet.VNicName)){
    Write-Verbose " - Creating Virtual NIC: $($Config.Vnet.VNicName)"
    $PublicIP = New-AzPublicIpAddress -Name $Config.Vnet.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -AllocationMethod $Config.Vent.AllocationMethod
    $VNic = New-AzNetworkInterface -Name $Config.Vnet.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PublicIP.Id
    Write-Verbose " - Public IP Address: $($PublicIP.IPAddress)"
}

Write-Verbose "[*] Checking the Virtual Machine..."
If (-Not(Test-VirtualMachine -ResourceGroup $Config.ResourceGroup -Name $Config.VM.VMName)){
    $PSVM = @{
        VMName  = $($Config.VM.VMName)
        VMSize  = $($Config.VM.VMSize)
        VMCred  = $VMCred
        OSType  = $($Config.VM.OSType)
        VMNicId = $($VNic.Id)
        VhdName = $($Config.VM.VhdName)
        PublisherName = $($Config.VM.PublisherName)
        Offer   = $($Config.VM.Offer)
        Skus    = $($Config.VM.Skus)
        Version = $($Config.VM.Version)
    }
    Write-Verbose "[*]Creating the VM Configuration..."
    $VMConfig = New-PSVirtualMachine @PSVM 
    Write-Verbose "[*]Deploying the Virtual Machine..."
    New-AzVM -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -VM $VMConfig -WhatIf
}

#endregion VM Deployment