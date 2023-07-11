; Script Information ===========================================================
; Name:        New AutoHotkey Script
; Description: New Script Description
; AHK Version: 1.1.31.01 (Unicode 32-bit)
; OS Version:  Windows 2000+
; Language:    English (United States)
; Author:      FirstName LastName <email@address.xyz>
; Filename:    New AutoHotkey Script.ahk
; ==============================================================================

; Revision History =============================================================
; Revision 1 (YYYY-MM-DD)
; * Initial release
; ==============================================================================

; Auto-Execute =================================================================
#SingleInstance, Force ; Allow only one running instance of script
#Persistent ; Keep the script permanently running until terminated
#NoEnv ; Avoid checking empty variables for environment variables
#Warn ; Enable warnings to assist with detecting common errors
;#NoTrayIcon ; Disable the tray icon of the script
;#KeyHistory, 0 ; Keystroke and mouse click history
;ListLines, Off ; The script lines most recently executed
SetWorkingDir, % A_ScriptDir ; Set the working directory of the script
SetBatchLines, -1 ; The speed at which the lines of the script are executed
SendMode, Input ; The method for sending keystrokes and mouse clicks
;DetectHiddenWindows, On ; The visibility of hidden windows by the script
;SetWinDelay, 0 ; The delay to occur after modifying a window
;SetControlDelay, 0 ; The delay to occur after modifying a control
OnExit("OnUnload") ; Run a subroutine or function when exiting the script

return ; End automatic execution
; ==============================================================================

; Labels =======================================================================
; TBD
; ==============================================================================

; Functions ====================================================================
OnLoad() {
	Global ; Assume-global mode
	Static Init := OnLoad() ; Call function

	Menu, Tray, Tip, IP Changer

	Presets := []
	Presets[1] := {"IP": "192.168.31.3", "SM": "255.255.255.0", "GW": "192.168.31.1", "DNS1": "192.168.31.1", "DNS2": "223.5.5.5"}
	Presets[2] := {"IP": "192.168.31.3", "SM": "255.255.255.0", "GW": "192.168.31.11", "DNS1": "192.168.31.11", "DNS2": "192.168.31.11"}

	If (FileExist(A_Temp "\NetInfo.txt")) {
		FileDelete, %A_Temp%\NetInfo.txt
	}
}

OnUnload(ExitReason, ExitCode) {
	Global ; Assume-global mode
}

GuiCreate() {
	Global ; Assume-global mode
	Static Init := GuiCreate() ; Call function

	Gui, +LastFound -Resize +HWNDhGui
	Gui, Margin, 10, 10

	Gui, Add, Text, xm ym w160, Select Preset:
	Gui, Add, DropDownList, w160 vPresetsDDL gPresetsDDL +AltSubmit
	Gui, Add, Text, x+20 ym w160 Section, Select Adapter:
	Gui, Add, DropDownList, w160 vAdaptersDDL gAdaptersDDL
	Gui, Add, Text, xm w160, IP Address:
	Gui, Add, Edit, w160 r1 HWNDhIPAddress +ReadOnly
	Gui, Add, Text, w160, Subnet Mask:
	Gui, Add, Edit, w160 r1 HWNDhSubnetMask +ReadOnly
	Gui, Add, Text, w160, Gateway:
	Gui, Add, Edit, w160 r1 HWNDhGateway +ReadOnly
	Gui, Add, Text, w160, DNS Server 1:
	Gui, Add, Edit, w160 r1 HWNDhDNSServer1 +ReadOnly
	Gui, Add, Text, w160, DNS Server 2:
	Gui, Add, Text, x+20 yp w160, Selected Adapter:
	Gui, Add, Edit, xm w160 r1 HWNDhDNSServer2 +ReadOnly
	Gui, Add, Edit, x+20 w160 r1 HWNDhSelectedAdapter +ReadOnly
	Gui, Add, Button, xm w80 h23, Set IP
	Gui, Add, Button, xs yp w80 h23, DHCP

	Gui, Add, Text, xm y+20 w160 HWNDhStatus,

	Gui, Font, c666666
	GuiControl, Font, % hStatus

	Gui, Show, AutoSize, IP Changer

	For Index, Value In Presets {
		GuiControl,, PresetsDDL, % "Preset " Index

		If (Index = Presets.MaxIndex()) {
			GuiControl,, PresetsDDL, Custom
		}
	}

	GuiControl,, % hStatus, Getting Adapters...
	GuiControl, +Disabled, AdaptersDDL
	RunWait, PowerShell.exe Get-NetAdapter | Format-Table -Property Name | Out-File -FilePath %A_Temp%\NetInfo.txt -Width 300,, Hide

	Adapters := ""

	Loop, Read, %A_Temp%\NetInfo.txt
	{
		If (A_Index < 4 || A_LoopReadLine = "") {
			Continue
		}

		Adapters .= RegexReplace(A_LoopReadLine, "^\s+|\s+$") "|"
	}

	If (FileExist(A_Temp "\NetInfo.txt")) {
		FileDelete, %A_Temp%\NetInfo.txt
	}

	Sort, Adapters, UD|
	GuiControl,, AdaptersDDL, % Adapters
	GuiControl, -Disabled, AdaptersDDL
	GuiControl,, % hStatus, Ready
}

AdaptersDDL:
	Gui, Submit, NoHide

	GuiControl,, % hSelectedAdapter, % AdaptersDDL
return

PresetsDDL:
	Gui, Submit, NoHide

	If (PresetsDDL <> Presets.MaxIndex() + 1) {
		GuiControl,, % hIPAddress, % Presets[PresetsDDL].IP
		GuiControl,, % hSubnetMask, % Presets[PresetsDDL].SM
		GuiControl,, % hGateway, % Presets[PresetsDDL].GW
		GuiControl,, % hDNSServer1, % Presets[PresetsDDL].DNS1
		GuiControl,, % hDNSServer2, % Presets[PresetsDDL].DNS2
	}

	GuiControl, % (PresetsDDL = Presets.MaxIndex() + 1  ? "-ReadOnly" : "+ReadOnly"), % hIPAddress
	GuiControl, % (PresetsDDL = Presets.MaxIndex() + 1  ? "-ReadOnly" : "+ReadOnly"), % hSubnetMask
	GuiControl, % (PresetsDDL = Presets.MaxIndex() + 1  ? "-ReadOnly" : "+ReadOnly"), % hGateway
	GuiControl, % (PresetsDDL = Presets.MaxIndex() + 1  ? "-ReadOnly" : "+ReadOnly"), % hDNSServer1
	GuiControl, % (PresetsDDL = Presets.MaxIndex() + 1  ? "-ReadOnly" : "+ReadOnly"), % hDNSServer2
return

GuiClose(GuiHwnd) {
	ExitApp ; Terminate the script unconditionally
}

GuiEscape(GuiHwnd) {
	ExitApp ; Terminate the script unconditionally
}
; ==============================================================================