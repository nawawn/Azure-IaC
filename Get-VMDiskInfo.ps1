Function Get-VMOSDiskInfo{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String]$VMName,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String]$ResourceGroup
    )
    Begin{}
    Process{
        return ((Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName).StorageProfile.OsDisk | Select Name,OsType,DiskSizeGB,ManagedDisk)
    }
    End{}
}