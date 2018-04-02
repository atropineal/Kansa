if (-Not (Test-Path -Path "*proces.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,name from *process.csv group by name order by ct,name"