if (-Not (Test-Path -Path "*smbconnection.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername as source,username as source_user,servername as target,credential as target_user,sharename from *smbconnection.csv order by source,source_user,target,target_user,sharename"