#Requires AutoHotkey v2.0
; #HotIf WinActive("ahk_exe hollow_knight.exe")
SetKeyDelay -1
#SingleInstance Force

; 封装步骤发送函数
sendSteps(steps) {
    for step in steps
    {
        key := step[1]
        delay := step[2]
        Send "{" key " down}"
        Sleep 100
        Send "{" key " up}"
        if (delay > 0)
            Sleep delay
    }
}

; 椅子大法
Right::
{
    steps := [
        ["esc",   300],
        ["down",  200],
        ["down",  200],
        ["enter", 800],
        ["down",  500],
        ["enter", 3500],
        ["enter", 2000],
        ["up",  200],
        ["up",  200],
        ["enter", 0]
    ]
    sendSteps(steps)
}
