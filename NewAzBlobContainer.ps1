Class AzBlobContainer{
    [String]$ResourceGroup
    [String]$Location
    [String]$StorageAccName
    [String]$StorageSkuName = 'Standard_LRS'
    [String]$StorageKind = 'StorageV2'
    [String]$ContainerName

    AzBlobContainer(){}

    AzBlobContainer([String]$ResourceGroup, [String]$Location, [String]$StorageAccName, [String]$StorageSkuName, [String]$StorageKind, [String]$ContainerName)
    {        
        $this.ResourceGroup  = $ResourceGroup
        $this.Location       = $Location
        $this.StorageAccName = $StorageAccName.ToLower()
        $this.StorageSkuName = $StorageSkuName
        $this.StorageKind    = $StorageKind
        $this.ContainerName  = $ContainerName
    }
    [void]newResourceGroup(){
        New-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location
    }

    [bool]testStorageAccountName(){
        $Regex = '^[a-z]+$'
        return ($this.StorageAccName -cmatch $Regex)
    }

    [bool]testResourceGroup(){
        return ($null -ne (Get-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location))
    }

    [bool]testStorageAccount(){
        return ($null -ne (Get-AzStorageAccount -ResourceGroupName $this.ResourceGroup -Name $this.StorageAccName))
    }

    [void]newStorageAccount(){
        If (testStorageAccountName){
            If (!(testResourceGroup)){
                newResourceGroup
            }
            If (!(testStorageAccount)){        
                New-AzStorageAccount -ResourceGroupName $this.ResourceGroup -AccountName $this.AccountName -Location $this.Location -SkuName $this.StorageSkuName -Kind $this.StorageKind
            }
            Else { Write-Output "$($this.StorageAccName) already exists!"}
        }
    }

    [void]newBlobContainer(){
        #WIP
        
        $StorAcc = Get-AzStorageAccount -ResourceGroupName $this.ResourceGroup -AccountName $this.StorageAccName
        New-AzStorageContainer -Name $this.ContainerName -Context $StorAcc.Context -Permission Blob
    }
}