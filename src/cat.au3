#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Outfile=..\bin\cat.exe
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Simple Command-line Tool made in AutoIt
#AutoIt3Wrapper_Res_Description=Cat_For_Windows
#AutoIt3Wrapper_Res_Fileversion=1.0.0.2
#AutoIt3Wrapper_Res_ProductName=cat
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.1
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include <Array.au3>
#include <WinAPIConv.au3>
#include <WinAPIProc.au3>
#include <Process.au3>

Opt("MustDeclareVars", 1)

Global $Error = ""
Global $sTempFile = "" ;saves the text of the std-in
Global $ClipBoard = ""
Global $FirstCutOrFirstReverse = -1

Global $ReverseLines = False
Global $CutLines = False
Global $SplitLinesFromTo[2] = []

Global $ReadCreateFile = False
Global $ReadCreateFileName[0] = []
Global $FromFile[0] = []

Global $FileCount = 0
Global $FileLineMaxLength = 0
Global $FileMaxLength = 0
Global $ParamList[17][3] =  [["-n", "--number", "number all output lines"], _
							["-e", "--show-ends", "display $ at end of each line"], _
							["-t", "--show-tabs", "display TAB characters as ^I"], _
							["-s", "--squeeze-blank", "suppress repeated output lines"], _
							["-r", "--reverse", "reverse output"], _
							["-c", "--count", "show sum of lines"], _
							["-b", "--hide-blank", "hide empty lines"], _
							["-o", "--oem-encoding", "read/write in oem-text-encoding"], _
							["-f", "--files", "list applied files"], _
							["-h", "--help", "display this help and exit"], _
							["-v", "--version", "output version information and exit"], _
							["-d", "--debug", "show debug information"], _
							["-i", "--interactive", "use stdin"], _
							["-l", "--clip", "copy output to clipboard"], _
							["--dec", "--dec", "convert decimal number to hexadecimal and binary"], _
							["--hex", "--hex", "convert hexadecimal number to decimal and binary"], _
							["--bin", "--bin", "convert binary number to decimal and hexadecimal"]]
Global $ParamUsage[Ubound($ParamList)]
For $i = 0 To Ubound($ParamUsage)-1
    $ParamUsage[$i] = False
Next

If not _SetSettings() Then _ShowErrorAndExit()
If $ParamUsage[12] Then _CheckForStdIn()

_RunMain()

Func _RunMain()
	If $ParamUsage[11] Then ;--debug
		_Debug()
	EndIf
	If $ParamUsage[9] Then ;--help
		_ShowHelp()
	ElseIf $ParamUsage[10] Then ;--version
		_ShowVersion()
	Else
		If $ReadCreateFile Then
			If $ParamUsage[12] Then ;--interactive
				_WriteFromStdIn()
			Else
				_ReadWriteFromStdIn()
			EndIf
		EndIf
		If $ParamUsage[4] Then $FileCount = _GetFileLinesSum()
		$FileLineMaxLength = _GetFileLineMaxLength()
		$FileMaxLength = _GetFileMaxLength()
		Local $iStart = 0
		Local $iEnd = Ubound($FromFile)-1

		For $i = ($ParamUsage[4] ? $iEnd : $iStart) To ($ParamUsage[4] ? $iStart : $iEnd) Step ($ParamUsage[4] ? -1 : 1)
			_PrintFile($FromFile[$i], $i == ($ParamUsage[4] ? $iStart : $iEnd), $i+1)
		Next
	EndIf
	If $ParamUsage[12] and FileExists($sTempFile) Then FileDelete($sTempFile) ;cleanup tempfile
EndFunc

