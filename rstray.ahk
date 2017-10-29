;Redshift Tray v1.4.2 - https://github.com/ltGuillaume/Redshift-Tray
#NoEnv
#SingleInstance, force
#Persistent
#MaxHotkeysPerInterval, 200
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

Global exe = "redshift.exe", ini = "rstray.ini", s = "Redshift", lat, lon, day, night, fullscreen, notransitions
Global mode, timer, temperature, rundialog, brightness = 1, isfullscreen, withcaption := Object()
IniRead, lat, %ini%, %s%, latitude
IniRead, lon, %ini%, %s%, longitude
IniRead, day, %ini%, %s%, daytemp, 6500
IniRead, night, %ini%, %s%, nighttemp, 3500
IniRead, fullscreen, %ini%, %s%, fullscreentemp, 6500
IniRead, fullscreenmode, %ini%, %s%, fullscreenmode, 0
IniRead, pauseminutes, %ini%, %s%, pauseminutes, 10
IniRead, notransitions, %ini%, %s%, notransitions, 0
IniRead, colorizecursor, %ini%, %s%, colorizecursor, 0
IniRead, traveling, %ini%, %s%, traveling, 0
IniRead, startdisabled, %ini%, %s%, startdisabled, 0
IniRead, hotkeys, %ini%, %s%, optionalhotkeys, 0
IniRead, runasadmin, %ini%, %s%, runasadmin, 0

If runasadmin And !A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%" /restart

RegRead, mousetrails, HKCU\Control Panel\Mouse, MouseTrails
If colorizecursor And mousetrails <> -1
	RegWrite, REG_SZ, HKCU\Control Panel\Mouse, MouseTrails, -1
Else If !colorizecursor And mousetrails = -1
	RegDelete, HKCU\Control Panel\Mouse, MouseTrails

Menu, Tray, NoStandard
Menu, Tray, Tip, Redshift
Menu, Tray, Add, &Enabled, Enable, Radio
Menu, Tray, Add, &Forced, Force, Radio
Menu, Tray, Add, &Paused, Pause, Radio
Menu, Tray, Add, &Disabled, Disable, Radio
Menu, Tray, Add
Menu, Tray, Add, &Help, Help
Menu, Settings, Add, &Autorun, Autorun
Menu, Settings, Add, &Hotkeys, Hotkeys
Menu, Settings, Add, &More settings..., Settings
Menu, Tray, Add, &Settings, :Settings
Menu, Tray, Add
Menu, Tray, Add, &Restart, Restart
Menu, Tray, Add, E&xit, Exit
If hotkeys
	Menu, Settings, Check, &Hotkeys

RegRead, autorun, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
If !ErrorLevel
	Menu, Settings, Check, &Autorun

If startdisabled
	Goto, Disable
Else If fullscreenmode
	SetTimer, FullScreen, 1000

Enable:
	mode = enabled
	timer = 0
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Uncheck, &Paused
	Menu, Tray, Check, &Enabled
	Menu, Tray, Default, &Disabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 1, 1
	If traveling Or (lat = "ERROR" Or lon = "ERROR")
		GetLocation()
	If (lat = "ERROR" Or lon = "ERROR")
		Goto, Settings
	Else
		Run()
	Return

Force:
	mode = forced
	timer = 0
	temperature = %night%
	Menu, Tray, UnCheck, &Enabled
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, Uncheck, &Paused
	Menu, Tray, Check, &Forced
	Menu, Tray, Default, &Enabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 1, 1
	Run()
	Return

Disable:
	If isfullscreen <> 1
		mode = disabled
	timer = 0
	brightness = 1
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
	mode = paused
	timer := pauseminutes * 60
	restorebrightness = %brightness%
	brightness = 1
	Menu, Tray, Uncheck, &Enabled
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Check, &Paused
	Menu, Tray, Default, &Enabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 2, 1
	Restore()
	SetTimer, Paused
	Return

Paused:
	While timer > 0 {
		If mode <> paused
			SetTimer,, Delete
		TrayTip()
		Sleep, 10000
		timer -= 10
	}
	SetTimer,, Delete
	If mode = paused
	{
		brightness = %restorebrightness%
		Goto, Enable
	}
	Return

