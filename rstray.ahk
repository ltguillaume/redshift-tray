; Redshift Tray v1.6.3 - https://github.com/ltGuillaume/Redshift-Tray
#NoEnv
#SingleInstance, force
#Persistent
#MaxHotkeysPerInterval, 200
SetKeyDelay, -1
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
OnExit, OnExit

; Global variables (when also used in functions)
Global exe = "redshift.exe", ini = "rstray.ini", s = "Switches", v = "Values"
Global customtimes, notransitions, colorizecursor, traveling, startdisabled, hotkeys, remotedesktop, runasadmin	; Switches
Global lat, lon, day, night, fullscreen, pauseminutes, fullscreenmode, daytime, nighttime	; Values
Global mode, temperature, brightness = 1, timer, endtime, customnight, isfullscreen, ralt, rctrl, rdpclient, remote, rundialog, withcaption := Object()	; Internal
; Settings from .ini
IniRead, lat, %ini%, %v%, latitude
IniRead, lon, %ini%, %v%, longitude
IniRead, day, %ini%, %v%, daytemp, 6500
IniRead, night, %ini%, %v%, nighttemp, 3500
IniRead, fullscreen, %ini%, %v%, fullscreentemp, 6500
IniRead, pauseminutes, %ini%, %v%, pauseminutes, 10
IniRead, daytime, %ini%, %v%, daytime, HHmm
IniRead, nighttime, %ini%, %v%, nighttime, HHmm
IniRead, colorizecursor, %ini%, %s%, colorizecursor, 0
IniRead, customtimes, %ini%, %s%, customtimes, 0
IniRead, fullscreenmode, %ini%, %s%, fullscreenmode, 0
IniRead, notransitions, %ini%, %s%, notransitions, 0
IniRead, hotkeys, %ini%, %s%, optionalhotkeys, 0
IniRead, remotedesktop, %ini%, %s%, remotedesktop, 0
IniRead, runasadmin, %ini%, %s%, runasadmin, 0
IniRead, startdisabled, %ini%, %s%, startdisabled, 0
IniRead, traveling, %ini%, %s%, traveling, 0

; Initialize
If (runasadmin And !A_IsAdmin)
	Run *RunAs "%A_ScriptFullPath%" /restart

; Set up tray menu
Menu, Tray, NoStandard
Menu, Tray, Tip, Redshift
Menu, Tray, Add, &Enabled, Enable, Radio
Menu, Tray, Add, &Forced, Force, Radio
Menu, Tray, Add, &Paused, Pause, Radio
Menu, Tray, Add, &Disabled, Disable, Radio
Menu, Tray, Add
Menu, Tray, Add, &Help, Help
Menu, Settings, Add, &Autorun, Autorun
Menu, Settings, Add, &Colorize cursor, ColorizeCursor
Menu, Settings, Add, &Custom times, CustomTimes
Menu, Settings, Add, &Full-screen mode, FullScreen
Menu, Settings, Add, &No transitions, NoTransitions
Menu, Settings, Add, &Optional hotkeys, Hotkeys
Menu, Settings, Add, &Remote Desktop support, RemoteDesktop
Menu, Settings, Add, &Run as Administrator, RunAsAdmin
Menu, Settings, Add, &Start disabled, StartDisabled
Menu, Settings, Add, &Traveling, Traveling
Menu, Settings, Add
Menu, Settings, Add, &More settings..., Settings
Menu, Tray, Add, &Settings, :Settings
Menu, Tray, Add
Menu, Tray, Add, &Restart, Restart
Menu, Tray, Add, E&xit, Exit

RegRead, autorun, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Redshift
If !ErrorLevel
	Menu, Settings, Check, &Autorun
ColorizeCursor()
If customtimes
	Menu, Settings, Check, &Custom times
if fullscreenmode
	Menu, Settings, Check, &Full-screen mode
If notransitions
	Menu, Settings, Check, &No transitions
If hotkeys
	Menu, Settings, Check, &Optional hotkeys
If remotedesktop
	Menu, Settings, Check, &Remote Desktop support
If runasadmin
	Menu, Settings, Check, &Run as Administrator
If startdisabled
	Menu, Settings, Check, &Start disabled
If traveling
	Menu, Settings, Check, &Traveling

; Set mode
If remotedesktop
	SetTimer, RemoteDesktopMode, 1500
