if (-Not (Test-Path -Path "*filehash.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,path,hash from *filehash.csv group by path,hash order by ct"