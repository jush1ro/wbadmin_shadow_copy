function RunCmd {
	Param (
		[Parameter(Mandatory=$True)] [string] $cmd,
		[Parameter(Mandatory=$False)] [array] $Params,
		[switch] $NoWait,
		[switch] $ReturnExitCode
	)
	If ($NoWait) {
		try {
			WriteDebug "��������� ������� � ������� ������"
			$ps = Start-Process -FilePath $cmd -ArgumentList $Params -PassThru #-NoNewWindow
			#$ps.WaitForExit() #$ps.ExitCode
		}
		catch { write-host "File" -nonewline -foregroundcolor "Yellow"; write-host $cmd -nonewline -foregroundcolor "Green"; write-host " run failed: " -nonewline -foregroundcolor "Yellow"; write-host "$($_.Exception.Message)" -foregroundcolor "Yellow"}
	}
	Else {
		try { #& $cmd $Params # �� ��� ���� ������������
			WriteDebug "��������� ������� � ��������� ��� ����������"
			$ps = Start-Process -FilePath $cmd -ArgumentList $Params -Wait -PassThru #-NoNewWindow
			$ps.WaitForExit() 
			If ($ReturnExitCode) { return $ps.ExitCode }
		}
		catch { write-host "File" -nonewline -foregroundcolor "Yellow"; write-host $cmd -nonewline -foregroundcolor "Green"; write-host " run failed: " -nonewline -foregroundcolor "Yellow"; write-host "$($_.Exception.Message)" -foregroundcolor "Yellow"}
	}
}