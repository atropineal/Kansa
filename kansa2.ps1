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
$Quiet=$False

Try {

if(!$Quiet) {
    $VerbosePreference = "Continue"
}

function Get-Modules {
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$ModulePath
)
    $Error.Clear()
    $ModuleScript = ($ModulePath -split " ")[0]
    $ModuleArgs   = @($ModulePath -split [regex]::escape($ModuleScript))[1].Trim()
    $Modules = $FoundModules = @()
    $ModuleHash = New-Object System.Collections.Specialized.OrderedDictionary
    $ModuleHash.Add((ls $ModuleScript), $ModuleArgs)
    $Module = ls $ModuleScript | Select-Object -ExpandProperty BaseName
    Write-Verbose "Running module: $Module $ModuleArgs"
    Return $ModuleHash
}

function Get-Targets {
Param(
    [Parameter(Mandatory=$False,Position=0)]
        [String]$TargetList=$Null,
    [Parameter(Mandatory=$False,Position=1)]
        [int]$TargetCount=0
)
    $Error.Clear()
    $Targets = $False
    if ($TargetList) {
        # user provided a list of targets
        $Targets = Get-Content $TargetList | Foreach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 }
    } else {
        Write-Hosts "Expected list of targets.. use -Target or -TargetList!"
        exit
    }

    if ($Targets) {
        Write-Verbose "`$Targets are ${Targets}."
        return $Targets
    } else {
        Write-Verbose "Get-Targets function found no targets. Checking for errors."
    }
    
    if ($Error) { # if we make it here, something went wrong
        $Error | Add-Content -Encoding $Encoding $ErrorLog
        "ERROR: Get-Targets function could not get a list of targets. Quitting."
        $Error.Clear()
        Exit
    }
}

function Get-TargetData {
<#
.SYNOPSIS
Runs each module against each target. Writes out the returned data to host where Kansa is run from.
#>
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [Array]$Targets,
    [Parameter(Mandatory=$True,Position=1)]
        [System.Collections.Specialized.OrderedDictionary]$Modules,
    [Parameter(Mandatory=$False,Position=2)]
        [System.Management.Automation.PSCredential]$Credential=$False,
    [Parameter(Mandatory=$False,Position=3)]
        [Int]$ThrottleLimit
)
    $Error.Clear()

    # Create our sessions with targets
    $PSSessions = New-PSSession -ComputerName $Targets -Port 5985 -Authentication "Kerberos" -SessionOption (New-PSSessionOption -NoMachineProfile)

    # Check for and log errors
    if ($Error) {
        $Error | Add-Content -Encoding $Encoding $ErrorLog
        $Error.Clear()
    }

    $Modules.Keys | Foreach-Object { $Module = $_
        $ModuleName  = $Module | Select-Object -ExpandProperty BaseName
        $Arguments   = @()
        $Arguments   += $($Modules.Get_Item($Module)) -split ","
        $ArgFileName = "" 
            
        $DirectivesHash  = @{}
            
        if ($Arguments) {
            Write-Debug "Invoke-Command -Session $PSSessions -FilePath $Module -ArgumentList `"$Arguments`" -AsJob -ThrottleLimit $ThrottleLimit"
            $Job = Invoke-Command -Session $PSSessions -FilePath $Module -ArgumentList $Arguments -AsJob -ThrottleLimit $ThrottleLimit
            Write-Verbose "Waiting for $ModuleName $Arguments to complete."
        } else {
            Write-Debug "Invoke-Command -Session $PSSessions -FilePath $Module -AsJob -ThrottleLimit $ThrottleLimit"
            $Job = Invoke-Command -Session $PSSessions -FilePath $Module -AsJob -ThrottleLimit $ThrottleLimit                
            Write-Verbose "Waiting for $ModuleName to complete."
        }
        Wait-Job $Job
            
        $GetlessMod = $($ModuleName -replace "Get-") 
        # Long paths prevent output from being written, so we truncate $ArgFileName to accomodate
        # We're estimating the output path because at this point, we don't know what the hostname
        # is and it is part of the path. Hostnames are 15 characters max, so we assume worst case
        $EstOutPathLength = $OutputPath.Length + ($GetlessMod.Length * 2) + ($ArgFileName.Length * 2)
                            
        $Job.ChildJobs | Foreach-Object { $ChildJob = $_
            $Recpt = Receive-Job $ChildJob
            if($Error) {
                $ModuleName + " reports error on " + $ChildJob.Location + ": `"" + $Error + "`"" | Add-Content -Encoding $Encoding $ErrorLog
                $Error.Clear()
                Return
            }
            $Outfile = $OutputPath + "\" + $ChildJob.Location + "-" + $GetlessMod + $ArgFileName
            if ($Outfile.length -gt 256) {
                "ERROR: ${GetlessMod}'s output path length exceeds 260 character limit. Can't write the output to disk for $($ChildJob.Location)." | Add-Content -Encoding $Encoding $ErrorLog
                Return
            }
            $Outfile = $Outfile + ".csv"
            $Recpt | Export-Csv -NoTypeInformation -Encoding $Encoding $Outfile
        }
        Remove-Job $Job
    }
    Remove-PSSession $PSSessions

    if ($Error) {
        $Error | Add-Content -Encoding $Encoding $ErrorLog
        $Error.Clear()
    }
    
}

