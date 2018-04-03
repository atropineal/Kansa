if (-Not (Test-Path -Path "*process.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
logparser /q:on "select pscomputername,path,id from *process.csv where path like '%\\svchost.exe' and path not like 'c:\\windows\\system32%\\svchost.exe' order by pscomputername,path,id"