If customtimes
{
	If (daytime = "HHmm" Or nighttime = "HHmm") {
		MsgBox, 64, Custom Times, Please fill in nighttime and daytime (use military times),`nthen save and close the settings file.
		Goto, Settings
	}
	SetTimer, CustomTimesMode, 60000
	If !startdisabled
		Goto, CustomTimesMode
}
If startdisabled
	Goto, Disable

; Or else, Enable:
Enable:
	mode = enabled
	timer = 0
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Uncheck, &Paused
	Menu, Tray, Check, &Enabled
	Menu, Tray, Default, &Disabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 1, 1
	If (traveling Or (lat = "ERROR" Or lon = "ERROR"))
		GetLocation()
	If (lat = "ERROR" Or lon = "ERROR")
		Goto, Settings
	Run()
	If fullscreenmode
		SetTimer, FullScreenMode, 1000
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
	endtime =
	endtime += timer, seconds
	FormatTime, endtime, %endtime%, HH:mm:ss
	restorebrightness = %brightness%
	brightness = 1
	Menu, Tray, Uncheck, &Enabled
	Menu, Tray, Uncheck, &Disabled
	Menu, Tray, UnCheck, &Forced
	Menu, Tray, Check, &Paused
	Menu, Tray, Default, &Enabled
	Menu, Tray, Icon, %A_ScriptFullPath%, 2, 1
	Restore()
	TrayTip()
	timer -= 10
	SetTimer, Paused, 10000
Return

Paused:
	If (timer > 0 And mode = "paused") {
		timer -= 10
	} Else {
		SetTimer,, Delete
		If mode = paused
		{
			brightness = %restorebrightness%
			Goto, Enable
		}
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

ColorizeCursor:
	colorizecursor := !colorizecursor
	ColorizeCursor()
Return

CustomTimes:
	customtimes := !customtimes
	Goto, Restart
Return

FullScreen:
	fullscreenmode := !fullscreenmode
	If fullscreenmode
	{
		SetTimer, FullScreenMode, 1000
		Menu, Settings, Check, &Full-screen mode
	}
	Else
	{
		SetTimer, FullScreenMode, Delete
		Menu, Settings, Uncheck, &Full-screen mode
	}
Return

NoTransitions:
	If notransitions
	{
		notransitions = 0
		Menu, Settings, Uncheck, &No transitions
	}
	Else
	{
		notransitions = 1
		Menu, Settings, Check, &No transitions
	}
Return

Hotkeys:
	If hotkeys
	{
		hotkeys = 0
		Menu, Settings, Uncheck, &Optional hotkeys
	}
	Else
	{
		hotkeys = 1
		Menu, Settings, Check, &Optional hotkeys
	}
Return

RemoteDesktop:
	remotedesktop := !remotedesktop
	If remotedesktop
	{
		SetTimer, RemoteDesktopMode, 2500
		Menu, Settings, Check, &Remote Desktop support
	}
	Else
	{
		SetTimer, RemoteDesktopMode, Delete
		Menu, Settings, Uncheck, &Remote Desktop support
	}
Return

RunAsAdmin:
	runasadmin := !runasadmin
	Goto, Restart
Return

StartDisabled:
	startdisabled := !startdisabled
	If startdisabled
		Menu, Settings, Check, &Start disabled
	Else
		Menu, Settings, Uncheck, &Start disabled
Return

Traveling:
	traveling := !traveling
	Goto, Restart
Return

Settings:
	OnExit
	WriteSettings()
	FileGetTime, modtime, %ini%
	RunWait, %ini%
	FileGetTime, newmodtime, %ini%
	If newmodtime <> %modtime%
		Goto, Restart
	OnExit, OnExit
Return

CustomTimesMode:
	FormatTime, time,, HHmm
	If (daytime <= time And time < nighttime) {
		If (customnight Or mode = "") {
			customnight = 0
			If (mode = "" Or mode = "enabled")
				Goto, Disable
		}
	} Else If (!customnight) {
		customnight = 1
		If (mode = "" Or mode = "disabled")
			Goto, Enable
	}
Return

FullScreenMode:
	If mode <> enabled
		Return
	WinGet, id, ID, A
	WinGetClass, cls, ahk_id %id%
	WinGet style, Style, ahk_id %id%
	WinGetPos ,,, width, height, ahk_id %id%
	; 0x800000 is WS_BORDER
	; 0x20000000 is WS_MINIMIZE
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

RemoteDesktopMode:
	IfWinActive, ahk_class TscShellContainerClass
	{
		If !rdpclient
		{
			Hotkey, RAlt & `,, Off
			Hotkey, RAlt & ., Off
			Send, {Alt Up}{Ctrl Up}{RAlt Up}{RCtrl Up}
			Suspend, On
			Suspend, Off
			rdpclient = 1
		}
	}
	Else
	{
		Hotkey, RAlt & `,, On
		Hotkey, RAlt & ., On
		rdpclient = 0
	}
	If (RemoteSession() And !remote) {
		Menu, Tray, Disable, &Enabled
		Menu, Tray, Disable, &Forced
		Menu, Tray, Disable, &Paused
		Menu, Tray, Disable, &Disabled
		Menu, Tray, Tip, Redshift`nDisabled (Remote Desktop)
		Restore()
		remote = 1
	} Else If (!RemoteSession() And remote) {
		Menu, Tray, Enable, &Enabled
		Menu, Tray, Enable, &Forced
		Menu, Tray, Enable, &Paused
		Menu, Tray, Enable, &Disabled
		If mode = enabled
			Gosub, Enable
		If mode = forced
			Gosub, Force
		remote = 0
	}