function Set-KansaPath {
    $Error.Clear()
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $kansapath  = Split-Path $Invocation.MyCommand.Path
    $Paths      = ($env:Path).Split(";")
    if (-not($Paths -match [regex]::Escape("$kansapath\Modules"))) {
        $env:Path = $env:Path + ";$kansapath\Modules"
    }
    $AnalysisPaths = (ls -Recurse "$kansapath\Modules" | Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName)
    $AnalysisPaths | ForEach-Object {
        if (-not($Paths -match [regex]::Escape($_))) {
            $env:Path = $env:Path + ";$_"
        }
    }
    if ($Error) {
        $Error | Add-Content -Encoding $Encoding $ErrorLog
        $Error.Clear()
    }
}

function Get-Analysis {
<#
.SYNOPSIS
Runs analysis scripts
Saves output to AnalysisReports folder under the output path
Fails silently, but logs errors to Error.log file
#>
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$OutputPath,
    [Parameter(Mandatory=$True,Position=1)]
        [String]$StartingPath
)
    $Error.Clear()

    if (Get-Command -Name Logparser.exe) {
        $AnalysisScripts = @()
        $AnalysisScripts = Get-ChildItem -Path "$StartingPath\Modules" -Depth 2 -Filter "*-Analyze*.ps1" | % { $_.Directory.Name + "\" + $_.Name }
        $AnalysisOutPath = $OutputPath + "\AnalysisReports\"
        [void] (New-Item -Path $AnalysisOutPath -ItemType Directory -Force)
        $DirectivesHash  = @{}
        $AnalysisScripts | Foreach-Object { $AnalysisScript = $_
            # $DirectivesHash = Get-Directives $AnalysisScript -AnalysisPath
            Push-Location
            Set-Location "$OutputPath"
            $AnalysisFile = ((((($AnalysisScript -split "\\")[1]) -split "Get-")[1]) -split ".ps1")[0]
            # As of this writing, all analysis output files are tsv
            & "$StartingPath\Modules\${AnalysisScript}" | Set-Content -Encoding $Encoding ($AnalysisOutPath + $AnalysisFile + ".tsv")
            Pop-Location
        }
    } else {
        "Kansa could not find logparser.exe in path. Skipping Analysis." | Add-Content -Encoding $Encoding -$ErrorLog
    }
    # Non-terminating errors can be checked
    if ($Error) {
        # Write the $Error to the $Errorlog
        $Error | Add-Content -Encoding $Encoding $ErrorLog
        $Error.Clear()
    }
} # End Get-Analysis

Write-Verbose "Started $(Get-Date)"

$Error.Clear()
$ErrorActionPreference = "SilentlyContinue"
$StartingPath = Get-Location | Select-Object -ExpandProperty Path

$Runtime = ([String] (Get-Date -Format yyyy-MM-dd-HH-mm-ss))
$OutputPath = $StartingPath + "\Output\$Runtime\"
[void] (New-Item -Path $OutputPath -ItemType Directory -Force) 

Set-Variable -Name ErrorLog -Value ($OutputPath + "Error.Log") -Scope Script

if (Test-Path($ErrorLog)) {
    Remove-Item -Path $ErrorLog
}

Set-Variable -Name Encoding -Value "Ascii" -Scope Script

Write-Debug "Sanity checking parameters"
$Exit = $False
if ($TargetList -and -not (Test-Path($TargetList))) {
    "ERROR: User supplied TargetList, $TargetList, was not found." | Add-Content -Encoding $Encoding $ErrorLog
    $Exit = $True
}

if ($Exit) {
    "ERROR: One or more errors were encountered with user supplied arguments. Exiting." | Add-Content -Encoding $Encoding $ErrorLog
    Exit
}
Write-Debug "Parameter sanity check complete."

Set-KansaPath

Write-Debug "`$ModulePath is ${ModulePath}."
Write-Debug "`$OutputPath is ${OutputPath}."
Write-Debug "`$ServerList is ${TargetList}."

$Modules = Get-Modules -ModulePath $ModulePath

if ($TargetList) {
    $Targets = Get-Targets -TargetList $TargetList -TargetCount $TargetCount
} elseif ($Target) {
    $Targets = $Target
} else {
    Write-Host "Error: No Targets specified: use -Target <name> or -TargetList <file>"
    exit
}

Get-TargetData -Targets $Targets -Modules $Modules -Credential $Credential -ThrottleLimit $ThrottleLimit

Get-Analysis $OutputPath $StartingPath

Write-Verbose "Finished $(Get-Date)"

Exit

} Catch {
    ("Caught: {0}" -f $_)
} Finally {
    Exit-Script
}