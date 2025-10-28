#Requires AutoHotkey v2.0
#SingleInstance Force

; 加载必要的DLL
XInput := DllCall("LoadLibrary", "Str","xinput1_4.dll", "Ptr")
user32 := DllCall("LoadLibrary", "Str","user32.dll", "Ptr")

; 全局变量
global prevButtons := 0
global lastValidButtons := 0
global errorCount := 0
global isIntercepting := false
global hWnd := 0

; 常量定义
RIM_TYPEHID := 2
RIDEV_INPUTSINK := 0x00000100
WM_INPUT := 0x00FF

; 创建隐藏窗口来接收Raw Input消息
hWnd := CreateHiddenWindow()

; 注册Raw Input设备来拦截手柄输入
RegisterRawInputDevices(hWnd)

; 使用5ms检测频率，确保最高精度
SetTimer CheckController, 5

CheckController() {
    global prevButtons, lastValidButtons, errorCount, isIntercepting, hWnd
    static state := Buffer(16, 0)
    static lastProcessTime := 0
    static rapidPressCount := 0
    
    ; 清空缓冲区确保数据干净
    DllCall("RtlZeroMemory", "Ptr", state, "UInt", 16)
    
    result := DllCall("xinput1_4\XInputGetState", "UInt", 0, "Ptr", state)
    
    ; XInput调用失败处理
    if (result != 0) {
        errorCount++
        if (errorCount > 10) {
            prevButtons := lastValidButtons
            errorCount := 0
        }
        return
    }
    
    errorCount := 0
    buttons := NumGet(state, 4, "UShort")
    currentTime := A_TickCount
    
    ; 检测快速点按
    if ((buttons & 0x0100) && !(prevButtons & 0x0100)) {
        if (currentTime - lastProcessTime < 100) {  ; 100ms内再次按下
            rapidPressCount++
        } else {
            rapidPressCount := 0
        }
        lastProcessTime := currentTime
    }
    
    ; 处理按键状态变化 - 使用新的完全拦截方法
    processButtonsUltimate(buttons, rapidPressCount)
    
    prevButtons := buttons
    lastValidButtons := buttons
    
    ; 处理Windows消息
    ProcessWindowsMessages(hWnd)
}

processButtonsUltimate(buttons, rapidPressCount) {
    static lastProcessedButtons := 0
    static lbDownTime := 0
    static lbProcessed := false
    static lastSendTime := 0
    
    currentTime := A_TickCount
    
    ; LB按下处理 - 终极防抖机制
    if ((buttons & 0x0100) && !(lastProcessedButtons & 0x0100)) {
        ; 防止重复发送（最小间隔20ms）
        if (currentTime - lastSendTime < 20) {
            return
        }
        
        ; 设置拦截状态
        isIntercepting := true
        
        lbDownTime := currentTime
        lbProcessed := false
        lastSendTime := currentTime
        
        ; 立即发送键盘x按下，使用更稳定的发送方式
        SendInput("{x down}")
        
        ; 对于快速点按，立即发送抬起
        if (rapidPressCount >= 1) {
            Sleep(2)  ; 极短延迟
            SendInput("{x up}")
            lbProcessed := true
        }
        
        ; ToolTip("LB按下 (快速:" rapidPressCount ") 拦截中", 0, 0)
    }
    
    ; LB抬起处理 - 终极防抖机制
    if (!(buttons & 0x0100) && (lastProcessedButtons & 0x0100)) {
        ; 确保按下时间足够长才发送抬起
        if (!lbProcessed && (currentTime - lbDownTime) > 30) {
            SendInput("{x up}")
            lastSendTime := currentTime
            ; ToolTip("LB抬起", 0, 0)
        }
        
        ; 清除拦截状态
        isIntercepting := false
        lbProcessed := false
    }

    lastProcessedButtons := buttons
}

