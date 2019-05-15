@{
    Description   = 'Azure VM Template'
    ResourceGroup = ''
    Location      = ''    
           
    Vnet = @{
        VNetName = ''
        VNetAddr = ''
        SubNetName = ''
        SubNetAddr = ''
        VNicName = ''
        AllocationMethod = ''
    }
    
    VM = @{
        VMName = ''
        VMSize = ''
        VMUser = ''
        VMPass = ''
        OSType = ''
        VhdName = ''        
        Offer   = ''
        Skus    = ''
        Version = ''        
        PublisherName = ''
    }      
}