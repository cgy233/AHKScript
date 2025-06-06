# ahk2exe.exe /in "脚本路径.ahk" /out "输出路径.exe" /icon "图标路径.ico"
import os
import subprocess

ahk2exe_path = r"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"

def ahk2exe(script_path, icon_path, output_path):
    command = [
        ahk2exe_path,
        '/in', script_path,
        '/out', output_path,
        '/icon', icon_path
    ]
    subprocess.run(command)

if __name__ == "__main__":
    script_path = "./tools.ahk"
    icon_path = "./apple.ico"
    output_path = "./tools.exe"
    ahk2exe(script_path, icon_path, output_path)