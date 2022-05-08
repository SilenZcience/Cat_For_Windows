Func _DecimalToHex($iNumber)
	If not IsNumber($iNumber) Then $iNumber = Number($iNumber)
    Local $ihex = ""
    Do
        $ihex = Hex(Mod($iNumber, 16), 1) & $ihex
        $iNumber = Floor($iNumber / 16)
    Until $iNumber = 0
    Return $ihex
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
    Local $aN, $ihex = 0
	If StringLeft($iNumber, 2) == "0x" Then $iNumber = StringTrimLeft($iNumber, 2)
    $aN = StringSplit($iNumber, "", 1)
    For $x = 1 To UBound($aN) - 1
        $ihex += Dec($aN[$x]) * (16 ^ (UBound($aN) - 1 - $x))
    Next
    Return $ihex
EndFunc

Func _BinaryToDecimal($iNumber)
  Local $iDecimal = 0
  For $i = 0 To StringLen($iNumber) Step 1
    $iDecimal = $iDecimal + Number(StringMid($iNumber, StringLen($iNumber)-$i, 1))*(2^$i)
  Next
  Return $iDecimal
EndFunc