Help:
	Gui, Add, ActiveX, w800 h600 vbrowser, Shell.Explorer
	browser.Navigate("file://" . A_ScriptDir . "/readme.htm")
	Gui, Show,, Help
	Return

GuiClose:
	Gui, Destroy
	Return

Hotkeys:
	MsgBox, 4, Hotkeys,
	(
============	  Default Hotkeys	===========
Alt Home		Reset Redshift
Alt End		Disable Redshift
Alt PgUp		Increase brightness
Alt PgDn		Decrease brightness
Alt Pause		Toggle pause for %pauseminutes% minutes
AltGr Home	Force night temperature (reset)
AltGr End		End forced temperature
AltGr PgUp	Increase forced temperature
AltGr PgDn	Decrease forced temperature

============	 Optional Hotkeys	===========
AltGr 9		Toggle window always on top
AltGr 0		Toggle window on top click-through
AltGr -		Increase window transparency
AltGr =		Decrease window transparency
AltGr Space	Send Ctrl W
AltGr ,		MM: Previous
AltGr .		MM: Next
AltGr /		MM: Play/Pause
RCtrl Up		MM: Volume up
RCtrl Down	MM: Volume down
RCtrl Menu	Windows Run dialog
Menu + Arrows	Aero Snap
Menu Home	Restart computer
Menu End		Hibernate computer
DblClick on taskbar	Show desktop
MidClick on taskbar	Open Task Manager
Wheel on taskbar	MM: Volume up/down

Hotkeys will not work when the active window is of a
program run as admin, unless you set "runasadmin=1".

Enable optional hotkeys?
	)
	IfMsgBox Yes
	{
		Menu, Settings, Check, &Hotkeys
		hotkeys = 1
	}
	IfMsgBox No
	{
		Menu, Settings, Uncheck, &Hotkeys
		hotkeys = 0
	}
	IniWrite, %hotkeys%, %ini%, %s%, optionalhotkeys
	Return

Autorun:
	RegRead, autorun, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
	If ErrorLevel
	{
		RegWrite, REG_SZ, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift, "%A_ScriptFullPath%"
		Menu, Settings, Check, &Autorun
	}
	Else
	{
		RegDelete, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
		Menu, Settings, Uncheck, &Autorun
	}
	Return

Settings:
	IniWrite, %lat%, %ini%, %s%, latitude
	IniWrite, %lon%, %ini%, %s%, longitude
	IniWrite, %day%, %ini%, %s%, daytemp
	IniWrite, %night%, %ini%, %s%, nighttemp
	IniWrite, %fullscreen%, %ini%, %s%, fullscreentemp
	IniWrite, %fullscreenmode%, %ini%, %s%, fullscreenmode
	IniWrite, %pauseminutes%, %ini%, %s%, pauseminutes
	IniWrite, %notransitions%, %ini%, %s%, notransitions
	IniWrite, %colorizecursor%, %ini%, %s%, colorizecursor
	IniWrite, %traveling%, %ini%, %s%, traveling
	IniWrite, %startdisabled%, %ini%, %s%, startdisabled
	IniWrite, %hotkeys%, %ini%, %s%, optionalhotkeys
	IniWrite, %runasadmin%, %ini%, %s%, runasadmin
	FileGetTime, modtime, %ini%
	RunWait, %ini%
	FileGetTime, newmodtime, %ini%
	If newmodtime <> %modtime%
		Reload
	Return

FullScreen:
	If mode <> enabled
		Return
	WinGet, id, ID, A
	WinGetClass, cls, ahk_id %id%
	WinGet style, Style, ahk_id %id%
	WinGetPos ,,, width, height, ahk_id %id%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	If ((style & 0x20800000) Or height < A_ScreenHeight Or width < A_ScreenWidth) {	; Not full-screen
		If isfullscreen = 1	; Was full-screen
		{
			isfullscreen = 2	; Full-screen is done
			Gosub, Enable
			isfullscreen = 0	; Full-screen is off
		}
	} Else If (isfullscreen <> 1 And cls <> "Progman" And cls <> "WorkerW" And cls <> "TscShellContainerClass") {	; Full-screen and not (remote) desktop
		isfullscreen = 1	; Full-screen is on
		If fullscreen = 6500
			Goto, Disable
		Else
			Goto, Enable
	}
	Return

