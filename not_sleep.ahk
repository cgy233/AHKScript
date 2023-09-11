#SingleInstance, Force  ; 确保脚本只运行一个实例

; 禁止休眠脚本
; 作者：ChatGPT

#Persistent  ; 保持脚本持续运行

; 设置初始的时间间隔为120000毫秒（2分钟）
interval := 120000
; interval := 5000
SetTimer, PreventSleep, %interval%
return

PreventSleep:
	; 模拟NumLock按键事件
	SetNumLockState, On
	SetNumLockState, Off

	; 根据需要调整时间间隔，这里将时间间隔修改为300000毫秒（5分钟）
	; interval := 300000
	SetTimer, PreventSleep, %interval%

	; 在右下角显示消息提示
	; TrayTip, Don't Sleep!, GOGOGO, ,0x11
return
