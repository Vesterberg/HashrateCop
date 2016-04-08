#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;This is what I need: 

/*QT miner auto restart if the hash rates stall - usually see this on my screen as no hash rates and solution text keeps appearing and being submitted but not actually counted by the pool. 

todo: output reading

Solution idea:
start script
Ask, write hashrateGoal, or wait 5 seconds to use current setting: 
save hashrateGoal variable persistently 
use the saved hashrateGoal
wait 60 seconds for the mining to start
timer every 2 seconds do this:
	get QTminer CMD window output
	read latest QTminer CMD window output 
	if hashrate > hashrateGoal
		restart QTminer
	if "Host not found"
		wait x minutes
		if "host not found"
			force system restart


 if internet connection is lost, "Stratum Connection Error: Host not found", it should wait x minutes before restarting the pc
 

*/


/*Autostart on startup - if the computer is shut down and restarts, I want QTminer command line (with the server connection & my address ) to be executed to start mining. 

ALMOST DONE! just make it run once instead of on hotkey
*/


/*If possible, force restart on the system is QTMiner script is not able to restart the hashing - this would restart the computer and autoload the script to start QTminer again and begin hashing.

Solution ideas:

1:
Start script
restartCounter starts at 0
start qtminer for the first time
wait 3 minutes
checks hashrate
hashrate too low
Must restart QT miner: run QTminer restart routine 
restartsCounter + 1 

If restartcounter < 3
	force system restart

2:
every 5 seconds:
If QTminer.exe unresponsive
	kill QTminer.exe process
Must restart QT miner: run QTminer restart routine 
wait 30 seconds
If QTminer.exe unresponsive - check using the window name, or some other way
	restart system
*/



;Is this doable ? 
;How long do you think this would take ? 
;What do you feel is fair compensation for this in Eth ?


;set shortcut to script in startup folder
;A_Startup
/*
#1:: ; Win+1 makes a shortcut of the selected file in the startup folder
sel := Explorer_GetSelected()
InputBox, vOutBox, Rename, Enter New Shortcut Name, , 180, 135
if errorlevel <> 0
    return
FileCreateShortcut, %sel%, %A_Startup%/%vOutBox%.lnk
run, %A_Startup%
return
*/
;http://www.autohotkey.com/board/topic/60985-get-paths-of-selected-items-in-an-explorer-window/
;thanks Rapte_Of_Suzaku
/*
	Library for getting info from a specific explorer window (if window handle not specified, the currently active
	window will be used).  Requires AHK_L or similar.  Works with the desktop.  Does not currently work with save
	dialogs and such.
	
	
	Explorer_GetSelected(hwnd="")   - paths of target window's selected items
	Explorer_GetAll(hwnd="")        - paths of all items in the target window's folder
	Explorer_GetPath(hwnd="")       - path of target window's folder
	
	example:
		F1::
			path := Explorer_GetPath()
			all := Explorer_GetAll()
			sel := Explorer_GetSelected()
			MsgBox % path
			MsgBox % all
			MsgBox % sel
		return
	
	Joshua A. Kinnison
	2011-04-27, 16:12
*/
/*
Explorer_GetPath(hwnd="")
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
		return A_Desktop
	path := window.LocationURL
	path := RegExReplace(path, "ftp://.*@","ftp://")
	StringReplace, path, path, file:///
	StringReplace, path, path, /, \, All 
	
	; thanks to polyethene
	Loop
		If RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
		Else Break
	return path
}
Explorer_GetAll(hwnd="")
{
	return Explorer_Get(hwnd)
}
Explorer_GetSelected(hwnd="")
{
	return Explorer_Get(hwnd,true)
}

Explorer_GetWindow(hwnd="")
{
	; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%
	
	if (process!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
}
Explorer_Get(hwnd="",selection=false)
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
	{
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
		if !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop
		Loop, Parse, files, `n, `r
		{
			path := base "\" A_LoopField
			IfExist %path% ; ignore special icons like Computer (at least for now)
				ret .= path "`n"
		}
	}
	else
	{
		if selection
			collection := window.document.SelectedItems
		else
			collection := window.document.Folder.Items
		for item in collection
			ret .= item.path "`n"
	}
	return Trim(ret,"`n")
}
*/
1::
SplitPath, A_Scriptname, , , , OutNameNoExt 
LinkFile=%A_Startup%\%OutNameNoExt%.lnk 
IfNotExist, %LinkFile% 
  FileCreateShortcut, %A_ScriptFullPath%, %LinkFile% 
SetWorkingDir, %A_ScriptDir%