Restart:
	Run "%A_ScriptFullPath%" /restart
	Return

Exit:
	Restore()
	ExitApp

#IfWinNotActive, ahk_class TscShellContainerClass
!PgUp::Brightness(0.05)
!PgDn::Brightness(-0.05)
!Home::
	Brightness(1)
	Goto, Enable
	Return
!Pause::
	If mode = paused
		Goto, Enable
	Else
		Goto, Pause
	Return
!End::Goto, Disable
<^>!Home::Goto, Force
<^>!PgUp::Temperature(100)
<^>!PgDn::Temperature(-100)
<^>!End::Goto, Enable

GetLocation() {
	try {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://ipapi.co/latlong", false)
		whr.Send()
		response := whr.ResponseText
	}
	If (InStr(response, "Undefined") Or response = "") {
		If (lat = "ERROR" Or lon = "ERROR") {
			MsgBox, 308, Location Error
				, An error occurred while determining your location!`nChoose Yes to retry, or No to manually specify latitude and longitude.
			IfMsgBox Yes
				GetLocation()
		}
		Return
	}
	StringSplit, latlon, response, `,
	lat = %latlon1%
	lon = %latlon2%
	IniWrite, %lat%, %ini%, %s%, latitude
	IniWrite, %lon%, %ini%, %s%, longitude
}

Close() {
	Loop {
		Process, Close, %exe%
		Process, Exist, %exe%
	} Until !ErrorLevel
}

Restore() {
	Close()
	RunWait, %exe% -x,,Hide
}

Run(adjust = FALSE) {
	br := brightness>1 ? "-g " . brightness : "-b " . brightness
	ntmp := isfullscreen = 1 ? fullscreen : night
	notr := isfullscreen Or notransitions ? "-r" : ""
	If mode = enabled
		cfg = -l %lat%:%lon% -t %day%:%ntmp% %br% %notr%
	Else If mode = forced
		cfg = -O %temperature% %br%
	Else If mode = paused
		cfg = -O 6500 %br%
	Else If mode = disabled
		cfg = -O 6500 %br%
	Close()
	If adjust
		cfg = %cfg% -r
	Else
		Restore()
	Run, %exe% %cfg%,,Hide
	TrayTip()
}

TrayTip() {
	If mode = enabled
		status = Enabled: %night%K/%day%K`nLatitude: %lat%`nLongitude: %lon%
	Else If mode = forced
		status = Forced: %temperature%K
	Else If mode = paused
	{
		endtime =
		endtime += timer, seconds
		FormatTime, endtime, %endtime%, HH:mm
		status = Disabled until %endtime%
	}
	Else
		status = Disabled
	br := Round(brightness * 100, 0)
	Menu, Tray, Tip, Redshift`n%status%`nBrightness = %br%`%
}

Brightness(value) {
	If value = 1
		brightness = 1
	Else
	{
		newbrightness := brightness + value
		If (newbrightness > 0.09 And newbrightness < 10.01)
			brightness = %newbrightness%
		Else
			Return
	}
	Run(TRUE)
	If mode = enabled
	{
		Sleep, 200
		Process, Exist, %exe%
		If !ErrorLevel
		{
			brightness -= value
			Run(TRUE)
		}
	}
}

Temperature(value) {
	If mode <> forced
		Gosub, Force
	If value = 1
		temperature = night
	Else
	{
		temp := temperature + value
		If (temp > 999 And temp < 25001)
			temperature = %temp%
		Else
			Return
	}
	Run(TRUE)
	If mode = enabled
	{
		Sleep, 200
		Process, Exist, %exe%
		If !ErrorLevel
		{
			temperature -= value
			Run(TRUE)
		}
	}
}

#If, !WinActive("ahk_class TscShellContainerClass") And hotkeys
>^AppsKey::WinRunDialog()
>^Up::Send {Volume_Up}
>^Down::Send {Volume_Down}
<^>!,::Send {Media_Prev}
<^>!.::Send {Media_Next}
<^>!/::Send {Media_Play_Pause}
<^>!9::WinSet, AlwaysOnTop, Toggle, A
<^>!0::ClickThroughWindow()
<^>!-::Opacity(-5)
<^>!=::Opacity(5)
<^>!Space::Send ^w
AppsKey & Up::Send #{Up}
AppsKey & Down::Send #{Down}
AppsKey & Left::Send #{Left}
AppsKey & Right::Send #{Right}
AppsKey & Home::Shutdown, 2
AppsKey & End::DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
AppsKey::Send {AppsKey}
#If, MouseOnTaskbar() And !WinActive("ahk_class TscShellContainerClass") And hotkeys
~LButton::ShowDesktop()
MButton::TaskMgr()
WheelUp::Send {Volume_Up}
WheelDown::Send {Volume_Down}

MouseOnTaskbar() {
	MouseGetPos,,, id
	Return WinExist("ahk_id" . id . " ahk_class Shell_TrayWnd")
}

WinRunDialog() {
	If (rundialog <> "" And WinExist("ahk_id" . rundialog)) {
		IfWinActive, ahk_id %rundialog%
			Send !{Esc}
		WinClose, ahk_id %rundialog%
		rundialog =
	} Else {
		Send #r
		WinWaitActive, ahk_class #32770 ahk_exe explorer.exe
		WinGet, rundialog, ID, A
	}
}

ClickThroughWindow() {
	WinGetClass, cls, A
	If cls = WorkerW
		Return
	WinGet, id, ID, A
	_id = ahk_id %id%
	WinGet, exstyle, ExStyle, %_id%
	If (exstyle & 0x20) {	; Clickthrough
		If withcaption.HasKey(id)
		{
			max := withcaption.Delete(id)
			if max = 1
				WinSet, Style, -0x1000000, %_id%	; -Maximize
			WinSet, Style, +0xC00000, %_id%	; +Caption
		}
		WinSet, AlwaysOnTop, Off, %_id%
		WinSet, ExStyle, -0x20, %_id%	; -Clickthrough
	} Else {
		WinGet, tr, Transparent, %_id%
		If (tr = "")
			WinSet, Transparent, 255, %_id%
		WinGet, style, Style, %_id%
		If (style & 0xC00000) {	; Has caption
			WinGet, maximized, MinMax, %_id%
			If (maximized = 1 Or WinExist(_id . " ahk_class ApplicationFrameWindow")) {
				max = 0
			} Else {
				max = 1
				WinSet, Style, +0x1000000, %_id%	; +Maximize (lose shadow)
			}
			withcaption[id] := max
			WinSet, Style, -0xC00000, %_id%	; -Caption
		}
		WinSet, AlwaysOnTop, On, %_id%
		WinSet, ExStyle, +0x20, %_id%	; +Clickthrough
	}
}

Opacity(value) {
	WinGet, tr, Transparent, A
	If (tr = "")
		tr = 255
	tr += value
	WinGet, exstyle, ExStyle, A
	If (tr > 254 And Not exstyle & 0x20)
		tr = Off
	Else If tr < 15
		tr = 15
	WinSet, Transparent, %tr%, A
	Return
}

ShowDesktop() {
	If (A_TimeSincePriorHotkey < 400 And A_PriorHotkey="~LButton" And WinActive("ahk_class Shell_TrayWnd")) {
		MouseGetPos,,,, control
		If control = MSTaskListWClass1
			Send #d
	}
}

TaskMgr() {
	WinGetClass, before, A
	If before = Shell_TrayWnd
	{
		Send !{Esc}
		WinGetClass, before, A
	}
	Click, Middle
	WinGetClass, after, A
	If (after = "Shell_TrayWnd" And before <> after)
		If A_Is64bitOS
			Run, %A_WinDir%\SysNative\taskmgr.exe
		Else
			Run, taskmgr.exe
}
