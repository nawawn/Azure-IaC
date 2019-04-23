<#
.Synopsis
   Deploy VMs on the Azure IaaS platform
.DESCRIPTION
   This script deploys VM on the Azure environment using the config file as a parameter. 
   Written by Naw Awn, Proof of Concept for Infrastructure as Code using PowerShell.
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

If((Test-Path $ConfigFile -PathType Leaf) -and (Test-PSDataFile $ConfigFile)){
    $Config = Import-PowerShellDataFile -Path $ConfigFile
}
Else {
    Write-Warning "$ConfigFile : File not found or incorrect format"
    return
}

If (-Not(Test-ResourceGroup -ResourceGroup $Config.ResourceGroup)){
    New-AzResourceGroup -Name $Config.ResourceGroup -Location $Config.Location
}

If(-Not(Test-StorageAccount -ResourceGroup $Config.ResourceGroup -Name $Config.StorageAccount)){
    New-AzStorageAccount -Name $Config.StorageAccount -Type $Config.Type -ResourceGroupName $Config.ResourceGroup -Location $Config.Location
}

If(-Not(Test-VirtualNetwork -ResourceGroup $Config.ResourceGroup -Name $Config.Vnet.VNetName)){
    $VnetAddr = $Config.Vnet.VNetAddr
    $SubnetName = $Config.Vnet.SubNetName
    $SubnetAddr = $Config.Vnet.SubNetAddr
    $Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddr
    $Vnet = New-AzVirtualNetwork -Name $Config.Vnet.VNetName -ResourceGroupName $Config.ResourceGroup -Location $Config.Locaion -AddressPrefix $VnetAddr -Subnet $Subnet
}

#With Public IP
If(-Not(Test-VirtualNIC -Name $Config.Vnet.VNicName)){
    $PublicIP = New-AzPublicIpAddress -Name $Config.Vnet.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -AllocationMethod $Config.Vent.AllocationMethod
    $VNic = New-AzNetworkInterface -Name $Config.Vnet.VNicName -ResourceGroupName $Config.ResourceGroup -Location $Config.Location -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PublicIP.Id
}

#Virtual Machine
If (-Not(Test-VirtualMachine -ResourceGroup $Config.ResourceGroup -Name $Config.VM.VMName)){
    Write-Verbose "Provisioning VM Config..."
    <# Work in Progress
    $VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VMCred   = (Get-Credential -Message "VM Admin Credentials")
    $VMConfig = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMName -Credential $VMCred -ProvisionVMAgent -EnableAutoUpdate
    $VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $Skus -Version $Version
    $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $VNic.Id

    $VhdName = 'OSD-IIS-Pri.vhd'
    $StorageAcc = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorAccName

    #CreateOption = FromImage | Attach | Empty
    $OsDiskUri = $StorageAcc.PrimaryEndpoints.Blob.ToString() + "VHDs/" + $VhdName
    $VmConfig = Set-AzVMOSDisk -VM $VMConfig -Name $VhdName -VhdUri $OsDiskUri -CreateOption FromImage

    Write-Verbose "Deploying the VM..."
    New-AzVM -ResourceGroupName $ResourceGroup -Location $Locaion -VM $VmConfig
    #>
}
