<#
.SYNOPSIS
Get-SmbSession.ps1 returns smb connections from this host.

.NOTES
Next line needed by Kansa.ps1 for handling this scripts output.
OUTPUT TSV
#>

if (Get-Command Get-SmbConnection -ErrorAction SilentlyContinue) {
    Get-SmbConnection
}