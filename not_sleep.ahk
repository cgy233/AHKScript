#SingleInstance, Force
#Persistent
SetTimer, CheckInput, 120000
return

CheckInput:
  ; 检查鼠标事件
  Critical
  OnMessage(0x200, "ResetTimer")  ; 0x200代表鼠标事件
  MouseGetPos, , , id, control
  If (id != 0) {
    ; 如果检测到鼠标事件，重置计时器并返回
    SetTimer, CheckInput, -1
    SetTimer, CheckInput, 120000
    return
  }

  ; 检查键盘事件
  OnMessage(0x100, "ResetTimer")  ; 0x100代表键盘事件
  Input, key, L1 V
  If (ErrorLevel = "Timeout") {
    ; 如果没有检测到键盘事件，重置计时器并返回
    SetTimer, CheckInput, -1
    SetTimer, CheckInput, 120000
    return
  }

  ; 如果检测到键盘事件，重置计时器并返回
  SetTimer, CheckInput, -1
  SetTimer, CheckInput, 120000
return

ResetTimer(wParam, lParam) {
  ; 重置计时器
  SetTimer, CheckInput, -1
  SetTimer, CheckInput, 120000
  return
}
