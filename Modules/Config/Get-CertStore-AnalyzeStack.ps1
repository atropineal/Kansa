if (-Not (Test-Path -Path "*certstore.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,friendlyname,thumbprint,issuer from *certstore.csv group by friendlyname,thumbprint,issuer order by ct"