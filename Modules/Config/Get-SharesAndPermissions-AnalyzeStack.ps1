if (-Not (Test-Path -Path "*sharepermissions.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,share,path,source,user,type,isowner,full,write,read,other from *sharepermissions.csv group by share,path,source,user,type,isowner,full,write,read,other order by ct"