#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; ************************************************** 音量控制 **************************************************

; 初始化音量数组和索引
global volumeLevelsCount := 6
global volumeLevels := [30, 50, 70, 79, 100]
global volumeIndex := 3 ; 初始索引，对应音量50

; ************************************************** 输出设备切换 **************************************************
devices := ["耳机", "扬声器"]

logo := 0x1
voice := 0x10
cur := 0
choice := 0

ShowTip(title, msg, timeout) {
	HideTrayTip()

}

HideTrayTip() {
	TrayTip
}

#!i::
	cur := Mod(cur + 1, devices.Length())
	option := logo+voice
	ChangeDevice(devices[cur+1], option)
	return
ChangeDevice(device, option) {
	TrayTip, %device%, 播放设备, , %option%
	Run, nircmd.exe setdefaultsounddevice %device%
	SetTimer, HideTrayTip, 1000
}
; 屏蔽全角
; +Space::Send, {Space}
#!l::Run, https://www.bilibili.com
#!v::Run, https://www.v2ex.com
#!f::Run, https://jable.tv/hot/
#!a::Run, https://chat.openai.com
#!s::Run, https://grok.com
#!d::Run, https://chat.deepseek.com
#!p::Send, lArocheposay@233..

; VIM
!k::Send {Up}
!j::Send {Down}
!h::Send {Left}
!l::Send {Right}

; Media 
; next music
!Right:: Send {Media_Next}
!Left:: Send {Media_Prev}
!WheelUp:: Send {Volume_Up}
!WheelDown:: Send {Volume_Down}

; ************************************************** 小爱音箱音量控制 **************************************************

; 监听 Win+Alt+Up 和 Win+Alt+Down 组合键
#!Up:: ; Win+Alt+Up
	IncreaseVolume()
return

#!Down:: ; Win+Alt+Down
	DecreaseVolume()
return

; 增加音量的函数
IncreaseVolume() {
	if (volumeIndex < (volumeLevelsCount - 1)) {
		volumeIndex := volumeIndex + 1
	}
	SendMqttMessage()
}

; 减少音量的函数
DecreaseVolume() {
	if (volumeIndex > 1) {
		volumeIndex := volumeIndex - 1
	}
	SendMqttMessage()
}

; 发送 MQTT 消息的函数
SendMqttMessage() {
	value := volumeLevels[volumeIndex]
	; 构建 Python 命令
	pythonCommand := "python -u D:\Tools\AHKScript\xiaoai_volume_control.py " . value

	; 调用 Python 脚本发送 MQTT 消息
	Run, %pythonCommand%, , Hide

	; 显示当前音量提示
	ShowToolTip(value)
}

; 显示提示的函数
ShowToolTip(value) {
	ToolTip, volume: %value%
	SetTimer, RemoveToolTip, 1000 ; 1秒后移除提示
}

; 移除提示的函数
RemoveToolTip() {
	ToolTip
}
