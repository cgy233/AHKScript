#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe deadcells.exe") ;熱鍵在[死亡細胞]才會生效
SetKeyDelay -1 ;發送鍵擊後無延遲
#SingleInstance Force

F9::
{
    steps := [
        ["esc",   300],
        ["left",  300],
        ["enter", 300],
        ["space", 1000],
        ["down",  500],
        ["down",  500],
        ["enter", 500],
        ["right", 500],
        ["x",     300],
        ["left",  300],
        ["enter", 300],
        ["space", 500],
        ["esc",   500],
        ["enter", 300],
        ["enter", 0]
    ]

    for step in steps
    {
        key := step[1]
        delay := step[2]

        Send "{" key " down}"
        Sleep 50
        Send "{" key " up}"

        if (delay > 0)
            Sleep delay
    }
}

F10::
{
    steps := [
        ["esc",   300],
        ["left",  300],
        ["enter", 300],
        ["space", 1000],
        ["down",  500],
        ["down",  500],
        ["enter", 500],
        ["x",     300],
        ["right", 500],
        ["enter", 300],
        ["space", 500],
        ["esc",   500],
        ["enter", 300],
        ["enter", 0]
    ]

    for step in steps
    {
        key := step[1]
        delay := step[2]

        Send "{" key " down}"
        Sleep 50
        Send "{" key " up}"

        if (delay > 0)
            Sleep delay
    }
}
