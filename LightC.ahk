#SingleInstance, Force
SetCapsLockState, AlwaysOff
    ; AHK YYDS!!!
    ; ---------------------------------------------------------
    ; Esc + A 大小写锁
    !+^a::
    GetKeyState, CapsLockState, CapsLock, T
    if CapsLockState = D
        SetCapsLockState, AlwaysOff
    else
        SetCapsLockState, AlwaysOn
    KeyWait, a
    ; 模拟小键盘
    !Del:: 
    Send {1}
    return
    !End::
    Send {2}
    return
    !PgDn::
    Send {3}
    return
    !Ins::
    Send {4}
    return
    !Home::
    Send {5}
    return
    !Pgup::
    Send {6}
    return
    !PrintScreen::
    Send {7}
    return
    !Esc::
    Send {8}
    return
    !Pause::
    Send {9}
    return
    ; 编辑文本时 vim 上下左右
    !k::   ;; !->alt键   k->字母键k
    Send {Up}   ;;输入 上 键
    return
    !j::
    Send {Down}
    return
    !h::
    Send {Left}
    return
    !l::
    Send {Right}
    return
    ; 快捷文本
    !+^p:: Send, szzs1211652514.
    return
    ; 复制文件完整路径及文件名
    !+^c::
    Clipboard =
    Send,^c
    ClipWait
    path = %Clipboard%
    Clipboard = %path%
    Tooltip,%path%
    Sleep,1000
    Tooltip
    return
    ; vscode 调试51 编译快捷键
    !+^;::
    {
        Send, idf.py build
        Send {enter}
        Sleep, 10000
        Send, idf.py -p COM17 flash monitor
        Send {enter}
        ; Click, 97, 83

    }
    return
    ; 抓串口日志
    !+^'::
    {
        Loop, 50
        {
            
        }
        ; Click, 1433, 70
        ;Click, 960, 909
    }
    return
    ; ---------------------------------------------------------
    ; 音源选择
    ; Ctrl+Shift+Alt+I -> 显示器输出
    !+^i::
    {
        Run nircmd setdefaultsounddevice "24G2W1G4"
        return
    }
    ; Ctrl+Shift+Alt+O -> 扬声器输出
    !+^o::
    {
        Run nircmd setdefaultsounddevice "扬声器"
        return
    }
    ; Ctrl+Shift+Alt+B -> 蓝牙
    !+^b::
    {
        Run nircmd setdefaultsounddevice "耳机"
        return
    }
    ; ---------------------------------------------------------
    ; 网络配置，直连或Openwrt
    ; 直连
    !+^d::
    {
        Run, *RunAs %ComSpec% /c netsh interface ip set address name="以太网" source=dhcp,,hide
        Run, *RunAs %ComSpec% /c netsh interface ip set dns name="以太网" source=dhcp,,hide
        return
    }
    ; Openwrt
    !+^s::
    {
        Run, *RunAs %ComSpec% /c netsh interface ip set address name="以太网" source=static addr=192.168.31.33 mask=255.255.255.0 gateway=192.168.31.11 1,,hide
        Run, *RunAs %ComSpec% /c netsh interface ip set dns name="以太网" source=static addr=192.168.31.11,,hide
        return
    }
    ; 锻炼身体
    ; !+^j:: Run https://fs1.app/hot/
    ; 锻炼心脏
    !+^g::
    {
        Run D:\steam\steam.exe
        Run D:\Program Files (x86)\nn\nn.exe
        return
    }