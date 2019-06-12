<img src="https://github.com/ltGuillaume/Redshift-Tray/blob/master/Icons/redshift.ico" align="right"/>

# Redshift Tray
[Redshift Tray](https://github.com/ltGuillaume/Redshift-Tray) by ltGuillaume  
[Redshift](https://github.com/jonls/redshift) by [Jon Lund Steffensen](https://github.com/jonls) 

## Overview
Redshift Tray is a no-frills GUI for the excellent screen temperature adjustment tool [Redshift](https://github.com/jonls/redshift) by Jon Lund Steffensen. Redshift Tray allows you to:

- Control Redshift based on location or custom night/day times
- Quickly enable/disable Redshift: double-click the tray icon
- Force a full nighttime temperature adjustment, no matter what the actual time is
- Pause the temperature adjustment for x minutes
- Adjust the screen brightness and forced temperature via hotkeys
- Optionally update your current coordinates every time you enable Redshift (e.g. when traveling)
- Use a fantastic set of extra hotkeys that have got nothing to do with Redshift
- Make use of Remote Desktop: Redshift hotkeys will stay active locally, while Redshift Tray can also run on the remote system for its optional hotkeys

It also includes a set of extra hotkeys. Admittedly, these are entirely based on my personal preferences, but since this program is put together in [AutoHotkey](http://www.autohotkey.com), it's easy to add your own hotkeys and remove the ones you think are rubbish.

## List of hotkeys

__Hotkeys__ | &nbsp;
:---: |---
Alt Home | Reset gamma (again to reset brightness)
Alt Pause | Toggle pause for %pauseminutes% minutes
Alt End | Disable Redshift
Alt PgUp | Increase brightness
Alt PgDn | Decrease brightness
AltGr Home | Force night temperature (again to reset brightness)
AltGr End | End forced temperature
AltGr PgUp | Increase forced temperature
AltGr PgDn | Decrease forced temperature
__Extra Hotkeys__ | &nbsp;
LCtrl LWin | Type to run
RWin | 
RCtrl Menu | 
LCtrl LWin x2 | Windows Run dialog
RWin x2 | 
RCtrl Menu x2 | 
AltGr 9 | Toggle window on top click-through
AltGr 0 | Toggle window always on top
AltGr - | Increase window transparency
AltGr = | Decrease window transparency
AltGr . | Switch between open items (Alt Tab)
AltGr , | Switch between open items (Shift Alt Tab)
AltGr x2 | Close current tab/window
Menu + Arrows | Aero Snap
Menu Pause | Suspend computer
Menu Home | Restart computer
Menu End | Hibernate computer
Menu P | Presentation display mode
Menu , | MM: Previous
Menu . | MM: Next
Menu / | MM: Stop
Menu Shift | MM: Play/Pause
Menu M | MM: Mute
RCtrl Up | MM: Volume up
RCtrl Down | MM: Volume down
Wheel on taskbar | MM: Volume up/down
DblClick on taskbar | Show desktop
MidClick on taskbar | Open Task Manager
RCtrl x2 | Switch between RDP host/client

## Getting started
1. Download Redshift Tray from the [releases page](https://github.com/ltGuillaume/Redshift-Tray/releases) and extract it to a folder you really like. Alternatively, you can [install via Chocolatey](https://chocolatey.org/packages/rstray) (repo is maintained by [dimqua](https://github.com/dimqua), thanks!).
2. Run __rstray.exe__ and you'll see a handsome icon pop up in the notification area next to your clock. Now right-click it and choose __Settings__. You can quickly switch some features on/off, or choose __More Settings__. The text file __rstray.ini__ that shows up in your editor contains all the settings for Redshift Tray.
    - For accurate coordinates, you can set them yourself, otherwise it uses your IP and the [ipapi](https://ipapi.co) service (__one time only__). Use a <a href="https://encrypted.google.com/search?q=Amsterdam+coordinates">search engine</a>, Maps, Wikipedia, or whatever and jot down your coordinates behind __latitude__ and __longitude__.
    - During the day, the color temperature should match the light from outside, typically around 5500K-6500K. The light has a higher temperature on an overcast day. Redshift assumes that your screen will produce light at a color of 6500K when no color correction is applied by the program. Thus, 6500K is the neutral temperature. The __daytemp__ setting helps you set this value (e.g. __daytemp=6500__).
    - At night, the color temperature should be set to match the lamps in your room. This is typically a low temperature at around 3000K-4000K. The __nighttemp__ setting helps you out here (e.g. __nighttemp=3500__).
    - Redshift Tray can check if the active window is in full-screen mode and automatically switch to a different color temperature (useful for image viewers and video players). Set the __fullscreentemp__ to your preferred value and enable this feature with __fullscreenmode=1__.
    - You can temporarily disable Redshift's color adjustment for a few (or a whole lotta) minutes. Set the amount of those hella blue minutes with the __pauseminutes__ setting.
    - If you want total control over the times at which Redshift will be enabled and disabled, just set __nighttime=1800__ and __daytime=0600__, where the values depict 24h military time. Then, set __customtimes=1__.
    - If you get annoyed by the fact that your mouse cursor does not assume the same color temperature, set __colorizecursor=1__ and Redshift Tray will write _MouseTrails=-1_ to _HKCU\Control Panel\Mouse_ in your registry to fix this. You'll need to save and exit the config file, then __restart Windows or log off__ to get this working.
    - The setting __hotkeys=1__ will enable the set of hotkeys, while (big surprise) __hotkeys=0__ disables them. Similarly, you can control the extra set of hotkeys with the entry __extrahotkey__.
    - With __keepbrightness=1__ you can apply the brightness setting even when you disable the gamma adjustment (when paused or disabled). This could help if your monitor starts humming or flickering with a low backlight brightness. You will lose some "color space", though.
    - If you have loaded an ICC profile or have done a custom display calibration (Control Panel > Color Management > Advanced), Redshift might interfere with this. As such, you can set __keepcalibration=1__ to have Redshift Tray keep that into account. This will, however, require Redshift Tray to run as administrator (it will take care of that for you).
    - If you loathe the fading transition upon start-up, just set __notransitions=1__.
    - If you're a Remote Desktop addict like me, be sure to set __remotedesktop=1__. This way, you can run this gem in both environments, switch between local and remote sessions by double-tapping RCtrl, and change the local Redshift settings while in a remote screen.
    - If you want to use the (default and/or extra) hotkeys when a program that runs as admin (has elevated privileges) is the active window, set __runasadmin=1__ so that Redshift Tray will try to run as admin, too. If this scenario doesn't really occur on your system, leave the damn thing alone.
    - If you don't want Redshift to be enabled on start-up (because you just want to use the fancy hotkeys, for example), set __startdisabled=1__.
    - Traveling with your laptop? You can set __traveling=1__ after which the coordinates will be updated every time Redshift is enabled. It'll keep its mouth shut if there's no Internet connection, though. Since the location is based on your IP, don't use this when a VPN is active.
3. Now save the settings file and close it. Redshift Tray will restart with the settings you've defined.
4. If you'd like Redshift Tray to automatically run at startup, right-click the tray icon again and click __Autorun__ under __Settings__, so that this option is checked. This setting just creates or removes a value in the registry key _HKCU\Software\Microsoft\Windows\CurrentVersion\Run_.
5. If Redshift [fails to adjust the color temperature](http://jonls.dk/2010/09/windows-gamma-adjustments), or the brightness level gets stuck at a certain percentage, import __unlock-gammarange.reg__ into the registry and restart Windows.

You. Are. Done!

## Credits
* Icon created from a damn good [design](http://www.laytondiament.com/blog/2015/5/3/design-chill-sunset-icon) by [Layton Diament](http://www.laytondiament.com)  
* [AutoHotkey](https://www.autohotkey.com), a scripting language for desktop automation by Chris Mallet and others.  
* [Redshift](https://github.com/jonls/redshift) by [Jon Lund Steffensen](https://github.com/jonls)
