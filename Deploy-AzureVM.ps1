[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    $ConfigFile
)
#requires -Modules Az

Function Test-AzPSSession{          
    return($null -ne (Get-AzContext))
}

Function Test-PSDataFile{
    [CmdletBinding()]
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$FilePath
    )
    process{         
        return ([IO.Path]::GetExtension($FilePath) -eq ".psd1")
    }
}

Function Test-ResourceGroup{    
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]                 
        [String]$ResourceGroup
    )
    process{         
        return ($null -ne (Get-AzResourceGroup -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue))
    }
}

Function Test-StorageAccount{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroupName
    )
    process{         
        return ($null -ne (Get-AzStorageAccount -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue))
    }
}

Function Test-VirtualNetwork{    
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroup
    )
    process{         
        return ($null -ne (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue))
    }
}

Function Test-VirtualMachine{
    [OutputType([Bool])]
    Param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$ResourceGroup
    )
    process{         
        return ($null -ne (Get-AzVM -ResourceGroupName $ResourceGroup -Name $Name -ErrorAction SilentlyContinue))
    }
}

If((Test-Path $ConfigFile -PathType Leaf) -and (Test-PSDataFile $ConfigFile)){
    $Config = Import-PowerShellDataFile -Path $ConfigFile
}
