Function Download-BlobContainer{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroup,
        [Parameter(Mandatory)][String]$StorageAccountName,
        [Parameter(Mandatory)][String]$ContainerName,
        [AllowNull()][String]$FileName,
        [String]$Destination = $(Get-Location)
    )
    Begin{
        $Storage = Get-AzStorageAccount -ResourceGroup $ResourceGroup -StorageAccountName $StorageAccountName
    }
    Process{
        $Blob = Get-AzStorageBlob -Container $ContainerName -Context $Storage.Context
        If ($FileName){
            Get-AzStorageBlobContent -Blob $FileName -Container $ContainerName -Destination $Destination -Context $Storage.Context
        }
        Else{
            Foreach($file in $Blob){
                Get-AzStorageBlobContent -Blob $File.Name -Container $ContainerName -Destination $Destination -Context $Storage.Context           
            }    
        }
    }
<#
.Example
    Download-BlobContainer -ResourceGroup 'RG-Storage' -StorageAccountName 'stortest012' -ContainerName 'files-container'
#>
}

Function UploadTo-BlobContainer{
    Param(
        [Parameter(Mandatory)][String]$ResourceGroup,
        [Parameter(Mandatory)][String]$StorageAccountName,
        [Parameter(Mandatory)][String]$ContainerName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]$File
        
    )
    Begin{        
        $Storage = Get-AzStorageAccount -ResourceGroup $ResourceGroup -StorageAccountName $StorageAccountName
    }
    Process{        
        Set-AzStorageBlobContent -File $FileName -Container $containerName -Blob $((Get-Item $File).Name) -Context $Storage.Context
    }
<#
.EXAMPLE
   UploadTo-BlobContainer -ResourceGroup 'RG-Storage' -StorageAccountName 'stortest012' -ContainerName 'files-container' -File 'C:\temp\test.txt'
#>
}