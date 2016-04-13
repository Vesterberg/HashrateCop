;Written by Jakob Vesterberg, Username Vesterberg on github
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
SetKeyDelay, -1

/*
Autostart on startup - if the computer is shut down and restarts, I want QTminer command line (with the server connection & my address ) to be executed to start mining. 
DONE
*/


HashrateCopVersion=HashrateCop 1.0
;------------------------------------Autostart-on-OS-bootup-shortcut-generation--------------------
; Next 5 lines makes sure that there will always be a shortcut in the startup folder that starts the script on every OS bootup
SplitPath, A_Scriptname, , , , OutNameNoExt 
LinkFile=%A_Startup%\%OutNameNoExt%.lnk 
IfNotExist, %LinkFile% 
  FileCreateShortcut, %A_ScriptFullPath%, %LinkFile% 
SetWorkingDir, %A_ScriptDir%

;------------------------------------PERMANENT-SETTINGS-FIRST-TIME-SETUP---------------------------

IfNotExist, HashrateCopSettings.ini 																			; writes default hashrate goal settings to .ini file if no .ini file exists
{
	hashrateMinimumDefaultValue := 500000
	IniWrite, % hashrateMinimumDefaultValue, % A_ScriptDir "\HashrateCopSettings.ini", Section, hashrateMinimumCurrentlyUsedValueKey
	etheraddress := 0x2d96cefbdec4c5a6ea88d9496fdeddefa561adcd
	IniWrite, % etheraddress, % A_ScriptDir "\HashrateCopSettings.ini", Section, usersEtheraddress 
	IniWrite, 0x2d96cefbdec4c5a6ea88d9496fdeddefa561adcd, % A_ScriptDir "\HashrateCopSettings.ini", Section, developersEtheraddress
	IniWrite, 5, % A_ScriptDir "\HashrateCopSettings.ini", Section, MaximumMinerAppRestartsIfHashrateTooLow 
	minutesOfNoStratumConnectionErrorsBeforeRestart:=5
	IniWrite, % userInputminutesOfNoStratumConnectionBeforeRestart, % A_ScriptDir "\HashrateCopSettings.ini", Section, minutesOfNoStratumConnectionErrorsBeforeRestart
}

