@{
    Description   = 'Azure-LinuxVM'
    ResourceGroup = 'RG-Test-Ubn-01'
    Location      = 'ukwest'    
    
    Vnet = @{
        VNetName = 'Vnet-Test-Env'
        VNetAddr = '10.7.0.0/16'
        SubnetName = 'LAN-Subnet'
        SubnetAddr = '10.7.0.0/24'        
        VNicName = 'Vnic-Test-Ubn-01'
        AllocationMethod = 'Dynamic'
    }
    
    VM = @{
        VMName = 'VM-Test-Ubn-01'
        VMSize = 'Basic_A1'
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='
	OSType = 'Linux'        
        Offer = 'UbuntuServer'
        Skus  = '18.04-LTS'
        Version = 'Latest'
        VhdName = 'OSD-Ubn-Pxy.vhd'
	PublisherName = 'Canonical'
    }      
}