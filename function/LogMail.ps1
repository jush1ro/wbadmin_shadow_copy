Function LogMail {
	Param (	
		[string] $SmtpServerName,
		[string] $SmtpServerPort,
		[string] $SmtpServerLogin,
		[string] $SmtpServerPassword,
		[string] $EmailTo,
		[string] $EmailFrom,
		[switch] $EmailAutenfication,
		[switch] $BackupingLog
	)
	WriteDebug "Бэкап логов с высыланием на почту и их удаление"
	$CurrentDate=(get-date -uformat "%Y-%m-%d")
	$Days = "7" # •раним архивы 7 дней
	$LogDir = "c:\log\"; If (!( Test-Path "c:\log\" )) { New-Item "c:\log\" -type directory | Out-Null }

	If ($BackupingLog) {
		$LogFilesKilledArh = "d:\backup\log\" + "$CurrentDate" + "_killed.log.7z"
		$BackupDir = "d:\backup\log\"; If (!( Test-Path "d:\backup\log\" )) { New-Item "d:\backup\log\" -type directory | Out-Null }
		If ((Test-Path $LogDir) -and (Test-Path $BackupDir)) {
			get-childitem $LogDir -include *.log, *.txt -recurse | where {
				$CurrentLogFileArh = $BackupDir + $CurrentDate + "_" + $_.Name + ".7z"
				Zip -Pack -ArhFile $CurrentLogFileArh -FilesToArh $_.FullName
				$Error7zPack = Zip -Test -ReturnExitCode -ArhFile $CurrentLogFileArh
				If ($Error7zPack -eq 0) { Remove-Item -path $_.FullName -force | Out-Null }
			}
			get-childitem $BackupDir -include *.7z, *.rar, *.bak -recurse | where {
				If (($_.LastWriteTime -le (Get-Date).AddDays(-$Days)) -and ($_.FullName)) {
					Remove-Item -path $_.FullName -force | Out-Null
				}
			}
		}
	}

	Function SendEmail {	
		Param ($EmailTo, $EmailFrom, $EmailSubj, $EmailBody, $Files)
		$msg = New-Object Net.Mail.MailMessage
		$msg.From = $EmailFrom
		$msg.To.Add($EmailTo) 
		$msg.Body = $EmailBody
		$msg.Subject = $EmailSubj

		If ($Files) {
			foreach ($FileToAttach in $Files) {
				$attach = New-Object Net.Mail.Attachment($FileToAttach.fullname) 
				$msg.Attachments.Add($attach) 
			}
		}
		$client = New-Object net.Mail.SmtpClient($SmtpServerName, $SmtpServerPort) 
		$client.EnableSsl = $false 
		If ($EmailAutenfication) {$client.Credentials = New-Object System.Net.NetworkCredential($SmtpServerLogin, $SmtpServerPassword)}
		$client.Send($msg)
	} 

	$Files = Get-ChildItem "C:\log\" | where { ! $_.PSIsContainer }
	$global:EmailBody += ""
	SendEmail $EmailTo $EmailFrom $global:EmailSubj $global:EmailBody $Files
}
