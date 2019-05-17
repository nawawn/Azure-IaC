Function New-ResourceGroup{
    Param(
        [Parameter(Mandatory)]
        [String]$ResourceGroup,
        [String]$Location
    )
    return (New-AzResourceGroup -Name $ResourceGroup -Location $Location)
}
Function New-StorageProvision{
    Param(        
        [Parameter(Mandatory)]
        [String]$AccountName,
        [String]$SkuName = 'Standard_LRS',
        [String]$Kind = 'StorageV2'
    )
    $ResourceGroup = (Get-AzResourceGroup -ResourceGroup -Location).ResourceGroupName
    return (New-AzStorageAccount -ResourceGroupName $ResourceGroup -AccountName $AccountName -Location $Location -SkuName $SkuName -Kind $Kind)
}

Function New-BlobContainer{
    Param(
        [String]$ContainerName
    )
    $StorAcc = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -AccountName $AccountName
    New-AzStorageContainer -Name $ContainerName -Context $StorAcc.Context -Permission Blob
}