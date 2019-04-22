@{
    Description   = 'Azure-LinuxVM'

    ResourceGroup  = 'RG-IIS-Pri'
    Location       = 'uksouth'    
    StorageAccount = 'storprod'
    Type           = 'Standard_LRS'
    
    Vnet = @{
        VNetName = 'Vnet-IIS-Pri'
        VNetAddr = '10.0.1.0/16'

        SubNetName = 'FrontendSubnet'
        SubNetAddr = '10.0.0.0/24'
        
        VNicName = 'Vnic-Ubn-Pxy'
        AllocationMethod = 'Dynamic'
    }
    
    VM = @{
        VMName = 'VM-Ubn-Pxy'
        VMSize = 'Basic_A1'
        VMUser = 'Naw.Awn'
        VMPass = '' #Base64

        PublisherName = 'Canonical'
        Offer = 'UbuntuServer'
        Skus  = '18.04-LTS'
        Version = 'Latest'

        VhdName = 'OSD-Ubn-Pxy.vhd'
    }      
}