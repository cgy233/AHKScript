#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe deadcells.exe") ;熱鍵在[死亡細胞]才會生效
SetKeyDelay -1 ;發送鍵擊後無延遲
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

; 回退
Right::
{
    steps := [
        ["esc",   100],
        ["left",  100],
        ["enter", 100],
        ["space", 500],
        ["down",  100],
        ["down",  100],
        ["enter", 100],
        ["right", 100],
        ["x",     100],
        ["left",  100],
        ["enter", 100],
        ["space", 100],
        ["esc",   100],
        ["enter", 100],
        ["enter", 0]
    ]
    sendSteps(steps)
}

; 存档
Left::
{
    steps := [
        ["esc",   100],
        ["left",  100],
        ["enter", 100],
        ["space", 500],
        ["down",  100],
        ["down",  100],
        ["enter", 100],
        ["x",     100],
        ["right", 100],
        ["enter", 100],
        ["space", 100],
        ["esc",   100],
        ["enter", 100],
        ["enter", 0]
    ]
    sendSteps(steps)
}
