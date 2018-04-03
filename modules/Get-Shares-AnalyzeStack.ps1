if (-Not (Test-Path -Path "*shares.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,name,path,securitydescriptor from *shares.csv group by name,path,securitydescriptor order by ct"