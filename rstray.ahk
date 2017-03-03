;Redshift Tray v1.0.1 - https://github.com/ltGuillaume/Redshift-Tray
#NoEnv
#SingleInstance, force
#Persistent
SetWorkingDir %A_ScriptDir%

Global lat, lon, day, night, pauseminutes, hotkeys, mode, timer, restorecaption, ini = "rstray.ini", brightness = 1
IniRead, lat, %ini%, Redshift, latitude, 52.3702
IniRead, lon, %ini%, Redshift, longitude, 4.8952
IniRead, day, %ini%, Redshift, daytemp, 6500
IniRead, night, %ini%, Redshift, nighttemp, 3500
IniRead, pauseminutes, %ini%, Redshift, pauseminutes, 10
IniRead, hotkeys, %ini%, Redshift, optionalhotkeys, 0
IniRead, colorizecursor, %ini%, Redshift, colorizecursor, 0
IniRead, runasadmin, %ini%, Redshift, runasadmin, 0

If runasadmin And !A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%" /restart

RegRead, mousetrails, HKCU\Control Panel\Mouse, MouseTrails
If colorizecursor And mousetrails <> -1
	RegWrite, REG_SZ, HKCU\Control Panel\Mouse, MouseTrails, -1
Else If !colorizecursor And mousetrails = -1
	RegDelete, HKCU\Control Panel\Mouse, MouseTrails

Menu, Tray, NoStandard
Menu, Tray, Add, &Enabled, Enable, Radio
Menu, Tray, Add, &Disabled, Disable, Radio
Menu, Tray, Add, &Forced, Force, Radio
Menu, Tray, Add, &Paused, Pause, Radio
Menu, Tray, Add
Menu, Tray, Add, &Hotkeys, Hotkeys
Menu, Tray, Add, &Autorun, Autorun
Menu, Tray, Add, &Settings, Settings
Menu, Tray, Add
Menu, Tray, Add, E&xit, Exit
If hotkeys
	Menu, Tray, Check, &Hotkeys
Else
	Suspend, On
RegRead, autorun, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
If !ErrorLevel
	Menu, Tray, Check, &Autorun

Enable:
	mode = enable
	timer = 0
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Uncheck, &Paused
	Menu, Tray, Check, &Enabled
	Menu, Tray, Default, &Disabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 1, 1
	Run()
	Return

Force:
	mode = force
	timer = 0
	Menu, Tray, UnCheck, &Enabled
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, Uncheck, &Paused
	Menu, Tray, Check, &Forced
	Menu, Tray, Default, &Disabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 1, 1
	Run()
	Return

Disable:
	mode = disable
	timer = 0
	Menu, Tray, Uncheck, &Enabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Uncheck, &Paused
	Menu, Tray, Check, &Disabled
	Menu, Tray, Default, &Enabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 2, 1
	Restore()
	TrayTip()
	Return

Pause:
	mode = pause
	timer := pauseminutes * 60
	Menu, Tray, Uncheck, &Enabled
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Check, &Paused
	Menu, Tray, Default, &Enabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 2, 1
	Restore()
	While timer > 0
	{
		TrayTip()
		Sleep, 10000
		timer -= 10
	}
	If mode = pause
		Goto, Enable
	Return

Hotkeys:
	MsgBox, 4, Hotkeys List,
	(
============	  Default Hotkeys	===========
RControl PgUp	Increase brightness
RControl PgDn	Decrease brightness
RControl Home	Reset brightness

============	 Optional Hotkeys	===========
RControl Up	MM: Volume up
RControl Down	MM: Volume down
AltGr ,		MM: Previous
AltGr .		MM: Next
AltGr /		MM: Play/Pause
AltGr 9		Toggle window always on top
AltGr 0		Toggle window on top clickthrough
AltGr -		Increase window transparency
AltGr =		Decrease window transparency
AltGr Space	Send Ctrl-W
RShift		Windows Run dialog

Hotkeys will not work when the active program is running
as admin, unless you set the "runasadmin" setting to 1.

Enable optional hotkeys?
	)
	IfMsgBox Yes
	{
		Suspend, Off
		Menu, Tray, Check, &Hotkeys
		hotkeys = 1
	}
	IfMsgBox No
	{
		Suspend, On
		Menu, Tray, Uncheck, &Hotkeys
		hotkeys = 0
	}
	IniWrite, %hotkeys%, %ini%, Redshift, optionalhotkeys
	Return

Autorun:
	RegRead, autorun, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
	If ErrorLevel
	{
		RegWrite, REG_SZ, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift, "%A_ScriptFullPath%"
		Menu, Tray, Check, &Autorun
	}
	Else
	{
		RegDelete, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
		Menu, Tray, Uncheck, &Autorun
	}
	Return

