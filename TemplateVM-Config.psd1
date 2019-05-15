@{
    Description   = 'Azure-SQL2017-WS2016VM'
    ResourceGroup = 'RG-Test-SQL-01'
    Location      = 'ukwest'    
           
    Vnet = @{
        VNetName = 'Vnet-Test-Env'
        VNetAddr = '10.7.0.0/16'

        SubNetName = 'LAN-Subnet'
        SubNetAddr = '10.7.0.0/24'

        VNicName = 'Vnic-Test-SQL-01'
        AllocationMethod = 'Dynamic'
    }
    
    VM = @{
        VMName = 'VM-Test-SQL-01'
        VMSize = 'BASIC_A3'
        VMUser = 'RootAdmin'
        VMPass = 'TXIuSkJvbmQwMDc='
        OSType = 'Windows'
        VhdName = 'OSD-Test-SQL-01.vhd'        
        Offer   = 'SQL2017-WS2016'
        Skus    = 'SQLDEV'
        Version = 'Latest'        
        PublisherName = 'MicrosoftSQLServer'
    }      
}