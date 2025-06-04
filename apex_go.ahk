#SingleInstance, Force

global nnPID := 0
global nnPath := "D:\Program\nn\nn.exe"
global nnTitle := "NN"
global kookPID := 0
global kookPath := "D:\Program\KOOK\KOOK.exe"
global kookTitle := "KOOK"
global toolPath := "C:\Users\Ethan\Desktop\AHK.lnk"

CheckWindowAndStartApp(ByRef pid, appPath, windowTitle)
{
    IfWinExist, %windowTitle%
    {
        WinGet, pid, PID
		WinActivate ahk_pid %pid%
    }
    else
    {
        Run, %appPath%
        Sleep, 6000
    }
}

AccelerateGame()
{
    CheckWindowAndStartApp(nnPID, nnPath, nnTitle)

    If (nnPID > 0)
    {
        WinActivate ahk_pid %nnPID%
    }

	Sleep, 500
	click 53, 714
	Sleep, 1000
	click 1956, 1355
	Sleep, 8000
	click 1956, 1355

}

JoinKookChannel()
{
    ; CheckWindowAndStartApp(kookPID, kookPath, kookTitle)
	Run, %kookPath%
	Sleep, 6000

    IfWinExist, %kookPath%
    {
        WinGet, kookPID, PID
		WinActivate ahk_pid %kookPID%
    }

    ; If (kookPID > 0)
    ; {
    ;     WinActivate ahk_pid %kookPID%
    ; }

	Sleep, 500
	Click 72, 376
	Sleep, 1000
	Click 264, 744
	Sleep, 20
	Click 264, 744
	

}

^!d::
{
	Run, %toolPath%

	; JoinKookChannel()

	AccelerateGame()

}
