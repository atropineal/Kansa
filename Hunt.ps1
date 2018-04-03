[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$ModulePath="Modules\",
    [Parameter(Mandatory=$False,Position=1)]
        [String]$TargetList=$Null,
    [Parameter(Mandatory=$False,Position=2)]
        [String]$Target=$Null
)

Write-Host "Started $(Get-Date)"

$ErrorActionPreference = "SilentlyContinue"
$StartingPath = Get-Location | Select-Object -ExpandProperty Path
$Timestamp = ([String] (Get-Date -Format yyyy-MM-dd-HH-mm-ss))
$OutputPath = $StartingPath + "\output\$Timestamp\"

[void] (New-Item -Path $OutputPath -ItemType Directory -Force) 
Set-Variable -Name ErrorLog -Value ($OutputPath + "Error.Log") -Scope Script
Set-Variable -Name Encoding -Value "Ascii" -Scope Script

if ($TargetList -and -not (Test-Path($TargetList))) {
    "ERROR: User supplied TargetList, $TargetList, was not found." | Add-Content $ErrorLog
    Exit
}
if ($TargetList) {
    $Targets = Get-Content $TargetList | Foreach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 }
} 
elseif ($Target) {
    $Targets = $Target
} 
else {
    Write-Host "Error: No Targets specified: use -Target <name> or -TargetList <file>"
    exit
}

$ModuleScript = ($ModulePath -split " ")[0]
$ModuleArgs   = @($ModulePath -split [regex]::escape($ModuleScript))[1].Trim()
$Module = ls $ModuleScript

Write-Host "Running module: $Module $ModuleArgs"
$PSSessions = New-PSSession -ComputerName $Targets -Port 5985 -Authentication "Kerberos" -SessionOption (New-PSSessionOption -NoMachineProfile)
if ($Error) {
    $Error | Add-Content $ErrorLog
    $Error.Clear()
}

$ModuleName  = $Module | Select-Object -ExpandProperty BaseName
$Arguments   = $ModuleArgs -split ","
$Job = Invoke-Command -Session $PSSessions -FilePath $Module -ArgumentList $Arguments -AsJob -ThrottleLimit 0
Write-Host "Waiting for $ModuleName to complete."
Wait-Job $Job          

$ModuleShortName = $($ModuleName -replace "Get-") 
$Job.ChildJobs | Foreach-Object { $ChildJob = $_
    $Recpt = Receive-Job $ChildJob
    if($Error) {
        $ModuleName + " reports error on " + $ChildJob.Location + ": `"" + $Error + "`"" | Add-Content $ErrorLog
        $Error.Clear()
        Return
    }
    $Outfile = $OutputPath + "\" + $ChildJob.Location + "-" + $($ModuleName -replace "Get-") + ".csv"
    $Recpt | Export-Csv -NoTypeInformation $Outfile
}
Remove-Job $Job
Remove-PSSession $PSSessions

$AnalysisScripts = Get-ChildItem -Path "$StartingPath\modules" -Filter ($ModuleName + "-Analyze*.ps1") | % { $_.Directory.Name + "\" + $_.Name }
$AnalysisOutPath = $OutputPath + "\AnalysisReports\"
$AnalysisScripts | Foreach-Object { 
    $AnalysisScript = $_
    [void] (New-Item -Path $AnalysisOutPath -ItemType Directory -Force)
    Push-Location
    Set-Location "$OutputPath"
    $AnalysisFile = ((((($AnalysisScript -split "\\")[1]) -split "Get-")[1]) -split ".ps1")[0]
    & "$StartingPath\${AnalysisScript}" | Set-Content ($AnalysisOutPath + $AnalysisFile + ".tsv")
    Pop-Location
}

Write-Host "Finished $(Get-Date)"