@{
    Description   = 'Azure-WindowsVM'

    ResourceGroup = 'RG-IIS-Pri'
    Location      = 'uksouth'    
    StorageAccount = 'storprod'
    Type           = 'Standard_LRS'
    
    Vnet = @{
        VNetName = 'Vnet-IIS-Pri'
        VNetAddr = '10.0.1.0/16'

        SubnetName = 'FrontendSubnet'
        SubnetAddr = '10.0.0.0/24'
        
        VNicName = 'Vnic-IIS-Pri'
        AllocationMethod = 'Dynamic'
    }
    
    VM = @{
        VMName = 'VM-IIS-Pri'
        VMSize = 'Basic_A1'
        VMUser = 'RootAdmin'
        VMPass = '#Base64'
        OSType = 'Windows'
        
        PublisherName = 'MicrosoftWindowsServer'
        Offer = 'WindowsServer'
        Skus  = '2019-Datacenter'
        Version = 'Latest'

        VhdName = 'OSD-IIS-Pri.vhd'
    }      
}