Settings:
	IniWrite, %lat%, %ini%, Redshift, latitude
	IniWrite, %lon%, %ini%, Redshift, longitude
	IniWrite, %day%, %ini%, Redshift, daytemp
	IniWrite, %night%, %ini%, Redshift, nighttemp
	IniWrite, %pauseminutes%, %ini%, Redshift, pauseminutes
	IniWrite, %colorizecursor%, %ini%, Redshift, colorizecursor
	IniWrite, %runasadmin%, %ini%, Redshift, runasadmin
	FileGetTime, modtime, %ini%
	RunWait, %ini%
	FileGetTime, newmodtime, %ini%
	If newmodtime <> %modtime%
		Reload
	Return

Exit:
	Restore()
	ExitApp

#IfWinNotActive ahk_class TscShellContainerClass
>^PgUp::Brightness(0.05)
>^PgDn::Brightness(-0.05)
>^Home::Brightness(1)
#If !WinActive("ahk_class TscShellContainerClass") And hotkeys
>^Up::Send {Volume_Up}
>^Down::Send {Volume_Down}
<^>!,::Send {Media_Prev}
<^>!.::Send {Media_Next}
<^>!/::Send {Media_Play_Pause}
<^>!9::WinSet, AlwaysOnTop, Toggle, A
<^>!0::
	WinGet, ExStyle, ExStyle, A
	If (ExStyle & 0x20) {
		If restorecaption
		{
			WinSet, Style, +0xC00000, A
			WinSet, Style, -0x1000000, A
			restorecaption = FALSE
		}
		WinSet, AlwaysOnTop, Off, A
		WinSet, ExStyle, -0x20, A
	} Else {
		WinGet, transparency, Transparent, A
		WinSet, AlwaysOnTop, On, A
		WinGet, Style, Style, A
		If (transparency = "") Or transparency = 255
			WinSet, Transparent, 254, A
		If (Style & 0xC00000) {
			restorecaption = TRUE
			WinSet, Style, -0xC00000, A
			WinSet, Style, +0x1000000, A
		}
		If transparency = 254
			WinSet, Transparent, 255, A
		WinSet, ExStyle, +0x20, A
	}
	Return
<^>!-::
	WinGet, transparency, Transparent, A
	If (transparency = "")
		transparency = 255
	Else If transparency > 20
		transparency -= 5
	WinSet, Transparent, %transparency%, A
	Return
<^>!=::
	WinGet, transparency, Transparent, A
	If (transparency = "")
		transparency = 255
	Else If transparency = 255
		transparency = OFF
	Else
		transparency += 5
	WinSet, Transparent, %transparency%, A
	Return
<^>!Space::Send ^w
RShift & Up::Return	; Make RShift a prefix by using it in front of "&" at least once.
RShift::WinRunDialog()

Restore() {
	RunWait, redshift.exe -x,,Hide
	Loop {
		Process, Close, redshift.exe
		Process, Exist, redshift.exe
	}	Until !ErrorLevel
}

Run(adjbr = FALSE) {
	br := brightness>1 ? "-g " . brightness : "-b " . brightness
	br := adjbr ? br . " -r" : br
	If mode = enable
		cfg = -l %lat%:%lon% -t %day%:%night% %br%
	Else If mode = force
		cfg = -O %night% -r
	Else If mode = disable
		cfg = -O 6500 %br%
	Process, Exist, redshift.exe
	If ErrorLevel
		Restore()
	Run, redshift.exe %cfg%,,Hide
	TrayTip()
}

TrayTip() {
	If mode = enable
		status = Enabled: %night%K/%day%K`nLatitude: %lat%`nLongitude: %lon%
	Else If mode = force
		status = Forced: %night%K
	Else If mode = pause
	{
		endtime += timer, seconds
		FormatTime, endtime, %endtime%, HH:mm
		status = Disabled until %endtime%
	}
	Else
		status = Disabled
	br := Round(brightness * 100, 0)
	Menu, Tray, Tip, Redshift`n%status%`nBrightness = %br%`%
}

WinRunDialog() {
	IfWinExist, ahk_class #32770
	{
		IfWinActive, ahk_class #32770
			Send !{Esc}
		WinClose, ahk_class #32770
	}
	Else
		Send #r
}

Brightness(value) {
	If value = 1
		brightness = 1
	Else
		brightness += value
	Run(TRUE)
	BrightnessError(value)
}

BrightnessError(value) {
	Sleep, 500
	Process, Exist, redshift.exe
	If !ErrorLevel {
		brightness -= value
		Run(TRUE)
	}
}