<#
.SYNOPSIS
Get-CertStore.ps1 enumerates certificate stores.
.DESCRIPTION
Get-CertStore.ps1 uses PowerShell's Certificate provider to access and
enumerate information about certificates on the host.
.NOTES
Next line is required by Kansa.ps1 to determine how to treat the output
of this script.
OUTPUT TSV
#>

$ErrorActionPreference = "SilentlyContinue"
try {
    Get-ChildItem -Path "Cert:\*" -Recurse -ErrorAction SilentlyContinue | Select-Object -ErrorAction SilentlyContinue PSParentPath,FriendlyName,NotAfter,NotBefore,SerialNumber,Thumbprint,Issuer,Subject
}
catch {}