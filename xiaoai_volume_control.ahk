#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; 初始化音量数组和索引
global volumeLevels := [10, 25, 50, 75, 100]
global volumeIndex := 2 ; 初始索引，对应音量50

; 监听 Win+Alt+Up 和 Win+Alt+Down 组合键
#!Up:: ; Win+Alt+Up
	IncreaseVolume()
return

#!Down:: ; Win+Alt+Down
	DecreaseVolume()
return

; 增加音量的函数
IncreaseVolume() {
	if (volumeIndex < 5) {
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