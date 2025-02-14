$LOCAL = "C:\TMP"
$EPHEMERAL = "D:\TMP.vhdx"

if (-not (Get-Module -ListAvailable -Name Hyper-V)) {
    Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
}

If (!(Test-Path $LOCAL)) { 
    Remove-Item -Path $LOCAL -Recurse -Force -ErrorAction SilentlyContinue 
} else { 
    New-Item -ItemType Directory -Path $LOCAL 
}
New-VHD -Path $EPHEMERAL -SizeBytes 300MB -Fixed -NoDriveLetter -BlockSizeBytes 4K -LogicalSectorSizeBytes 4K -PhysicalSectorSizeBytes 4K -PassThru | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -UseMaximumSize -PassThru | Format-Volume -FileSystem ReFS -AllocationUnitSize 4K -NewFileSystemLabel "TMP" -Confirm:$false | Get-Disk | Get-Partition | ? { ($_ | Get-Volume) -ne $Null } | Add-PartitionAccessPath -AccessPath $LOCAL
