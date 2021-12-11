Graphics 1920, 1080, 32, 2

Dim energyMap (9, 9)
global numFlashes = 0

ReadInput()

print "Steps needed = " + Part2()

Function Part1()
	for i = 1 to 100
		Print("----- After step: " + i + " ---")
		SimulateStep()
		REnderMap()
		Print("~> used " + numFlashes + " flashes")
	next
End Function

Function Part2()
	afterStep = 0
	repeat
		SimulateStep()
		afterStep = afterStep + 1
		if(CheckSync())
			return afterStep
		endif
	forever
End Function

Function CheckSync()
	For y = 0 To 9
		For x = 0 To 9
			if(energyMap(x, y) <> 0)
				return false
			endif
		Next
	Next
	Return true
End Function

Function SimulateStep()
	IncreaseAllBy1()
    StartFlashing()
End Function

Function StartFlashing()
    For y = 0 To 9
		For x = 0 To 9
			if ShouldExplode(x, y)
				Flash(x, y)
			endif
		Next
	Next
End Function

Function ShouldExplode(x, y)
	return energyMap(x, y) >= 10
End Function

Function Flash(x, y)
	if energyMap(x, y) = 0
		; has flashed already here
		return
	endif

	; mark as flashed
	energyMap(x, y) = 0
	numFlashes = numFlashes + 1

	for xOffset = -1 to 1
		for yOffset = -1 to 1
			posX = x + xOffset
			posY = y + yOffset

			if (posX >= 0 and posY >= 0 and posX < 10 and posY < 10)
				IncreaseAt(posX, posY)
			endif
		next
	next
End Function

Function IncreaseAt(x, y)
	if energyMap(x, y) = 0
		; has flashed already here
		return
	endif

	energyMap(x, y) = energyMap(x, y) + 1
	
	if(ShouldExplode(x, y))
		Flash(x, y)
	endif
End Function

Function IncreaseAllBy1()
	For y = 0 To 9
		For x = 0 To 9
			energyMap(x,y) = energyMap(x,y) + 1
		Next
	Next
End Function

Function RenderMap()
	For y = 0 To 9
		Line$ = ""
		For x = 0 To 9
			Line$ = Line$ + Str(energyMap(x,y)) + " "
		Next
		Print(Line$)
	Next
End Function

Function ReadInput()
	fileHandle = ReadFile("input.txt")
	For i = 0 To 9
		Line$ = ReadLine(fileHandle)
		For ii = 0 To 9
			energyMap(ii,i) = Asc(Mid(Line$, ii + 1, 1))-48
		Next
	Next
	CloseFile(fileHandle)
End Function


