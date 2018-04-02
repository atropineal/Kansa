if (-Not (Test-Path -Path "*process.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,path from *process.csv group by path order by ct,path"