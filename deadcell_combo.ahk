#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe deadcells.exe") ;熱鍵在[死亡細胞]才會生效
SetKeyDelay -1 ;發送鍵擊後無延遲
WheelUp::   ; A+居合斬(滑鼠上滾輪)
{
Send "{1 down}" ;主武器(按下)
sleep 30 ;等待30毫秒
Send "{1 up}" ;主武器(鬆開)
sleep 200
Send "{1 down}" ;主武器(按下)
sleep 1
Send "{space down}" ;跳躍(按下)
sleep 1
Send "{ctrl down}" ;翻滾(按下)
sleep 300
Send "{1 up}{space up}{ctrl up}" ;主武器,跳躍,翻滾(鬆開)
}
WheelDown::  ; A+突擊斬(滑鼠下滾輪)
{
Send "{1 down}" ;主武器(按下)
sleep 30
Send "{1 up}" ;主武器(鬆開)
sleep 200
Send "{1 down}{2 down}" ;主武器,副武器(按下)
sleep 1
Send "{space down}" ;跳躍(按下)
sleep 1
Send "{ctrl down}" ;翻滾(按下)
sleep 300
Send "{1 up}{2 up}{space up}{ctrl up}" ;主武器,副武器,跳躍,翻滾(鬆開)
}
XButton1::   ; A+位移+居合斬(滑鼠側鍵4)
{
Send "{1 down}" ;主武器(按下)
sleep 30
Send "{1 up}" ;主武器(鬆開)
sleep 200
Send "{e down}" ;右技能(按下)
sleep 1
Send "{1 down}" ;主武器(按下)
sleep 100
Send "{ctrl down}" ;翻滾(按下)
sleep 300
Send "{1 up}{ctrl up}{e up}" ;主武器,翻滾,右技能(鬆開)
}
XButton2::   ; A+位移+突擊斬(滑鼠側鍵5)
{
Send "{1 down}" ;主武器(按下)
sleep 30
Send "{1 up}" ;主武器(鬆開)
sleep 200
Send "{e down}" ;右技能(按下)
sleep 1
Send "{1 down}{2 down}" ;主武器,副武器(按下)
sleep 100
Send "{ctrl down}" ;翻滾(按下)
sleep 300
Send "{1 up}{2 up}{ctrl up}{e up}" ;主武器,副武器,翻滾,右技能(鬆開)
}
#HotIf ;關閉熱鍵的上下文相關性
F3::Reload ;重啟腳本
F4::exitapp ;關閉腳本
