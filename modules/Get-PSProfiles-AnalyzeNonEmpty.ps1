if (-Not (Test-Path -Path "*psprofiles.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,name,profilepath,script from *psprofiles.csv where script is not null"