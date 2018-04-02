if (-Not (Test-Path -Path "*schedtasks.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
} 

Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,taskname,task\u0020to\u0020run,run\u0020as\u0020user from *schedtasks.csv  group by taskname,task\u0020to\u0020run,run\u0020as\u0020user order by ct"