Param(
    $ConfigFile = ".\SqlServerVM-Config.psd1"
)
Describe "New Test Environment"{    
    $DefaultEAP = $ErrorActionPreference
    $Config = Import-PowerShellDataFile -Path $ConfigFile 
    
    BeforeAll{        
        $ErrorActionPreference = 'SilentlyContinue'
    }
    AfterAll{
        $ErrorActionPreference = $DefaultEAP
    }       
    
    Context "Resource Group"{
        $RG = Get-AzResourceGroup -Name $($Config.ResourceGroup) -Location $($Config.Location)
        It "Resource Group Name: $($Config.ResourceGroup)"{
            $RG.ResourceGroupName | Should Not Be $null
        }
        It "Location: $($Config.Location)"{
            $RG.Location | Should Be $($Config.Location)
        }
    }
    Context "Virtual Network"{
        $VNet = Get-AzVirtualNetwork -Name $($Config.Vnet.VNetName) -ResourceGroupName "$($Config.ResourceGroup)"
        $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $($Config.Vnet.SubNetName) -VirtualNetwork $VNet
        $VNic = Get-AzNetworkInterface -Name $($Config.Vnet.VNicName) -ResourceGroupName $($Config.ResourceGroup)
        
        It "VNet Name: $($Config.Vnet.VNetName)"{
            $VNet.Name | Should Be $($Config.Vnet.VNetName)
        }
        It "VNet Address space: $($Config.Vnet.VNetAddr)"{
            $VNet.AddressSpace.AddressPrefixes | Should match $($Config.Vnet.VNetAddr)
        }
        It "Vnet Subnet Name: $($Config.Vnet.SubNetName)"{
            $Subnet.Name | Should Not Be $null
        }
        It "VNet Subnet Address: $($Config.Vnet.SubNetAddr)"{
            $Subnet.addressprefix | Should match $($Config.Vnet.SubNetAddr)
        }
        It "Virtual NIC Name: $($Config.Vnet.VNicName)"{
            $VNic.Name | Should match $($Config.Vnet.VNicName)
        }        
    }
    Context "Virtual Machine"{
        $VM = Get-AzVM -Name $($Config.VM.VMName) -ResourceGroupName $($Config.ResourceGroup)
        
        It "VM Name: $($Config.VM.VMName)"{
            $VM.Name | Should Be $($Config.VM.VMName)
        }
        It "VM Size: $($Config.VM.VMSize)"{
            $VM.HardwareProfile.VmSize | Should match $($Config.VM.VMSize)
        }
        It "VM Admin: $($Config.VM.VMUser)"{
            $VM.OSProfile.AdminUsername | Should Be $($Config.VM.VMUser)
        }
        It "VM OS Type: $($Config.VM.OSType)"{
            $VM.StorageProfile.OsDisk.OsType | Should Be $($Config.VM.OSType)
        }
        It "VM NIC attached: $($Config.Vnet.VNicName)"{
            ($VM.NetworkProfile.NetworkInterfaces.ID).EndsWith($($Config.Vnet.VNicName)) | Should Be $true
        }
        It "VM Extension: "{
            Set-ItResult -Inconclusive -Because "Not implemented yet"
        }
    }

}

#Invoke-Pester -Script @{Path = '.\Az-Infrastructure.Tests.ps1'; Parameters = @{ConfigFile = '.\SqlServerVM-Config.psd1'}}