#Future Implementation for transitive dependency (Work in Progress)
Class ResourceGroup{
    [String]$ResourceGroup
    [String]$Location = 'ukwest'
    
    ResourceGroup(){}
    ResourceGroup($RG,$Loc){
        $this.ResourceGroup = $RG
        $this.Location      = $Loc
    }
    [bool]Exists(){
        return ($null -ne (Get-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location))
    }
    [void]CreateResourceGroup(){
        If($this.Exists()){
            Write-Warning "$($this.ResourceGroup) resource group already exists!"
        }
        Else{
            Try{
                New-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location 
            }
            Catch{            
                Write-Warning ':( Error! Unable to create the Resource Group.'
                Write-Warning "$Error.Exception"
                break
            }
            Write-Verbose "$($this.ResourceGroup) resource group has been created!"
        }
    }
}
Class StorageAccount:ResourceGroup{
    [String]$StorageAccName
    [String]$StorageSku  = 'Standard_LRS'
    [String]$StorageKind = 'StorageV2'
    
    StorageAccount(){}
    StorageAccount($StorAccName,$StorSku,$StorKind){
        $this.StorageAccName = $StorAccName.ToLower()
        $this.StorageSku     = $StorSku
        $this.StorageKind    = $StorKind
    }
    [bool]Exists(){        
        return ($null -ne (Get-AzStorageAccount -ResourceGroupName $([ResourceGroup]$this.ResourceGroup) -Name $this.StorageAccName -ErrorAction 'SilentlyContinue'))        
    }
    [bool]IsValidName(){
        #Only characters lowercase a to z and numbers.
        $Regex = '^[a-z0-9]+$'
        return ($this.StorageAccName -cmatch $Regex)
    }
    [void]CreateStorageAccount(){
        If($this.IsValidName()){
            If(([ResourceGroup]$this).Exists()){
                If (-Not($this.Exists())){
                    Try{
                        New-AzStorageAccount -ResourceGroupName $([ResourceGroup]$this.ResourceGroup) -Name $this.StorageAccName -SkuName $this.StorageSku -Kind $this.StorageKind
                    }
                    Catch{
                        Write-Warning ':( Error! Unable to create the Storage Account.'
                        Write-Warning "$Error.Exception"
                        break
                    }
                    Write-Verbose "$($this.StorageAccName) has been created!"
                }
                Else{
                    Write-warning "$($this.StorageAccName) storage account already exists!"
                }
            }
            Else{
                Write-warning "Please create the resource group first!"
            }
        }
        Else{
            Write-Warning "$($this.StorageAccName) is invalid storage name."
        }
    }
}
Class BlobContainer:StorageAccount{
    [String]$ContainerName
    [String]$Context
    BlobContainer(){}
    BlobContainer($ConName){
        $this.ContainerName = $ConName        
    }
    [void]SetContext(){
        $this.Context = (Get-AzStorageAccount -Name ([StorageAccount]$this).StorageAccName -ResourceGroupName ([ResourceGroup]$this).ResourceGroup).Context
    }
    [bool]Exists(){
        If( ([StorageAccount]$this).Exists() ){
            $this.SetContext()
            return ($null -ne (Get-AzStorageContainer -Name $this.ContainerName -Context $this.Context))
        }
        Else{
            return $false
        }        
    }
    [bool]IsValidName(){
        #Only lowercase characters a to z and numbers.
        $Regex = '^[a-z0-9]+$'
        return ($this.ContainerName -cmatch $Regex)
    }
    [void]CreateBlobContainer(){
        If ( $this.IsValidName()){
            If (([StorageAccount]$this).Exists()){
                If (-Not($this.Exists())){
                    Try{
                        $this.SetContext()                        
                        New-AzStorageContainer -Name $this.ContainerName -Context $this.Context -Permission 'Blob'
                    }
                    Catch{                        
                        Write-Warning ':( Error! Unable to create the Blob Container.'
                        Write-Warning "$Error.Exception"
                        break
                    }
                    Write-Verbose "$($this.ContainerName) container has been created!"
                }
                Else{
                    Write-Warning "$($this.ContainerName) blob container already exists!"
                }
            }
            Else{
                Write-Warning "Please create the storage account first!"
            }
        }
        Else{
            Write-Warning "$($this.ContainerName) is invalid container name"
        }
    }
}
Class FileShare:StorageAccount{
    [String]$ShareName
    [String]$Context
    [Int64]$QuotaGB = 1024
    FileShare(){}
    FileShare($ShrName){
        $this.ShareName = $ShrName        
    }
    [void]SetContext(){
        $this.Context = (Get-AzStorageAccount -Name ([StorageAccount]$this).StorageAccName -ResourceGroupName ([ResourceGroup]$this).ResourceGroup).Context
    }
    [void]CreateFileShare(){}
}
Class Table:StorageAccount{
    [String]$TableName
    [String]$Context
    Table(){}
    Table($TblName){
        $this.TableName = $TblName
    }
    [void]SetContext(){
        $this.Context = (Get-AzStorageAccount -Name ([StorageAccount]$this).StorageAccName -ResourceGroupName ([ResourceGroup]$this).ResourceGroup).Context
    }
    [void]CreateTable(){}
}
Class Queue:StorageAccount{
    [String]$QueueName
    [String]$Context
    Queue(){}
    Queue($QueName){
        $this.QueueName = $QueName.ToLower()
    }
    [void]SetContext(){
        $this.Context = (Get-AzStorageAccount -Name ([StorageAccount]$this).StorageAccName -ResourceGroupName ([ResourceGroup]$this).ResourceGroup).Context
    }
    [void]CreateQueue(){}
}

Function New-xBlobContainer{
    # Create Resource Group
    # Create Storage Account
    # Create blob storage
}
Function New-xFileShare{
    # Create Resource Group
    # Create Storage Account
    # Create File Share
}
Function New-xTable{
    # Create Resource Group
    # Create Storage Account
    # Create Table
}
Function New-xQueue{
    # Create Resource Group
    # Create Storage Account
    # Create Queue
}