Func _SetSettings()
	If $CMDLine[0] == 0 and $ParamUsage[12] == False Then ;execute a CMD if executable is not started from within one
		If _ProcessGetName(_WinAPI_GetParentProcess()) <> StringTrimLeft(@ComSpec, StringInStr(@ComSpec, "\", 0, -1)) Then
			ShellExecute(@ComSpec, '/k echo Usage: cat [FILE]... [OPTIONS]...')
			Return False
		EndIf
		$Error = "Not enough parameters!"
		Return False
	EndIf
	For $i = 1 To $CMDLine[0]
		If not _AddSetting($CMDLine[$i]) Then Return False
	Next
	Return True
EndFunc

Func _AddSetting($hParam)
	If StringRegExp($hParam, "^\[.{2,}\]$") Then ;check for [::-1] or [x:y]
		$hParam = StringTrimLeft(StringTrimRight($hParam, 1), 1)
		If $hParam == "::-1" Then
			$ReverseLines = True
			If $FirstCutOrFirstReverse == -1 Then $FirstCutOrFirstReverse = 0
		EndIf
		$hParam = StringSplit($hParam, ":")
		If $hParam[0] == 2 Then
			$CutLines = True
			If $FirstCutOrFirstReverse == -1 Then $FirstCutOrFirstReverse = 1
			$SplitLinesFromTo[0] = ($hParam[1] = "" ? 1 : $hParam[1])
			If $SplitLinesFromTo[0] <= 0 Then $SplitLinesFromTo[0] = 1
			$SplitLinesFromTo[1] = ($hParam[2] = "" ? -1+$SplitLinesFromTo[0] : $hParam[2])
		EndIf
		Return True
	EndIf

    For $i = 0 To Ubound($ParamList) -1
        If $hParam == $ParamList[$i][0] or $hParam == $ParamList[$i][1] Then 
            $ParamUsage[$i] = True
            Return True
        EndIf
    Next

    Local $sFile = _PathFull($hParam) ;if $hParam is not a known param, check if it is a file
    If StringRegExp($hParam, "\*") Then ;if it contains a "*", use all files that match that pattern
        Local $sFilterFilesArray = _FileListToArray(@WorkingDir, $hParam, 1, True)
        If not @error Then
            For $i = 1 To $sFilterFilesArray[0]
                _AddFileFrom($sFilterFilesArray[$i])
            Next
        EndIf
    ElseIf not _IsDirectory($sFile) Then ;if it is not a directory
        If FileExists($sFile) Then
            _AddFileFrom($sFile)
        ElseIf StringLeft($hParam, 1) == "-" and StringLen($hParam) > 2 Then ;if the $hParam concatenates multiple known params
            For $i = 2 To StringLen($hParam)
                If not _AddSetting("-" & StringMid($hParam, $i, 1)) Then Return False ;recursively check the params
            Next
        ElseIf StringRegExp($hParam, "\A[^-]+\Z") Then ; anything(1ormore) between start and end of string
            _AddFileReadCreate($sFile) ;unknown file we can write
        Else
            $Error = "The element '" & $hParam & "' is not supported!"
            Return False
        EndIf
    Else
        $Error = "'" & $hParam & "' is an existing directory!"
        Return False
    EndIf
	Return True
EndFunc

Func _AddFileFrom($sFile)
	Local $WriteTo = Ubound($FromFile)
	ReDim $FromFile[$WriteTo +1]
	$FromFile[$WriteTo] = $sFile
EndFunc

Func _AddFileReadCreate($sFile)
	$ReadCreateFile = True

	Local $WriteTo = Ubound($ReadCreateFileName)
	ReDim $ReadCreateFileName[$WriteTo +1]
	$ReadCreateFileName[$WriteTo] = $sFile
EndFunc

Func _PrintFile($aFile, $LastFile = False, $fileIndex = 1)
	Local $fFile = FileOpen($aFile, 0)
	Local $fContent = FileReadToArray($fFile)
	Local $fLength = @extended
	Local $iDecimal, $fLineTrimWhitespaces, $iLine
	If $ParamUsage[4] Then _ArrayReverse($fContent)
	For $i = 0 To $fLength-1
		$iLine = $fContent[$i]
		$fLineTrimWhitespaces = StringStripWS($iLine, 3)
		If $ParamUsage[14] and StringIsDigit($fLineTrimWhitespaces) Then
			$iLine &= " {Hexadecimal: " & _DecimalToHex($fLineTrimWhitespaces) & "; Binary: " & _DecimalToBinary($fLineTrimWhitespaces) & "}"
		EndIf
		If $ParamUsage[15] Then
			$iDecimal = _HexToDecimal($fLineTrimWhitespaces)
			$iLine &= " {Decimal: " & $iDecimal & "; Binary: " & _DecimalToBinary($iDecimal) & "}"
		EndIf
		If $ParamUsage[16] and StringIsDigit($fLineTrimWhitespaces) Then
			$iDecimal = _BinaryToDecimal($fLineTrimWhitespaces)
			$iLine &= " {Decimal: " & $iDecimal & "; Hexadecimal: " & _DecimalToHex($iDecimal) & "}"
		EndIf
		If $ParamUsage[6] and $iLine == "" Then ContinueLoop
		If $ParamUsage[3] and $i > 0 and $iLine == $fContent[$i-1] Then ContinueLoop
		If $ParamUsage[1] Then $iLine = $iLine & "$"

		If $FirstCutOrFirstReverse == 0 Then
			If $ReverseLines Then $iLine = StringReverse($iLine)
			If $CutLines Then
				$iLine = StringMid($iLine, $SplitLinesFromTo[0], $SplitLinesFromTo[1] - $SplitLinesFromTo[0])
			EndIf
		ElseIf $FirstCutOrFirstReverse == 1 Then
			If $CutLines Then
				$iLine = StringMid($iLine, $SplitLinesFromTo[0], $SplitLinesFromTo[1] - $SplitLinesFromTo[0])
			EndIf
			If $ReverseLines Then $iLine = StringReverse($iLine)
		EndIf

		If $ParamUsage[2] Then $iLine = StringReplace($iLine, @TAB, "^I")

		If $ParamUsage[0] Then _COut(_GetLineNumberPrefix($fileIndex, ($ParamUsage[4] ? ($FileCount-$i) : ($FileCount+($i+1)))))
		_COut($iLine)
		_COut(@LF)
	Next
	$FileCount += $ParamUsage[4] ? -$fLength : $fLength
	If $LastFile Then
		If $ParamUsage[5] or $ParamUsage[8] Then _COut(@LF & "------------------------------------------------------------" & @LF)
		If $ParamUsage[5] Then
			$FileCount = $ParamUsage[4] ? _GetFileLinesSum() : $FileCount
			_COut("Lines: " & $FileCount & @LF)
		EndIf
		If $ParamUsage[8] Then
			_COut("applied FILE(s):" & @LF)
			For $i = 0 To Ubound($FromFile)-1
				_COut(@TAB & $FromFile[$i] & @LF)
			Next
			_COut(@LF)
		EndIf
		If $ParamUsage[13] Then ClipPut($ClipBoard)
	EndIf
EndFunc

Func _GetLineNumberPrefix($fIndex, $fLine)
	Local $LineNumberPrefix = $fLine & ") "
	For $i = StringLen($fLine) To $FileLineMaxLength-1
		$LineNumberPrefix &= " "
	Next

	Local $fFilePrefix = ""
	If Ubound($FromFile) > 1 Then
		$fFilePrefix &= $fIndex
		For $i = StringLen($fIndex) To $FileMaxLength-1
			$fFilePrefix &= " "
		Next
		$fFilePrefix &= "."
	EndIf

	Return $fFilePrefix & $LineNumberPrefix
EndFunc

Func _GetFileLinesSum()
	Local $lines = 0
	Local $fFile, $fContent
	For $i = 0 To Ubound($FromFile) -1
		$fFile = FileOpen($FromFile[$i], 0)
		$fContent = FileReadToArray($fFile)
		$lines += @extended
		FileClose($fFile)
	Next

	Return $lines
EndFunc

Func _GetFileLineMaxLength()
	Local $lineSum = $ParamUsage[4] ? $FileCount : _GetFileLinesSum()
	Return StringLen($lineSum)
EndFunc

Func _GetFileMaxLength()
	Return StringLen(Ubound($FromFile))
EndFunc

Func _ShowHelp()
	_COut("Usage: cat [FILE]... [OPTIONS]..." & @LF)
	_COut("Concatenate FILE(s) to standard output" & @LF)
	_COut(@LF)
	For $i = 0 To Ubound($ParamList) -1
		_PrintHelpIntendation(@TAB & $ParamList[$i][0] & ", " & $ParamList[$i][1])
		_COut($ParamList[$i][2] & @LF)
	Next
	_COut(@LF)
	_PrintHelpIntendation(@TAB & "[::-1]:")
	_COut("reverse every line" & @LF)
	_PrintHelpIntendation(@TAB & "[x:y]:")
	_COut("split every line from x to y" & @LF)
	_PrintHelpIntendation(@TAB & "[x:]:")
	_COut("split every line from x to line end" & @LF)
	_PrintHelpIntendation(@TAB & "[:y]:")
	_COut("split every line from line start to y" & @LF)
	_COut(@LF)
	_COut("Examples:" & @LF)
	_PrintHelpIntendation(@TAB & "cat f g -r")
	_Cout("Output g's contents in reverse order, then f's content in reverse order" & @LF)
	_PrintHelpIntendation(@TAB & "cat f g -ne")
	_COut("Output f's, then g's content, while numerating and showing the end of lines." & @LF)
	_COut(@LF)
EndFunc

Func _PrintHelpIntendation($c)
	_Cout(StringFormat("%-25s", $c))
EndFunc

Func _ShowVersion()
	Local $VersionString = ""
	Local $AutoItX = "x86"
	If @AutoItX64 Then $AutoItX = "x64"
	$VersionString &= (@LF)
	$VersionString &= ("------------------------------------------------------------" & @LF)
	$VersionString &= ("Cat " & _ProductVersion() & @LF)
	$VersionString &= ("------------------------------------------------------------" & @LF)
	$VersionString &= (@LF)
	$VersionString &= ("AutoIt:" & @TAB & @TAB & @AutoItVersion & " " & $AutoItX & @LF)
	$VersionString &= ("Build time:" & @TAB & _BuildTime() & @LF)
	$VersionString &= ("Author:" & @TAB & @TAB & "Silas A. Kraume" & @LF)
	$VersionString &= (@LF)

	_COut($VersionString)
EndFunc

Func _ProductVersion()
	Local $fVersion = FileGetVersion(@ScriptFullPath, "FileVersion")
	If @error or $fVersion = "" Then Return "/"
	Return $fVersion
EndFunc

Func _BuildTime()
	Local $fTime = FileGetTime(@ScriptFullPath, 1, 0)
	If @error Then Return "/"
	Local $sString = $fTime[0] & "-" & $fTime[1] & "-" & $fTime[2] & " " & $fTime[3] & ":" & $fTime[4] & ":" & $fTime[5] & " CET"
	Return $sString
EndFunc

Func _WriteFromStdIn()
	Local $fOpen
	Local $sOutput = FileRead($sTempFile)
	For $i = 0 To Ubound($ReadCreateFileName)-1
		$fOpen = FileOpen($ReadCreateFileName[$i], 10)
		FileWrite($fOpen, $sOutput)
		FileClose($fOpen)
	Next
EndFunc

Func _ReadWriteFromStdIn() ;write all unknown files
	_COut("The given FILE(s):" & @LF)
	For $i = 0 To Ubound($ReadCreateFileName)-1
		_COut(@TAB & $ReadCreateFileName[$i] & @LF)
	Next
	_COut("do/does not exist. Write the FILE(s) and finish with the '^Z'-suffix ((Ctrl + Z) + Enter):" & @LF)
	Local $sOutput
	Do
		Sleep(25)
		$sOutput &= ConsoleRead()
	Until @error ;eof char
	If StringRight($sOutput, 1) == @LF Then $sOutput = StringTrimRight($sOutput, 2) ;delete new line at the end
	If AscW(StringRight($sOutput, 1)) == 26 Then $sOutput = StringTrimRight($sOutput, 1) ;delete '^Z' at the end
	If $sOutput == "" Then Return
	If $ParamUsage[7] Then $sOutput = _WinAPI_MultiByteToWideChar($sOutput, 1, 0, True)
	For $i = 0 To UBound($ReadCreateFileName)-1
		Local $fOpen = FileOpen($ReadCreateFileName[$i], 10)
		FileWrite($fOpen, $sOutput)
		FileClose($fOpen)
		_AddFileFrom($ReadCreateFileName[$i])
	Next
EndFunc

Func _ShowErrorAndExit()
	_COut("Error: " & $Error & @LF)
	_COut("For more information use 'cat -h' or 'cat --help'." & @LF)
	Exit
EndFunc

Func _Debug()
	_COut("Debug Information:" & @LF)
	_COut("RawCMDLine: " & $CMDLineRaw & @LF)
	_COut(@LF)
	_COut("known FILE(s):" & @LF)
	For $i = 0 To Ubound($FromFile)-1
		_COut(@TAB & $FromFile[$i] & @LF)
	Next
	_COut(@LF)
	_COut("unknown FILE(s):" & @LF)
	For $i = 0 To Ubound($ReadCreateFileName)-1
		_COut(@TAB & $ReadCreateFileName[$i] & @LF)
	Next
	_COut("=> ($ReadCreateFile): " & $ReadCreateFile & @LF)
	_COut(@LF)
	For $i = 0 To Ubound($ParamList)-1
		_COut($ParamList[$i][0] & ", " & $ParamList[$i][1] & ": " & $ParamUsage[$i] & @LF)
	Next
	_COut("($ReverseLines): " & $ReverseLines & @LF)
	_COut("($CutLines): " & $CutLines & @LF)
	_COut("($SplitLinesFromTo[0]): " & $SplitLinesFromTo[0] & @LF)
	_COut("($SplitLinesFromTo[1]): " & $SplitLinesFromTo[1] & @LF)
	_COut(@LF)
	_COut("Sum of lines from all FILE(s): " & _GetFileLinesSum() & @LF)
	_COut("String length of linesum: " & _GetFileLineMaxLength() & @LF)
	_COut("String length of file amount: " & _GetFileMaxLength() & @LF)
	_COut("------------------------------------------------------------" & @LF)
EndFunc

Func _CheckForStdIn()
	Local $StdInput = ""
	Do
		Sleep(25)
        $StdInput &= ConsoleRead()
    Until @error
	If StringRight($StdInput, 1) == @LF Then $StdInput = StringTrimRight($StdInput, 1) ;delete new line at the end
	If AscW(StringRight($StdInput, 1)) == 26 Then $StdInput = StringTrimRight($StdInput, 1) ;delete '^Z' at the end
	If $StdInput <> "" Then
		$sTempFile = _TempFile()
		FileWrite($sTempFile, $StdInput)
		_AddFileFrom($sTempFile)
	EndIf
EndFunc

Func _COut($c)
	If $ParamUsage[7] Then $c = _WinAPI_WideCharToMultiByte($c, 1, True, False)
	ConsoleWrite($c)
	If $ParamUsage[13] Then $ClipBoard &= $c
EndFunc

Func _IsDirectory($s_file)
    Return StringInStr(FileGetAttrib($s_file), "D")
EndFunc

Func _DecimalToHex($iNumber)
	If not IsNumber($iNumber) Then $iNumber = Number($iNumber)
	$iNumber = Int($iNumber)
	Return Hex($iNumber)
EndFunc

Func _DecimalToBinary($iNumber)
	If not IsNumber($iNumber) Then $iNumber = Number($iNumber)
	$iNumber = Int($iNumber)
    Local $sBinString = ""
    Do
        $sBinString = BitAND($iNumber, 1) & $sBinString
        $iNumber = BitShift($iNumber, 1)
    Until $iNumber <= 0
    If $iNumber < 0 Then SetError(1, 0, 0)
    Return $sBinString
EndFunc

Func _HexToDecimal($iNumber)
	Return Dec($iNumber)
EndFunc

Func _BinaryToDecimal($iNumber)
  Local $iDecimal = 0
  For $i = 0 To StringLen($iNumber) Step 1
    $iDecimal = $iDecimal + Number(StringMid($iNumber, StringLen($iNumber)-$i, 1))*(2^$i)
  Next
  Return $iDecimal
EndFunc