$events = Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' | where-object { $_.Id -eq 1149 }
$events | % {
	$object = "" | select-object username,domain,sourceip
	$object.username = $_.Properties[0].Value
	$object.domain = $_.Properties[1].Value
	$object.sourceip = $_.Properties[2].Value
	$object
}
