#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

devices := ["耳机", "音箱"]

; 0: home 1:work
net_type := 1

net_home_addr := "192.168.2.23"
net_home_dns := "223.5.5.5"
net_home_gateways := ["192.168.2.2", "192.168.2.3"]

net_work_addr := "192.168.3.180"
net_work_dns := "192.168.3.166"
net_work_gateways := ["192.168.3.254", "192.168.3.78"]

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
	SetTimer, HideTrayTip, 1300
}
#!a::
	TrayTip, It's Apex time !!!, GOGOGO, ,0x12
	Run, C:\Users\Ethan\Desktop\AHK.lnk
	SetTimer, HideTrayTip, 1000
	return
#!s::
	{
		If (net_type)
		{
			net_devices := net_work_gateways
			dns := net_work_dns
			addr := net_work_addr
		}
		Else
		{
			net_devices := net_home_gateways
			dns := net_home_dns
			addr := net_home_addr
		}
		choice := Mod(choice + 1, net_devices.Length())
		gateway := net_devices[choice + 1]
		Run, *RunAs %ComSpec% /c netsh interface ip set address name="以太网" source=static addr=%addr% mask=255.255.255.0 gateway=%gateway%,,hide
		Run, *RunAs %ComSpec% /c netsh interface ip set dns name="以太网" source=static addr=%dns%,,hide
		return
	}

; 屏蔽全角
+Space::Send, {Space}
#!l::Run, https://www.bilibili.com
#!z::Run, https://www.zhihu.com
#!v::Run, https://www.v2ex.com