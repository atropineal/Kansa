if (-Not (Test-Path -Path "*netinterfaces.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser "select pscomputername,macaddress,networkaddresses from *netinterfaces.csv where promiscuousmode <> 'False'"