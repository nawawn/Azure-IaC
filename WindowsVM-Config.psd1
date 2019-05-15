@{
    Description   = 'Azure-WindowsVM'
    ResourceGroup = 'RG-Test-IIS-01'
    Location      = 'ukwest'    
           
    Vnet = @{
        VNetName   = 'Vnet-Test-Env'
        VNetAddr   = '10.7.0.0/16'
        SubNetName = 'LAN-Subnet'
        SubNetAddr = '10.7.0.0/24'        
        VNicName = 'Vnic-Test-IIS-01'
        AllocationMethod = 'Dynamic'
    }
    
    VM = @{
        VMName = 'VM-Test-IIS-01'
        VMSize = 'Basic_A1'
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='
        OSType = 'Windows'        
        Offer   = 'WindowsServer'
        Skus    = '2016-Datacenter'
        Version = 'Latest'
        VhdName = 'OSD-Test-IIS-01.vhd'
	PublisherName = 'MicrosoftWindowsServer'
    }      
}