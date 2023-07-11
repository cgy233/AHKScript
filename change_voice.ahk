#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force

; 填写你的音频设备名称
devices := ["耳机", "音箱"]
; 设置提醒图标。0x0（无图标），0x1（信息图标），0x2（警告图标），0x3（错误图标）
logo := 0x1
; 设置切换提示声。0x0（有提示声），0x10（无提示声）
voice := 0x10

cur := 0
; Menu Tray, NoIcon
ChangeDevice(devices[cur+1], logo+voice)


RAlt & p::
    cur := Mod(cur + 1, devices.Length())
    option := logo+voice
    ChangeDevice(devices[cur+1], option)
    return

RAlt & Space::
    SoundSet, -1, , mute
    return

ChangeDevice(device, option) {
    TrayTip, %device%, 当前播放设备, , %option%
    Run, nircmd.exe setdefaultsounddevice %device%
    SetTimer, HideTrayTip, 1000
}

HideTrayTip() {
    TrayTip  ; 尝试以正常的方式隐藏它.
    ; if SubStr(A_OSVersion,1,3) = "10." {
    ;     Menu Tray, NoIcon
    ;     Sleep 200  ; 可能有必要调整 sleep 的时间.
    ;     Menu Tray, Icon
    ; }
}
