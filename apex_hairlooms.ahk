#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

^!d::
	Send {ESC}
	Sleep 200
	Send {R}
	Sleep 100
	Send {Click 845 718}
	Sleep 100
	Send {Click 845 718}
	Sleep 100
	Send {Click 845 718}
	Sleep 100
	Send {Click 845 718}
