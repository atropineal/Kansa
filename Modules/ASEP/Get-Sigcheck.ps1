<#
.SYNOPSIS
Get-Sigcheck.ps1 returns output from the SysInternals' sicheck.exe utility

.NOTES
OUTPUT tsv
BINDEP .\Modules\bin\sigcheck.exe

!! THIS SCRIPT ASUMES SIGCHECK.EXE WILL BE IN THE TARGET'S PATH !!
#>

if (Get-Command sigcheck.exe -ErrorAction SilentlyContinue) {
    & sigcheck.exe /accepteula -a -e -c -h -q -s -r $("$env:SystemDrive\") 2> $null | 
        ConvertFrom-Csv |
            ForEach-Object { $_ }
}
else {
    Write-Error "Sigcheck.exe not found in path..."
}