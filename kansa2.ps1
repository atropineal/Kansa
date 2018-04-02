[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$ModulePath="Modules\",
    [Parameter(Mandatory=$False,Position=1)]
        [String]$TargetList=$Null,
    [Parameter(Mandatory=$False,Position=2)]
        [String]$Target=$Null
)
$TargetCount=0
Write-Host "Started $(Get-Date)"
$ErrorActionPreference = "SilentlyContinue"
$StartingPath = Get-Location | Select-Object -ExpandProperty Path
$Timestamp = ([String] (Get-Date -Format yyyy-MM-dd-HH-mm-ss))
$OutputPath = $StartingPath + "\Output\$Timestamp\"
[void] (New-Item -Path $OutputPath -ItemType Directory -Force) 
Set-Variable -Name ErrorLog -Value ($OutputPath + "Error.Log") -Scope Script
if (Test-Path($ErrorLog)) {
    Remove-Item -Path $ErrorLog
}
Set-Variable -Name Encoding -Value "Ascii" -Scope Script
if ($TargetList -and -not (Test-Path($TargetList))) {
    "ERROR: User supplied TargetList, $TargetList, was not found." | Add-Content -Encoding $Encoding $ErrorLog
    Exit
}
$ModuleScript = ($ModulePath -split " ")[0]
$ModuleArgs   = @($ModulePath -split [regex]::escape($ModuleScript))[1].Trim()
$ModuleHash = New-Object System.Collections.Specialized.OrderedDictionary
$ModuleHash.Add((ls $ModuleScript), $ModuleArgs)
$Module = ls $ModuleScript | Select-Object -ExpandProperty BaseName
Write-Host "Running module: $Module $ModuleArgs"
$Modules = $ModuleHash
if ($TargetList) {
    $Targets = Get-Content $TargetList | Foreach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 }
} elseif ($Target) {
    $Targets = $Target
} else {
    Write-Host "Error: No Targets specified: use -Target <name> or -TargetList <file>"
    exit
}
$PSSessions = New-PSSession -ComputerName $Targets -Port 5985 -Authentication "Kerberos" -SessionOption (New-PSSessionOption -NoMachineProfile)
if ($Error) {
    $Error | Add-Content -Encoding $Encoding $ErrorLog
    $Error.Clear()
}
$Modules.Keys | Foreach-Object { $Module = $_
    $ModuleName  = $Module | Select-Object -ExpandProperty BaseName
    $Arguments   = @()
    $Arguments   += $($Modules.Get_Item($Module)) -split ","
        
    if ($Arguments) {
        $Job = Invoke-Command -Session $PSSessions -FilePath $Module -ArgumentList $Arguments -AsJob -ThrottleLimit 0
        Write-Host "Waiting for $ModuleName $Arguments to complete."
    } else {
        $Job = Invoke-Command -Session $PSSessions -FilePath $Module -AsJob -ThrottleLimit 0                
        Write-Host "Waiting for $ModuleName to complete."
    }
    Wait-Job $Job          
    $GetlessMod = $($ModuleName -replace "Get-") 
    $EstOutPathLength = $OutputPath.Length + ($GetlessMod.Length * 2) + ($ArgFileName.Length * 2)                            
    $Job.ChildJobs | Foreach-Object { $ChildJob = $_
        $Recpt = Receive-Job $ChildJob
        if($Error) {
            $ModuleName + " reports error on " + $ChildJob.Location + ": `"" + $Error + "`"" | Add-Content -Encoding $Encoding $ErrorLog
            $Error.Clear()
            Return
        }
        $Outfile = $OutputPath + "\" + $ChildJob.Location + "-" + $GetlessMod + $ArgFileName
        $Outfile = $Outfile + ".csv"
        $Recpt | Export-Csv -NoTypeInformation -Encoding $Encoding $Outfile
    }
    Remove-Job $Job
}
Remove-PSSession $PSSessions
if (Get-Command -Name Logparser.exe) {
    $AnalysisScripts = Get-ChildItem -Path "$StartingPath\Modules" -Depth 2 -Filter "*-Analyze*.ps1" | % { $_.Directory.Name + "\" + $_.Name }
    $AnalysisOutPath = $OutputPath + "\AnalysisReports\"
    $AnalysisScripts | Foreach-Object { $AnalysisScript = $_
        [void] (New-Item -Path $AnalysisOutPath -ItemType Directory -Force)
        Push-Location
        Set-Location "$OutputPath"
        $AnalysisFile = ((((($AnalysisScript -split "\\")[1]) -split "Get-")[1]) -split ".ps1")[0]
        & "$StartingPath\Modules\${AnalysisScript}" | Set-Content -Encoding $Encoding ($AnalysisOutPath + $AnalysisFile + ".tsv")
        Pop-Location
    }
} else {
    "Kansa could not find logparser.exe in path. Skipping Analysis." | Add-Content -Encoding $Encoding -$ErrorLog
}
Write-Host "Finished $(Get-Date)"