Return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
Return

Restart:
	Run "%A_ScriptFullPath%" /restart
Return

OnExit:
	WriteSettings()
	Restore()
	ExitApp
Return

Exit:
	ExitApp

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
!PgUp::Brightness(0.05)
!PgDn::Brightness(-0.05)
<^>!Home::Goto, Force
<^>!End::Goto, Enable
<^>!PgUp::Temperature(100)
<^>!PgDn::Temperature(-100)

GetLocation() {
	try {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://ipapi.co/latlong", FALSE)
		whr.Send()
		response := whr.ResponseText
	}
	If (InStr(response, "Undefined") Or response = "") {
		If (lat = "ERROR" Or lon = "ERROR") {
			MsgBox, 308, Location Error
				, An error occurred while determining your location!`nChoose Yes to retry, or No to manually specify latitude and longitude.
			IfMsgBox Yes
				GetLocation()
			IfMsgBox No
				Gosub, Settings
		}
		Return
	}
	StringSplit, latlon, response, `,
	lat = %latlon1%
	lon = %latlon2%
}

WriteSettings() {
	IniWrite, %lat%, %ini%, %v%, latitude
	IniWrite, %lon%, %ini%, %v%, longitude
	IniWrite, %day%, %ini%, %v%, daytemp
	IniWrite, %night%, %ini%, %v%, nighttemp
	IniWrite, %fullscreen%, %ini%, %v%, fullscreentemp
	IniWrite, %pauseminutes%, %ini%, %v%, pauseminutes
	IniWrite, %daytime%, %ini%, %v%, daytime
	IniWrite, %nighttime%, %ini%, %v%, nighttime
	IniWrite, %colorizecursor%, %ini%, %s%, colorizecursor
	IniWrite, %customtimes%, %ini%, %s%, customtimes
	IniWrite, %fullscreenmode%, %ini%, %s%, fullscreenmode
	IniWrite, %notransitions%, %ini%, %s%, notransitions
	IniWrite, %hotkeys%, %ini%, %s%, optionalhotkeys
	IniWrite, %remotedesktop%, %ini%, %s%, remotedesktop
	IniWrite, %runasadmin%, %ini%, %s%, runasadmin
	IniWrite, %startdisabled%, %ini%, %s%, startdisabled
	IniWrite, %traveling%, %ini%, %s%, traveling
}

ColorizeCursor() {
	RegRead, mousetrails, HKCU\Control Panel\Mouse, MouseTrails
	If colorizecursor
	{
		If mousetrails <> -1
			RegWrite, REG_SZ, HKCU\Control Panel\Mouse, MouseTrails, -1
		Menu, Settings, Check, &Colorize cursor
	}
	Else
	{
		If mousetrails = -1
			RegDelete, HKCU\Control Panel\Mouse, MouseTrails
		Menu, Settings, Uncheck, &Colorize cursor
	}
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
	{
		If customtimes
			cfg = -O %ntmp% %br%
		Else
			cfg = -l %lat%:%lon% -t %day%:%ntmp% %br% %notr%
	}
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
	{
		If customtimes
			status := "Enabled until " . SubStr(daytime, 1, 2) . ":" . SubStr(daytime, 3) . " (" . night . "K)"
		Else
		{
			latitude := Round(Abs(lat), 2) . "°" . (lat > 0 ? "N" : "S")
			longitude := Round(Abs(lon), 2) . "°" . (lon > 0 ? "E" : "W")
			status = Enabled: %night%K/%day%K`nLocation: %latitude% %longitude%
		}
	}
	Else If mode = forced
		status = Forced: %temperature%K
	Else If mode = paused
		status = Paused until %endtime%
	Else
	{
		status = Disabled
		if customtimes
			status .= " until " . SubStr(nighttime, 1, 2) . ":" . SubStr(nighttime, 3)
	}
	br := Round(brightness * 100, 0)
	Menu, Tray, Tip, Redshift`n%status%`nBrightness: %br%`%
	If (!isfullscreen And (A_ThisHotkey <> A_PriorHotkey Or (InStr(A_ThisHotkey, "Pg") And A_TimeSinceThisHotkey < 2500))) {
		Tooltip, %status%`nBrightness: %br%`%
		SetTimer, RemoveToolTip, 1000
	}
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

#If, hotkeys And !WinActive("ahk_class TscShellContainerClass")
<^LWin::WinRunDialog()
<^>!9::WinSet, AlwaysOnTop, Toggle, A
<^>!0::ClickThroughWindow()
<^>!-::Opacity(-5)
<^>!=::Opacity(5)
RAlt & ,::ShiftAltTab
RAlt & .::AltTab
RAlt::
	If (!ralt And A_PriorHotkey = A_ThisHotkey And A_TimeSincePriorHotkey < 400) {
		ralt = 1
		SetTimer, RAltReset, 400
		If (WinActive("ahk_class Chrome_WidgetWin_1") Or WinActive("ahk_class IEFrame")
			Or WinActive("Microsoft Edge") Or WinActive("ahk_class MozillaWindowClass"))
			Send ^{F4}
		Else IfWinActive, ahk_class TTOTAL_CMD
			Send ^w
		Else
			Send !{F4}
	} Else {
		ralt = 0
	}
Return
AppsKey & Up::Send #{Up}
AppsKey & Down::Send #{Down}
AppsKey & Left::Send #{Left}
AppsKey & Right::Send #{Right}
AppsKey & Home::Shutdown, 2
AppsKey & End::DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
AppsKey & ,::Send {Media_Prev}
AppsKey & .::Send {Media_Next}
AppsKey & /::Send {Media_Play_Pause}
AppsKey & m::Send {Volume_Mute}
AppsKey & p::Send #p
AppsKey::Send {AppsKey}
>^Up::Send {Volume_Up}
>^Down::Send {Volume_Down}
>^AppsKey::WinRunDialog()

#If, hotkeys And MouseOnTaskbar()
~LButton::ShowDesktop()
MButton::TaskMgr()
WheelUp::Send {Volume_Up}
WheelDown::Send {Volume_Down}

#If, hotkeys And remotedesktop And WinActive("ahk_class TscShellContainerClass")
>^Up::SetVolume("+1")
>^Down::SetVolume("-1")

#If, hotkeys And !RemoteSession()
RCtrl::
	If (!rctrl And A_PriorHotkey = A_ThisHotkey And A_TimeSincePriorHotkey < 400) {
		rctrl = 1
		SetTimer, RCtrlReset, 400
		Sleep, 50
		IfWinActive, ahk_class TscShellContainerClass
			WinMinimize
		Else IfWinExist, ahk_class TscShellContainerClass
			WinActivate
	} Else {
		rctrl = 0
	}
Return

RAltReset:
	ralt = 0
	SetTimer,, Delete
Return

RCtrlReset:
	rctrl = 0
	SetTimer,, Delete
Return

MouseOnTaskbar() {
	MouseGetPos,,, id
	Return WinExist("ahk_id" . id . " ahk_class Shell_TrayWnd")
}

SetVolume(value) {
	SoundSet, %value%
	SoundGet, volume
	Tooltip, % Round(volume)`%
	SetTimer, RemoveToolTip, 1000
	SoundGet, mute,, mute
	If mute = On
		SoundSet, 0,, mute
}

RemoteSession() {
	SysGet, isremote, 4096
	Return isremote > 0
}

WinRunDialog() {
	If (rundialog <> "" And WinExist("ahk_id" . rundialog)) {
		IfWinActive, ahk_id %rundialog%
		{
			Send !{Esc}
			WinClose, ahk_id %rundialog%
			rundialog =
		}
		Else
			WinActivate, ahk_id %rundialog%
	} Else {
		Send #r
		WinWait, ahk_class #32770 ahk_exe explorer.exe
		If !ErrorLevel
			WinActivate
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
	If (A_PriorHotkey = A_ThisHotkey And A_TimeSincePriorHotkey < 400 And WinActive("ahk_class Shell_TrayWnd")) {
		MouseGetPos,,,, control
		If control = MSTaskListWClass1
			Send #d
		Sleep, 250
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
