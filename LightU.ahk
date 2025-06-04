; 更新脚本
!+^r::
{
	Run, Ahk2Exe.exe /in D:\Tools\AHKScript\LightC.ahk /icon D:\Tools\AHKScript\banana.ico
	return
}
;感谢来自https://autohotkey.com/board/topic/83100-laptop-screen-brightness/ 提供的亮度控制功能

;下面两行作用为设置图标，现已注释

;SetWorkingDir %A_ScriptDir%	;设置工作路径

;Menu, Tray, Icon, 滚轮控制图标.ico, ,1	;设置图标文件，图标文件不能为英文

;全局变量

; global NextWhellTime := A_TickCount ;上次响应时间初始化为脚本执行时间，提供滚轮加速支持

;提示定时消失

; RemoveToolTip:

; ToolTip

; return

/*

;测试当前指向窗口的ID

+^q::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, , , id,	;获得指针指向窗口的ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

ToolTip, %class%	;以提示方式显示窗口类

Return

;测试某个全局变量值用

+^z::

ToolTip, 你好中文：%NextWhellTime%	;以提示方式显示窗口类

Return

;滚轮渐进增速测试

WheelUp::

IfWinActive, ahk_class Notepad

{

send, a

if (A_TickCount - NextWhellTime < 100)

{

send, b

}

if (A_TickCount - NextWhellTime < 50)

{

send, c

}

if (A_TickCount - NextWhellTime < 20)

{

send, d

}

NextWhellTime := A_TickCount

}

else

{

send, {WheelUp}

}

Return

*/

;滚轮控制音量和亮度

;bate 5	加入亮度调整、加入提示功能

WheelUp::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, xpos, ypos, id,	;获得指针指向窗口的屏幕度坐标和ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

if (ypos < 81)

{

TimeSpan := A_TickCount - NextWhellTime

if (TimeSpan < 100)

{

MoveBRightness(5)

}

else if (TimeSpan < 300)

{

MoveBRightness(3)

}

else

{

MoveBRightness(1)

}

NextWhellTime := A_TickCount ;刷新激活时间

}

else if((class = "Shell_TrayWnd") or (class = "WorkerW"))

{

send, {Volume_Up 1}

if (A_TickCount - NextWhellTime < 200)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 150)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 100)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 50)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 20)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 10)

{

send, {Volume_Up 1}

}

NextWhellTime := A_TickCount ;刷新激活时间

SoundGet, master_volume	;以提示方式显示当前音量

master_volume := Floor(master_volume)

ToolTip, 音量:%master_volume%

SetTimer, RemoveToolTip, -3000

}

else

{

send, {WheelUp}

}



Return



WheelDown::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, xpos, ypos, id,	;获得指针指向窗口的屏幕度坐标和ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

if (ypos < 81)

{

TimeSpan := A_TickCount - NextWhellTime

if (TimeSpan < 100)

{

MoveBRightness(-5)

}

else if (TimeSpan < 300)

{

MoveBRightness(-3)

}

else

{

MoveBRightness(-1)

}

NextWhellTime := A_TickCount ;刷新激活时间

}

else if((class = "Shell_TrayWnd") or (class = "WorkerW"))

{

send, {Volume_Down 1}

if (A_TickCount - NextWhellTime < 200)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 150)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 100)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 50)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 20)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 10)

{

send, {Volume_Down 1}

}

NextWhellTime := A_TickCount ;刷新激活时间

SoundGet, master_volume	;以提示方式显示当前音量

master_volume := Floor(master_volume)

ToolTip, 音量:%master_volume%

SetTimer, RemoveToolTip, -3000

}

else

{

send, {WheelDown}

}



Return



/*

;bate 1	直接进行热键替换

+WheelUp::Volume_Up

+WheelDown::Volume_Down



;bate 2	任务栏激活时有效

WheelUp::

IfWinActive, ahk_class Shell_TrayWnd

{

send, {Volume_Up}

}

else

{

send, {WheelUp}

}

Return

WheelDown::

IfWinActive, ahk_class Shell_TrayWnd

{

send, {Volume_Down}

}

else

{

send, {WheelDown}

}

Return



;bate 3	指针指向任务栏和桌面时有效

WheelUp::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, , , id,	;获得指针指向窗口的ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

if((class = "Shell_TrayWnd") or (class = "WorkerW"))

{

send, {Volume_Up}

}

else

{

send, {WheelUp}

}

Return

WheelDown::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, , , id,	;获得指针指向窗口的ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

if((class = "Shell_TrayWnd") or (class = "WorkerW"))

{

send, {Volume_Down}

}

else

{

send, {WheelDown}

}

Return



;bate 4	滚轮加速检测，滚动越快，调整越快

WheelUp::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, , , id,	;获得指针指向窗口的ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

if((class = "Shell_TrayWnd") or (class = "WorkerW"))

{

send, {Volume_Up 1}

if (A_TickCount - NextWhellTime < 200)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 150)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 100)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 50)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 20)

{

send, {Volume_Up 1}

}

if (A_TickCount - NextWhellTime < 10)

{

send, {Volume_Up 1}

}

NextWhellTime := A_TickCount ;刷新激活时间

}

else

{

send, {WheelUp}

}

Return



WheelDown::

CoordMode,Mouse,Screen	;全局获取模式

MouseGetPos, , , id,	;获得指针指向窗口的ID

WinGetClass, class, ahk_id %id%	;获得窗口ID对应的窗口类

if((class = "Shell_TrayWnd") or (class = "WorkerW"))

{

send, {Volume_Down 1}

if (A_TickCount - NextWhellTime < 200)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 150)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 100)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 50)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 20)

{

send, {Volume_Down 1}

}

if (A_TickCount - NextWhellTime < 10)

{

send, {Volume_Down 1}

}

NextWhellTime := A_TickCount ;刷新激活时间

}

else

{

send, {WheelDown}

}

Return

*/







