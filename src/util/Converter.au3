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