Class AzBlobContainer{
    [String]$ResourceGroup
    [String]$Location       = 'ukwest'
    [String]$StorageAccName
    [String]$StorageSkuName = 'Standard_LRS'
    [String]$StorageKind    = 'StorageV2'
    [String]$ContainerName

    AzBlobContainer(){}
   
    AzBlobContainer([String]$ResourceGroup, [String]$StorageAccName, [String]$ContainerName)
    {        
        $this.ResourceGroup  = $ResourceGroup        
        $this.StorageAccName = $StorageAccName.ToLower()         
        $this.ContainerName  = $ContainerName
    }

    AzBlobContainer([String]$ResourceGroup, [String]$Location, [String]$StorageAccName, [String]$StorageSkuName, [String]$StorageKind, [String]$ContainerName)
    {        
        $this.ResourceGroup  = $ResourceGroup
        $this.Location       = $Location
        $this.StorageAccName = $StorageAccName.ToLower()
        $this.StorageSkuName = $StorageSkuName
        $this.StorageKind    = $StorageKind
        $this.ContainerName  = $ContainerName.ToLower()
    }
    [bool]testStorageAccountName(){
        #Only characters lowercase a to z.
        $Regex = '^[a-z]+$'
        return ($this.StorageAccName -cmatch $Regex)
    }
    [bool]testResourceGroup(){
        return ($null -ne (Get-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location -ErrorAction 'SilentlyContinue'))
    }
    [bool]testStorageAccount(){
        return ($null -ne (Get-AzStorageAccount -ResourceGroupName $this.ResourceGroup -Name $this.StorageAccName -ErrorAction 'SilentlyContinue'))
    }
    [bool]testBlobContainer(){
        $Context = (Get-AzStorageAccount -ResourceGroup $this.ResourceGroup -Name $this.StorageAccName).Context
        return ($null -ne (Get-AzStorageContainer -Name $this.ContainerName -Context $Context -ErrorAction 'SilentlyContinue'))
    }

    [void]newResourceGroup(){
        If (!($this.testResourceGroup())){
            Try{
                New-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location 
            }Catch{
                Write-Warning ":("
                Write-Warning "Error Unable to create the Resource Group."
                break
            }
        }
        Else{
            Write-Warning "$($this.ResourceGroup) resource group already exists!"
        }
    }

    [void]newStorageAccount(){
        If ($this.testStorageAccountName()){
            If (!($this.testResourceGroup())){
                $this.newResourceGroup()
            }
            If (!($this.testStorageAccount())){
                Try{       
                    New-AzStorageAccount -ResourceGroupName $this.ResourceGroup -AccountName $this.AccountName -Location $this.Location -SkuName $this.StorageSkuName -Kind $this.StorageKind
                }Catch{                    
                    Write-Warning ":("
                    Write-Warning "Error Unable to create the Storage Account."
                    break
                }
            }
            Else { Write-Warning "$($this.StorageAccName) storage account already exists!"}
        }
        Else{
            Write-Warning "$($this.StorageAccName) is invalid name."
        }
    }

    [void]newBlobContainer(){       
        If (!($this.testStorageAccount())){
            $this.newStorageAccount()
        }
        If (!($this.testBlobContainer())){
            $StorAcc = Get-AzStorageAccount -ResourceGroupName $this.ResourceGroup -AccountName $this.StorageAccName
            Try{
                New-AzStorageContainer -Name $this.ContainerName -Context $StorAcc.Context -Permission Blob
            }Catch{
                Write-Warning ":("
                Write-Warning "Error Unable to create the Blob Container."
                break
            }
        }
        Else{
            Write-Warning "$($this.ContainerName) container already exists!"
        }        
    }
}

Function New-BlobContainer{
    Param(
        [Parameter(Mandatory)]
        [String]$ResourceGroup,
        [String]$Location,
        [Parameter(Mandatory)]
        [String]$AccountName,
        [String]$SkuName,
        [String]$Kind,
        [Parameter(Mandatory)]
        [String]$ContainerName
    )

    #$BlobObj = New-Object AzBlobContainer($ResourceGroup, $Location, $AccountName, $SkuName, $Kind, $ContainerName)
    #$BlobObj.newBlobContainer()

    $BlobObj = New-Object AzBlobContainer
    $BlobObj.ResourceGroup  = $ResourceGroup
    $BlobObj.Location       = $Location
    $BlobObj.StorageAccName = $AccountName
    $BlobObj.StorageSkuName = $SkuName
    $BlobObj.StorageKind    = $Kind
    $BlobObj.ContainerName  = $ContainerName.ToLower()
    
    #$BlobObj.testResourceGroup()
    #$BlobObj.testStorageAccountName()
    #$BlobObj.testStorageAccount()
    #$BlobObj.testBlobContainer()
    #$BlobObj.newBlobContainer()
    $BlobObj.newStorageAccount()
    #$BlobObj.newResourceGroup()
}

New-BlobContainer -ResourceGroup 'RG-Stor-Test-Dev' -Location 'ukwest' -AccountName 'stortestdev' -SkuName 'Standard_LRS' -Kind 'StorageV2' -ContainerName 'sqlbackup'
#Remove-AzStorageContainer -Name 'backup' -Context $StorAcc.Context -Force
#Clear-Host
