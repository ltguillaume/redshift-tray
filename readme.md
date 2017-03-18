<img src="https://github.com/ltGuillaume/Redshift-Tray/blob/master/Icons/redshift.ico" align="right"/>

# Redshift Tray
[Redshift Tray](https://github.com/ltGuillaume/Redshift-Tray) by ltGuillaume  
[Redshift](http://jonls.dk/redshift) by [Jon Lund Steffensen](https://github.com/jonls) 

## Overview
Redshift Tray is a no-frills GUI for the excellent screen temperature adjustment tool [Redshift](http://jonls.dk/redshift) by Jon Lund Steffensen. Redshift Tray allows you to:

- Quickly enable/disable Redshift: double-click the tray icon
- Force a full nighttime temperature adjustment, no matter what the actual time is
- Pause the temperature adjustment for x minutes
- Adjust the screen brightness and forced temperature via hotkeys
- Optionally update your current coordinates every time you enable Redshift (e.g. when traveling)

It also includes a set of optional hotkeys. Admittedly, these are entirely based on my personal preferences, but since this program is put together in [AutoHotkey](http://www.autohotkey.com), it's easy to add your own hotkeys and remove the ones you think are rubbish.

## Getting started
1. Download Redshift Tray from the [releases page](https://github.com/ltGuillaume/Redshift-Tray/releases) and extract it to a folder you really like.
2. Run __rstray.exe__ and you'll see a handsome icon pop up in the notification area next to your clock. Now right-click it and choose __Settings__. The text file __rstray.ini__ that shows up in your editor contains all the settings for Redshift Tray.
    - For accurate coordinates, you can set them yourself, otherwise it uses your IP and the [ipapi](https://ipapi.co) service (__one time only__). Use a <a href="https://encrypted.google.com/search?q=Amsterdam+coordinates">search engine</a>, Maps, Wikipedia, or whatever and jot down your coordinates behind __longitude=__ and __latitude=__.
    - During the day, the color temperature should match the light from outside, typically around 5500K-6500K. The light has a higher temperature on an overcast day. Redshift assumes that your screen will produce light at a color of 6500K when no color correction is applied by the program. Thus, 6500K is the neutral temperature. The __daytemp__ setting helps you set this value (e.g. __daytemp=6500__).
    - At night, the color temperature should be set to match the lamps in your room. This is typically a low temperature at around 3000K-4000K. The __nighttemp__ setting helps you out here (e.g. __nighttemp=4000__).
    - You can temporarily disable Redshift's color adjustment for a few (or a whole lotta) minutes. Set the amount of those hella blue minutes with the __pauseminutes__ setting.
    - Traveling with your laptop? You can set __traveling=1__ after which the coordinates will be updated every time Redshift is enabled. It'll keep its mouth shut if there's no Internet connection, though.
    - If you get annoyed by the fact that your mouse cursor does not assume the same color temperature, set __colorizecursor=1__ and Redshift Tray will write _MouseTrails=-1_ to _HKCU\Control Panel\Mouse_ in your registry to fix this. You'll need to save and exit the config file, then __restart Windows or log off__ to get this working.
    - The setting __optionalhotkeys=1__ will enable the extra set of hotkeys (right-click the tray icon and choose __Hotkeys__ to see a list), while (big surprise) __optionalhotkeys=0__ disables them. The _Hotkeys List_ dialog's yes/no buttons control this setting.
    - If you want to use the (default and/or optional) hotkeys when a program that runs as admin (has elevated privileges) is the active window, set __runasadmin=1__ so that Redshift Tray will try to run as admin, too. If this scenario doesn't really occur on your system, leave the damn thing alone.
3. Now save the settings file and close it. Redshift Tray will restart with the settings you've defined.
4. If you'd like Redshift Tray to automatically run at startup, right-click the tray icon again and click __Autorun__, so that this option is checked. This setting just creates or removes a value in the registry key _HKCU\Software\Microsoft\Windows\CurrentVersion\Run_.
5. If Redshift [fails to adjust the color temperature](http://jonls.dk/2010/09/windows-gamma-adjustments), or the brightness level gets stuck at a certain percentage, import __unlock-gammarange.reg__ into the registry and restart Windows.

You. Are. Done!

## Credits
* Icon created from a damn good [design](http://www.laytondiament.com/blog/2015/5/3/design-chill-sunset-icon) by [Layton Diament](http://www.laytondiament.com)  
* [AutoHotkey](https://www.autohotkey.com), a scripting language for desktop automation by Chris Mallet and others.  
* [Redshift](http://jonls.dk/redshift) by [Jon Lund Steffensen](https://github.com/jonls)
