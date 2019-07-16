function Zip {
	Param (
		[string] $UnpackDir,
		[string] $UnpackFile,
		[string] $ArhFile,
		[string] $FilesToArh,
		[string] $FullBackupFile,
		[switch] $Unpack,
		[switch] $PackFile,
		[switch] $PackDir,
		[switch] $Test,
		[switch] $DelFile,
		[switch] $DelFilesInPath,
		[switch] $differential
	)
	$cmd = "c:\Program Files\7-Zip\7z.exe"
	# ��������
	$arg17 = "-mmt=on"
	$arg1 = 'a'
	$arg2 = '-tzip'
	$arg3 = '-mx5'
	$arg4 = $ArhFile
	$arg5 = '-r'
	$arg6 = $FilesToArh
	#������������
	$arg7 = 't'
	$arg8 = $ArhFile
	#����������
	$arg9 = 'x'
	$arg10 = $ArhFile
	$arg11 = '-y'
	$arg12 = '-o' + $UnpackDir
	#���������������� �����
	$arg13 = "u"
	$arg14 = $FullBackupFile
	$arg15 = "-u-"
	$arg16 = "-up0q3r2x2y2z0w2!" + $ArhFile
	Try {
		If ($PackFile) {
			[Array]$Params = $arg17, $arg1, $arg2, $arg3, $arg4, $arg5, $arg6 
			WriteDebug "$cmd $Params ��� �������� "
			RunCmd $cmd $Params
		}
		If ($PackDir) {
			[Array]$Params = $arg17, $arg1, $arg2, $arg3, $arg4, $arg6 
			WriteDebug "$cmd $Params ��� �������� "
			RunCmd $cmd $Params
		}
		If ($Test) { 
			[Array]$Params = $arg7, $arg8
			WriteDebug "$cmd $Params ��� ������������ "
			$ReturnExitCode = RunCmd $cmd $Params -ReturnExitCode
			If ( $ReturnExitCode -eq 0 ) {Return $True}
			Else {Return $False}
		}
		If ($UnPack) {
			[Array]$Params = $arg9, $arg10, $arg11, $arg12
			WriteDebug "$cmd $Params ��� ���������� "
			RunCmd $cmd $Params
		}
		If ($DelFile) {Remove-Item -path $FilesToArh -force | Out-Null; WriteDebug "Remove-Item -path $FilesToArh -force"}
		If ($DelFilesInPath) {
			get-childitem $FilesToArh | where {
				If ($_.FullName) { 
					Remove-Item -path $_.FullName -force | Out-Null
					WriteDebug "������ $_.FullName"
		}}}
		If ($differential) {
			[Array]$Params = $arg17, $arg13, $arg14, $arg6, $arg2, $arg3, $arg15, $arg16
			WriteDebug "$cmd $Params ��� ���������������� �������� "
			RunCmd $cmd $Params
		}
	}
	Catch { $global:EmailBody += "   ������ ��� ��������� ����� $ArhFile �����������"}
}
