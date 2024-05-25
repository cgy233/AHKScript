%1 mshta vbscript:CreateObject("Shell.application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit

for /f "skip=1 tokens=3" %%s in ('query user %USERNAME%') do (
 %windir%\System32\tscon.exe %%s /dest:console
)

net stop NvContainerLocalSystem
net start NvContainerLocalSystem