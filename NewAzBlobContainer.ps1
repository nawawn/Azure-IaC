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
        $Context = (Get-AzStorageAccount -ResourceGroupName $this.ResourceGroup -Name $this.StorageAccName).Context
        return ($null -ne (Get-AzStorageContainer -Name $this.ContainerName -Context $Context -ErrorAction 'SilentlyContinue'))
    }

    [void]newResourceGroup(){
        If (!($this.testResourceGroup())){
            Try{
                New-AzResourceGroup -Name $this.ResourceGroup -Location $this.Location 
            }Catch{
                Write-Warning ':('
                Write-Warning 'Error Unable to create the Resource Group.'
                Write-Warning "$Error.Exception"
                break
            }
            Write-Verbose "$($this.ResourceGroup) resource group has been created!"
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
                    New-AzStorageAccount -ResourceGroupName $this.ResourceGroup -Name $this.StorageAccName -Location $this.Location -SkuName $this.StorageSkuName -Kind $this.StorageKind
                }Catch{                    
                    Write-Warning ':('
                    Write-Warning 'Error Unable to create the Storage Account.'
                    Write-Warning "$Error.Exception"
                    break
                }
                Write-Verbose "$($this.StorageAccName) storage account has been created!"
            }
            Else { Write-Warning "$($this.StorageAccName) storage account already exists!" }
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
            Try{
                $StorAcc = Get-AzStorageAccount -ResourceGroupName $this.ResourceGroup -Name $this.StorageAccName            
                New-AzStorageContainer -Name $this.ContainerName -Context $StorAcc.Context -Permission 'Off'
            }Catch{
                Write-Warning ':('
                Write-Warning 'Error Unable to create the Blob Container.'
                Write-Warning "$Error.Exception"
                break
            }
            Write-Verbose "$($this.ContainerName) container has been created!"
        }
        Else{
            Write-Warning "$($this.ContainerName) container already exists!"
        }        
    }
}

Function New-BlobContainer{
<#
.DESCRIPTION
Creates an Azure Blob storage container. This will also create the Resource Group and the Storage Account if they are not present.
.EXAMPLE
New-BlobContainer -ResourceGroup 'RG-Myresgroup' -AccountName 'stortestdev' -ContainerName 'testcontainer' -Verbose
.EXAMPLE
New-BlobContainer -ResourceGroup 'RG-Myresgroup' -Location 'ukwest' -AccountName 'stortestdev' -SkuName 'Standard_LRS' -Kind 'StorageV2' -ContainerName 'backup'
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)][String]$ResourceGroup,
        [String]$Location,
        
        [Parameter(Mandatory)][String]$AccountName,        
        [AllowNull()][ValidateSet('Standard_LRS','Standard_ZRS','Standard_GRS','Standard_RAGRS','Premium_LRS')]
        [String]$SkuName,        
        [AllowNull()][ValidateSet('Storage','StorageV2','BlobStorage','BlockBlobStorage')]
        [String]$Kind,
        
        [Parameter(Mandatory)][String]$ContainerName
    )

    If (!($Location) -and !($SkuName) -and !($Kind)){
        $BlobObj = New-Object AzBlobContainer($ResourceGroup, $AccountName, $ContainerName)
        #$BlobObj.newResourceGroup()
        #$BlobObj.newStorageAccount()
        $BlobObj.newBlobContainer()
    }
    Else{
        $BlobObj = New-Object AzBlobContainer($ResourceGroup, $Location, $AccountName, $SkuName, $Kind, $ContainerName)
        #$BlobObj.newResourceGroup()
        #$BlobObj.newStorageAccount()
        $BlobObj.newBlobContainer()
    }
}

#$StorAcc = Get-AzStorageAccount -ResourceGroupName 'RG-Myresgroup' -Name 'stortestdev'
#Remove-AzStorageContainer -Name 'backup' -Context $StorAcc.Context -Force
#Remove-AzResourceGroup -ResourceGroupName  'RG-Myresgroup' -Force