;------------------------------------STARTUP-WELCOME-----------------------------------------------
MsgBox, ,  %HashrateCopVersion% ,Press Ctrl+Esc at any time to stop script and close QtMiner `n2 percent of every 2 hours is spent donation mining to support development`n `nMade by Jakob Vesterberg "Vesterberg" on github , 3  

;------------------------------------CHANGE-PERMANENT-SETTINGS-PROMPT------------------------------
MsgBox, 4, %HashrateCopVersion%, Do you want to change the permanent settings? (press Yes/No or wait 5 seconds), 3  
IfMsgBox Yes
{
	showSettingsPrompts = 1 
}
IfMsgBox Timeout
{
	showSettingsPrompts = 0
} 

;------------------------------------PERMANENT-HASHRATE-SETTING------------------------------------
IniRead, hashrateMinimumCurrentlyUsedValue, HashrateCopSettings.ini, section, hashrateMinimumCurrentlyUsedValueKey

if (showSettingsPrompts = 1)
{
	InputBox, hashrateMinimumNewValue, Hashrate goal, What is your minimum Hashrate goal? Input goal or press Enter to use previously saved goal, , , , , , , 4

	if (hashrateMinimumNewValue != "") 																				;Inputbox sets variables even if user input is "" (empty) after the timeout, this variable exchange prevents that issue from deleting the previous hashrate minimum setting
	{
		hashrateMinimumCurrentlyUsedValue = %hashrateMinimumNewValue% 
	}
	 
	IniWrite, % hashrateMinimumCurrentlyUsedValue, % A_ScriptDir "\HashrateCopSettings.ini", Section, hashrateMinimumCurrentlyUsedValueKey

	MsgBox, , %HashrateCopVersion%, HashrateCop sets this as minimum hashrate: "%hashrateMinimumCurrentlyUsedValue%" H/s , 
}
;------------------------------------PERMANENT-ETHERADDRESS-SETTING--------------------------------
IniRead, etheraddress, HashrateCopSettings.ini, section, usersEtheraddress

if (showSettingsPrompts = 1)
{
	InputBox, userInputEtherAddress, Ether address, Copypaste your Ether address here or press Enter to use previously saved Ether address, , , , , , , 

	if (userInputEtherAddress != "") 																				;Inputbox sets variables even if user input is "" (empty) after the timeout, this variable exchange prevents that issue from deleting the previous hashrate minimum setting
	{
		etheraddress = %userInputEtherAddress% 
	}

	IniWrite, % etheraddress, % A_ScriptDir "\HashrateCopSettings.ini", Section, usersEtheraddress

	MsgBox, , %HashrateCopVersion%, Miner uses this ether address "%etheraddress%" , 
}
;------------------------------------PERMANENT-MAX-APP-RESTARTS-SETTING----------------------------
IniRead, userInputMaximumMinerAppRestarts, HashrateCopSettings.ini, section, MaximumMinerAppRestartsIfHashrateTooLow

if (showSettingsPrompts = 1)
{
	InputBox, MaximumMinerAppRestartsInputbox, Max miner relaunches, Type the maximum allowed miner application relaunches because of low hashrate before the OS reboots, or press Enter to use previously saved value, , , , , , , 

	if (MaximumMinerAppRestartsInputbox != "") 																		;Inputbox sets variables even if user input is "" (empty) after the timeout, this variable exchange prevents that issue from deleting the previous hashrate minimum setting
	{
		userInputMaximumMinerAppRestarts = %MaximumMinerAppRestartsInputbox% 
	} 

	IniWrite, % userInputMaximumMinerAppRestarts, % A_ScriptDir "\HashrateCopSettings.ini", Section, MaximumMinerAppRestartsIfHashrateTooLow

	MsgBox, , %HashrateCopVersion%, The miner app will restart "%userInputMaximumMinerAppRestarts%" times before resorting to rebooting the computer , 
} 
;------------------------------------PERMANENT-MAX-APP-RESTARTS-SETTING----------------------------
IniRead, userInputminutesOfNoStratumConnectionBeforeRestart, HashrateCopSettings.ini, section, minutesOfNoStratumConnectionErrorsBeforeRestart

if (showSettingsPrompts = 1)
{
	InputBox, minutesOfNoStratumConnectionBeforeRestartInputbox, Stratum Disconnect timer, How many minutes should the miner wait before restarting the OS because of stratum connection errors? Input value, or press Enter to use previously saved value, , , , , , , 

	if (minutesOfNoStratumConnectionBeforeRestartInputbox != "") 																		;Inputbox sets variables even if user input is "" (empty) after the timeout, this variable exchange prevents that issue from deleting the previous hashrate minimum setting
	{
		userInputminutesOfNoStratumConnectionBeforeRestart = %minutesOfNoStratumConnectionBeforeRestartInputbox% 
	} 

	IniWrite, % userInputminutesOfNoStratumConnectionBeforeRestart, % A_ScriptDir "\HashrateCopSettings.ini", Section, minutesOfNoStratumConnectionErrorsBeforeRestart

	MsgBox, , %HashrateCopVersion%, The miner app will wait "%userInputminutesOfNoStratumConnectionBeforeRestart%" minutes before resorting to rebooting the computer , 
}
;------------------------------------Variables-shared-between-lower-code-sections------------------
; Variables used by multiple parts of the code sections below are written in the next few lines, before the SetTimer, Label [, Period|On|Off] calls. It ended up like this because I messed around with the timer feature earlier.

connectionErrorAndFindHashrateCompareTimerInterval=4000														
minutesOfNoStratumConnectionBeforeRestart = 5																						; timers are not precise, its a rough estimate
triesPerSetMinutes := minutesOfNoStratumConnectionBeforeRestart*(60000/connectionErrorAndFindHashrateCompareTimerInterval)
maximumMinerAppRestarts := userInputMaximumMinerAppRestarts																			; Maximum miner application restarts because of Hashrate issues

SetTimer, startMining, 7127000
SetTimer, consoleOutputCheck, 4000
;------------------------------------START-QT-MINER------------------------------------------------ 
startMining:
 	developerfundMining=1                                                                                       
    Process, Exist, qtminer.exe
    If ErrorLevel <> 0
    {
		IfWinExist,  ahk_exe QtMiner.exe
	    {
	    	WinKill ; use the window found above
	    }
    }
    Run "qtminer.exe" -s us1.ethermine.org:4444 -u 0x2d96cefbdec4c5a6ea88d9496fdeddefa561adcd.stratum -G --cl-global-work 16384
  	sleep, 72000
  	developerfundMining=0
  	Process, Exist, qtminer.exe
    If ErrorLevel <> 0
    {
		IfWinExist,  ahk_exe QtMiner.exe
	    {
	    	WinKill ; use the window found above
	    }
    }
    Run "qtminer.exe" -s us1.ethermine.org:4444 -u %etheraddress%.stratum -G --cl-global-work 16384
Return

;------------------------------------CONSOLE-OUTPUT------------------------------------------------
; get the Console Output
consoleOutputCheck:
  if (developerfundMining=0)
  {
    if (firstConsoleOutput="")
    {
      sleep, 10000
    }
      WinActivate ahk_exe QtMiner.exe                                   ; go to our console window

      ClipBoard =                                                       ; empty ClibBoard to see data comming

      Send !{Space}es{Enter}                                            ; select all = used buffer, copy to clipboard

      ClipWait 2                                                        ; don't hang here at an error

    ClipBoardCMDoutput = %ClipBoard%                                    ; Save CMD output to string LatestCMDoutput

    if (ClipBoardCMDoutput != "")                                       ; creates the newLinesCMDoutput variable with the new command lines written by the console application since the last check
    {
      if(firstConsoleOutput="")
      {
        StringTrimLeft, newLinesCMDoutput, ClipBoardCMDoutput, 1275
        firstConsoleOutput=1
      }
      Else
      { ; Code in the following bracket grabs the newest 6 cmd lines
        StringLen, StringLengthOfOldCMDoutput, oldCMDoutput
        StringLen, StringLengthOfClipBoardCMDoutput, ClipBoardCMDoutput
        StringLengthDeletedToGetNewest3Lines:=StringLengthOfClipBoardCMDoutput-370
        StringTrimLeft, newLinesCMDoutput, ClipBoardCMDoutput, StringLengthDeletedToGetNewest3Lines
      }
      oldCMDoutput:=newLinesCMDoutput
      newLinesCMDoutputNotSearched=1
    }
    Else
    {
      Goto consoleOutputCheck
    }

    ;------------------------------------FINDS-LATEST-HASHRATE-COMPARE-TO-MINIMUM----------------------
    ; finds the latest hashrate (added to variable latestHashrate) and compares it to minimum hashrate goal
    
    if (newLinesCMDoutputNotSearched = 1)                                         ; creates the newLinesCMDoutput variable with the new command lines written by the console application since the last check
    {
      RegExMatch(newLinesCMDoutput, "\d+" " H/s = ", match)                       ; finds the latest hashrate in the CMD output
      StringTrimRight, latestHashrate, match, 7

      If (hashrateMinimumCurrentlyUsedValue > latestHashrate) && (latestHashrate != "")
      {
        hashratestrikeCounter+=1

        if(hashratestrikeCounter > 5)
        {
          Process, Exist, QTminer.exe
          If ErrorLevel <> 0
          {
              IfWinExist,  ahk_exe QtMiner.exe
              {
                WinKill ; use the window found above
              }
            Run "qtminer.exe" -s us1.ethermine.org:4444 -u 0x2d96cefbdec4c5a6ea88d9496fdeddefa561adcd.stratum -G --cl-global-work 16384
            QTminerRestartCounter+=1
            hashratestrikeCounter=0
          }
      	}
      }	
      Else
      {
      	hashratestrikeCounter=0
      }

      If (QTminerRestartCounter > triesPerSetMinutes) OR (QTminerRestartCounter > maximumMinerAppRestarts)
      {
      	MsgBox, , %HashrateCopVersion%, Restarting OS in 5 seconds , 5
        Shutdown, 6 ; Force OS restart
      }

      ;------------------------------------STRATUM-CONNECTION-ERROR-CHECK--------------------------------
      ; start looking for stratum connection error messages
      ; this will look for connection error messages in the newest chunk of command line output. It will check every 30 seconds  for up to X minutes. It will restart the computer if error messages still appear after 6 minutes. Timer time period 30 seconds * 12 tries = 6 minutes. Timer time period is written in the line where the timer is called.
      connectionErrorMessage = Stratum Connection Error: Host not found

      IfInString, newLinesCMDoutput, %connectionErrorMessage%
      {
        stratumCheckCounter += 1
        if (stratumCheckCounter > triesPerSetMinutes)
        {
        	MsgBox, , %HashrateCopVersion%, Restarting OS in 5 seconds , 5
          	Shutdown, 6                                             ; Force OS restart
        }
      }
      Else
      {
      	stratumCheckCounter=0
      }
      newLinesCMDoutputNotSearched = 0
    }
  }
Return




/*
QT miner auto restart if the hash rates stall - usually see this on my screen as no hash rates and solution text keeps appearing and being submitted but not actually counted by the pool. 
DONE
If possible, force restart on the system is QTMiner script is not able to restart the hashing - this would restart the computer and autoload the script to start QTminer again and begin hashing.
DONE
*/
/*
 if internet connection is lost, "Stratum Connection Error: Host not found", it should wait x minutes before restarting the pc
DONE, set to 5 minutes
*/

^Esc::
    Process, Exist, qtminer.exe
    If ErrorLevel <> 0
    {
		IfWinExist,  ahk_exe QtMiner.exe
	    {
	    	WinKill ; use the window found above
	    }
    }
ExitApp