; 创建隐藏窗口来接收Raw Input消息
CreateHiddenWindow() {
    ; 创建窗口类
    wc := Buffer(A_PtrSize == 8 ? 80 : 48)
    NumPut("UInt", 48, wc, 0)  ; cbSize
    NumPut("UInt", 0x0002 | 0x0008, wc, 4)  ; style (CS_HREDRAW | CS_VREDRAW)
    NumPut("Ptr", 0, wc, 8)  ; lpfnWndProc
    NumPut("Int", 0, wc, 16)  ; cbClsExtra
    NumPut("Int", 0, wc, 20)  ; cbWndExtra
    NumPut("Ptr", 0, wc, 24)  ; hInstance
    NumPut("Ptr", 0, wc, 32)  ; hIcon
    NumPut("Ptr", 0, wc, 40)  ; hCursor
    NumPut("Ptr", 0, wc, 48)  ; hbrBackground
    NumPut("Ptr", 0, wc, 56)  ; lpszMenuName
    NumPut("Ptr", 0, wc, 64)  ; lpszClassName
    
    ; 注册窗口类
    className := "RawInputWindow"
    NumPut("Ptr", StrPtr(className), wc, 64)
    
    atom := DllCall("RegisterClassW", "Ptr", wc, "UShort")
    if (atom == 0) {
        throw Error("无法注册窗口类")
    }
    
    ; 创建窗口
    hWnd := DllCall("CreateWindowExW"
        , "UInt", 0  ; dwExStyle
        , "Ptr", StrPtr(className)  ; lpClassName
        , "Ptr", 0  ; lpWindowName
        , "UInt", 0x80000000  ; dwStyle (WS_POPUP)
        , "Int", 0, "Int", 0, "Int", 0, "Int", 0  ; x, y, width, height
        , "Ptr", 0  ; hWndParent
        , "Ptr", 0  ; hMenu
        , "Ptr", 0  ; hInstance
        , "Ptr", 0  ; lpParam
        , "Ptr")
    
    if (hWnd == 0) {
        throw Error("无法创建窗口")
    }
    
    return hWnd
}

; 注册Raw Input设备
RegisterRawInputDevices(hWnd) {
    ; 设置Raw Input设备
    rid := Buffer(A_PtrSize == 8 ? 24 : 12)
    NumPut("UShort", 1, rid, 0)  ; usUsagePage (Generic Desktop)
    NumPut("UShort", 5, rid, 2)  ; usUsage (Game Pad)
    NumPut("UInt", RIDEV_INPUTSINK, rid, 4)  ; dwFlags
    NumPut("Ptr", hWnd, rid, A_PtrSize == 8 ? 8 : 8)  ; hwndTarget
    
    result := DllCall("RegisterRawInputDevices"
        , "Ptr", rid
        , "UInt", 1
        , "UInt", A_PtrSize == 8 ? 24 : 12
        , "UInt")
    
    if (result == 0) {
        ; ToolTip("Raw Input注册失败: " A_LastError, 0, 0)
    } else {
        ; ToolTip("Raw Input注册成功", 0, 0)
    }
}

; 处理Windows消息
ProcessWindowsMessages(hWnd) {
    msg := Buffer(48)
    while (DllCall("PeekMessageW", "Ptr", msg, "Ptr", hWnd, "UInt", 0, "UInt", 0, "UInt", 1)) {
        if (NumGet(msg, 8, "UInt") == WM_INPUT) {
            ; 处理Raw Input消息
            HandleRawInput(NumGet(msg, 16, "Ptr"))
        }
        DllCall("TranslateMessage", "Ptr", msg)
        DllCall("DispatchMessageW", "Ptr", msg)
    }
}

; 处理Raw Input数据
HandleRawInput(lParam) {
    if (isIntercepting) {
        ; 如果正在拦截，阻止Raw Input传递到游戏
        return
    }
    
    ; 获取Raw Input数据大小
    size := 0
    DllCall("GetRawInputData", "Ptr", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", &size, "UInt", 16)
    
    if (size > 0) {
        ; 读取Raw Input数据
        data := Buffer(size)
        result := DllCall("GetRawInputData", "Ptr", lParam, "UInt", 0x10000003, "Ptr", data, "UInt*", &size, "UInt", 16)
        
        if (result > 0) {
            ; 检查是否是手柄输入
            header := NumGet(data, 0, "UInt")
            if (header == RIM_TYPEHID) {
                ; 这是HID设备输入，可能是手柄
                ; 在这里可以进一步过滤特定的按键
                ; ToolTip("拦截到HID输入", 0, 50)
            }
        }
    }
}

