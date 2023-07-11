#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

devices := ["耳机", "音箱"]
net_devices := ["192.168.2.2", "192.168.2.3"]
logo := 0x1
voice := 0x10
cur := 0
choice := 0

#!i::
	HideTrayTip()
	cur := Mod(cur + 1, devices.Length())
	option := logo+voice
	ChangeDevice(devices[cur+1], option)
	return
ChangeDevice(device, option) {
	TrayTip, %device%, 播放设备, , %option%
	Run, nircmd.exe setdefaultsounddevice %device%
	SetTimer, HideTrayTip, 1300
}
HideTrayTip() {
	TrayTip
}
#!a::
	TrayTip, It's Apex time !!!, GOGOGO, ,0x12
	Run, C:\Users\Ethan\Desktop\AHK.lnk
	SetTimer, HideTrayTip, 1000
	return
#!s::
	{
		choice := Mod(choice + 1, net_devices.Length())
		gateway := net_devices[choice + 1]
		If (gateway > "192.168.2.2")
			dns := "223.5.5.5"
		Else
			dns := "192.168.2.2"
		Run, *RunAs %ComSpec% /c netsh interface ip set address name="以太网" source=static addr=192.168.2.23 mask=255.255.255.0 gateway=%gateway%,,hide
		Run, *RunAs %ComSpec% /c netsh interface ip set dns name="以太网" source=static addr=%dns%,,hide
		return
	}

; 屏蔽全角
+Space::Send, {Space}
#!l::Run, https://www.bilibili.com
#!z::Run, https://www.zhihu.com
#!v::Run, https://www.v2ex.com
#!f::Run, https://jable.tv/hot/