; MoveBrightness(IndexMove)

; {



; VarSetCapacity(SupportedBRightness, 256, 0)

; VarSetCapacity(SupportedBRightnessSize, 4, 0)

; VarSetCapacity(BRightnessSize, 4, 0)

; VarSetCapacity(BRightness, 3, 0)



; hLCD := DllCall("CreateFile"

; , Str, "\\.\LCD"

; , UInt, 0x80000000 | 0x40000000 ;Read | Write

; , UInt, 0x1 | 0x2  ; File Read | File Write

; , UInt, 0

; , UInt, 0x3        ; open any existing file

; , UInt, 0

; , UInt, 0)



; if hLCD != -1

; {

; DevVideo := 0x00000023, BuffMethod := 0, Fileacces := 0

; NumPut(0x03, BRightness, 0, "UChar")      ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both

; NumPut(0x00, BRightness, 1, "UChar")      ; The AC bRightness level

; NumPut(0x00, BRightness, 2, "UChar")      ; The DC bRightness level

; DllCall("DeviceIoControl"

; , UInt, hLCD

; , UInt, (DevVideo<<16 | 0x126<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS

; , UInt, 0

; , UInt, 0

; , UInt, &Brightness

; , UInt, 3

; , UInt, &BrightnessSize

; , UInt, 0)



; DllCall("DeviceIoControl"

; , UInt, hLCD

; , UInt, (DevVideo<<16 | 0x125<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS

; , UInt, 0

; , UInt, 0

; , UInt, &SupportedBrightness

; , UInt, 256

; , UInt, &SupportedBrightnessSize

; , UInt, 0)



; ACBRightness := NumGet(BRightness, 1, "UChar")

; ACIndex := 0

; DCBRightness := NumGet(BRightness, 2, "UChar")

; DCIndex := 0

; BufferSize := NumGet(SupportedBRightnessSize, 0, "UInt")

; MaxIndex := BufferSize-1



; loop, %BufferSize%

; {

; ThisIndex := A_Index-1

; ThisBRightness := NumGet(SupportedBRightness, ThisIndex, "UChar")

; if ACBRightness = %ThisBRightness%

; ACIndex := ThisIndex

; if DCBRightness = %ThisBRightness%

; DCIndex := ThisIndex

; }



; if DCIndex >= %ACIndex%

; BRightnessIndex := DCIndex

; else

; BRightnessIndex := ACIndex



; BRightnessIndex += IndexMove





; if BRightnessIndex > %MaxIndex%

; BRightnessIndex := MaxIndex



; if BRightnessIndex < 0

; BRightnessIndex := 0



; TempLight := Floor(BRightnessIndex / MaxIndex *100)	;以提示方式显示当前亮度 修改 by shinyship

; CoordMode, ToolTip

; ToolTip, ----------------------------------------------------------------------------------  亮度:%TempLight%  ------------------------------------------------------------------------------------ ,0, 81

; SetTimer, RemoveToolTip, -3000



; NewBRightness := NumGet(SupportedBRightness, BRightnessIndex, "UChar")



; NumPut(0x03, BRightness, 0, "UChar")               ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both

; NumPut(NewBRightness, BRightness, 1, "UChar")      ; The AC bRightness level

; NumPut(NewBRightness, BRightness, 2, "UChar")      ; The DC bRightness level



; DllCall("DeviceIoControl"

; , UInt, hLCD

; , UInt, (DevVideo<<16 | 0x127<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS

; , UInt, &Brightness

; , UInt, 3

; , UInt, 0

; , UInt, 0

; , UInt, 0

; , Uint, 0)



; DllCall("CloseHandle", UInt, hLCD)



; }



; }