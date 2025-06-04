#Requires AutoHotkey v2.0

#InputLevel 1 ; 只捕获用户输入

Up::
Down::
Left::
Right::
{
    MsgBox "你按下了方向键：" A_ThisHotkey
    return
}

#InputLevel 0 ; 还原默认

F1:: ; 测试脚本模拟
{
    SendLevel 1
    Send "{Up}"
}
