$SmtpServerName="mail.server"
$SmtpServerPort="25"
$SmtpServerLogin="Mail.user"
$SmtpServerPassword="password"
$EmailTo="mail.user"
$EmailFrom="mail.user"
$EmailAutenfication=$False
$BackupingLog=$False

$global:debug=$False
$tStamp = Get-Date -format yyyy-MM-dd-HH.mm

$BackupLogin="admin.user"
$BackupPassword="password"

$ServerName = $env:computername

$LogDir = "c:\log\"
	If ( Test-Path $LogDir ) {remove-item -path $LogDir -force -Recurse -Confirm:$False | Out-Null}
	If (!( Test-Path $LogDir )) { New-Item $LogDir -type directory | Out-Null }
$BackupLocation = "share.folder.for.backup.items"
	net use $BackupLocation $BackupPassword /USER:$BackupLogin
	remove-item -path $BackupLocation"WindowsImageBackup\$ServerName" -force -Recurse -Confirm:$False | Out-Null
	If (!( Test-Path $BackupLocation )) { New-Item $BackupLocation -type directory | Out-Null }
$BackupLog = $LogDir + (get-date -f yyyy-MM-dd) + "-$ServerName.log"

import-module C:\PoSh\function\runcmd.ps1
import-module C:\PoSh\function\zip.ps1
import-module C:\PoSh\function\LogMail.ps1

Function WriteDebug {
	Param ( [Parameter(Mandatory=$True)] [string] $Message )
	If ( $global:debug -eq $true ) { Write-host $Message }
}

function TestPath ([string]$path) {
	if ((Test-Path -path $path -pathtype container) -ne $True) {
		New-Item -ItemType Directory -Force -Path $path | out-null
	}
}

$Error.Clear()  
wbadmin start backup -backupTarget:$BackupLocation -user:$BackupLogin -password:$BackupPassword -allCritical -systemState -quiet >> ($BackupLog)
if (!$?) { 
	$global:EmailSubj = "Backup Results failed for $ServerName"
	$global:EmailBody += "   Backup Results failed for $ServerName. Please check attached log.`r`n"
}
Else {
	$global:EmailSubj = "   Backup Results OK for $ServerName"
	$global:EmailBody += "   The backup has succeeded for $ServerName. Attached log included.`r`n"
} 

LogMail -SmtpServerName $SmtpServerName -SmtpServerPort $SmtpServerPort -SmtpServerLogin $SmtpServerLogin -SmtpServerPassword $SmtpServerPassword -EmailTo $EmailTo -EmailFrom $EmailFrom
