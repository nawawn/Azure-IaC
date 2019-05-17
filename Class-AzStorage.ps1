#Future Implementation for transitive dependency
Class ResourceGroup
{
    [String]$ResourceGroup
    [String]$Location = 'ukwest'

}
Class StorageAccount:ResourceGroup
{
    [String]$StorageAccName
    [String]$StorageSkuName = 'Standard_LRS'
    [String]$StorageKind    = 'StorageV2'

}
Class BlobContainer:StorageAccount
{
    [String]$ContainerName
    [String]$Context
}
Class FileShare:StorageAccount
{
    [String]$ShareName
    [String]$Context
    [Int64]$QuotaGB = 1024
}
Class Table:StorageAccount
{
    [String]$TableName
    [String]$Context
}
Class Queue:StorageAccount
{
    [String]$QueueName
    [String]$Context
}

