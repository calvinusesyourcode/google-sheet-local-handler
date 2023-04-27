#Requires AutoHotkey v2.0
#Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir A_WorkingDir  ; Ensures a consistent starting directory.
#SingleInstance

DetectHiddenWindows 1
SetTitleMatchMode 2
SetNumLockState "AlwaysOn"


numpad := False
pedalboard := False
abletonKeys := False


interface_script := "https://script.google.com/macros/s/AKfycbzEf0u9O8sfEvpE47iGBnZ1PaFtahbZvNp57sDz3wQ6HGeWdQjyHm8G7wS1vPRXiCPI/exec"
interface_json := "?sheetid=%221cOyI1cq8rm85hJk0SuNahlMUaLps5N5Z4DHW3q1tzWQ%22"

Backspace::{ 
	SendText "exit"
	Sleep 10
	Send "{Enter}"
	Run "C:\Users\calvi\OneDrive\Documents\ffmpeg test\converted"
	Tooltip
	Hotkey("Backspace", "Off")
}


Hotkey("Backspace", "Off")

^+!k::{
	audio_folder := "C:\Users\calvi\OneDrive\Documents\ffmpeg test"
	ffmpeg_cmd := 'for %i in (*.wav) do ffmpeg -i "%i" -y -aq 5 "' . audio_folder . '\converted\%~ni_converted.mp3"'
	Run A_ComSpec
		Sleep 300
		SendText "cd " . audio_folder
		Send "{Enter}"
		Sleep 10
		SendText ffmpeg_cmd
		Send "{Enter}"
	Tooltip "Press Backspace"
	Hotkey("Backspace", "On")
}

Tab::{
Send "    "
}

Hotkey "Tab", "Off"

+^!a::{
Hotkey "Tab", "On"
userText := InputBox("delimit values with qq`rfirst item is app`rpermitted characters: ' , ?  .  ! @ - _ () [] {} / * : `; <> $`rNOT: % # & '' " , "CUSTOM ENTRY","W400 H160",).value
app_map := Map(
	"t" , "thoughts",
	"a" , "activity",
	"j" , "journal",
	"2" , "todo",
	"to", "todo",)
if userText {
	try {
		app := SubStr(userText,1,InStr(userText,"    ")-1)
		userText := SubStr(userText,InStr(userText,"    ")+4)
		if app_map.Has(app)
		app := app_map[app]
	} catch {
		app := "test"
	}
url := interface_script . interface_json . "&app=%22" . app . "_ahk%22&info=%22" . A_Now . customEncode(1,userText) . "%22"
;
text := AppsScriptRequest(url)
;
if !(InStr(text, "done")) {
ToolTip text
;Sleep 10000
ToolTip 
}
}
Hotkey "Tab", "Off"
}

+^!q::{
;WinActive
userText := InputBox("delimit values with qq`rfirst item is app`rpermitted characters: ' , ?  .  ! @ - _ () [] {} / * : `; <> $`rNOT: % # & '' " , "CUSTOM ENTRY","W400 H160",).value
app_map := Map(
	"t" , "thoughts",
	"a" , "activity",
	"j" , "journal",
	"2" , "todo",
	"to", "todo",)
if userText {
	try {
		app := SubStr(userText,1,InStr(userText,"    ")-1)
		userText := SubStr(userText,InStr(userText,"    ")+4)
		if app_map.Has(app)
		app := app_map[app]
	} catch {
		app := "test"
	}
url := interface_script . interface_json . "&app=%22" . app . "_ahk%22&info=%22" . A_Now . customEncode(1,userText) . "%22"
;
text := AppsScriptRequest(url)
;
if !(InStr(text, "done")) {
ToolTip text
Sleep 10000
ToolTip 
}
}
Hotkey "Tab", "Off"
}

^+!g::{
	MsgBox A_Clipboard
	MsgBox customEncode(1,A_Clipboard)
	
}
;--------------------------------------------------------------------------------------------------------------------
;		FUNCTIONS
;--------------------------------------------------------------------------------------------------------------------

ConnectedToInternet(flag:="0x40") { 
	Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag ,"Int",0) 
}

customEncode(mode, text) {
      specialChars := "_ !@#$%^&*()-+={[}]:`;\" . '"' . "'>.<,?/|~``"
      encodedChars := [
        "H01", "H02", "H03", "H04", "H05", "H06", "H07", "H08",
        "H09", "H0A", "H0B", "H0C", "H0D", "H0E", "H0F", "H0G",
        "H0H", "H0I", "H0J", "H0K", "H0L", "H0M", "H0N", "H0O",
        "H0P", "H0Q", "H0R", "H0S", "H0T", "H0U", "H0V", "H0W",
        "H0X", "H0Y", "H0Z", "H10", "H11", "H12", "H13", "H14",
        "H15", "H16", "H17", "H18", "H19", "H1A", "H1B", "H1C",
        "H1D", "H1E", "H1F", "H1G", "H1H", "H1I", "H1J", "H1K",
        "H1L", "H1M", "H1N", "H1O", "H1P", "H1Q", "H1R", "H1S"
      ]

if (mode == 1) {
        encodedText := ""
        Loop StrLen(text) {
            char := SubStr(text, A_Index, 1)
            index1 := InStr(specialChars, char)
            if (SubStr(text, A_Index, 4) = "    ") {
				encodedText .= "_" . encodedChars[encodedChars.length-0]
				A_Index += 3
			} else if (index1 > 0) {
				encodedText .= "_" . encodedChars[index1]
			} else {
				encodedText .= char
			}	
			}
		encodedText := StrReplace(encodedText, "`r`n", "_" . encodedChars[encodedChars.length-1])
        return encodedText
    } else if (mode == 0) {
        MsgBox "Sorry, I have not built decoding functionality yet"
    } else {
        throw "Invalid mode. Use 1 for encoding and 0 for decoding."
    }
}

AppsScriptRequest(theURL) {
try {
	A_Clipboard := theURL
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", theURL, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	return whr.ResponseText
} catch {
	text := "`r" . theURL
	FileAppend text, A_WorkingDir . "\offline-bunker.txt"
	Tooltip "saved offline"
	Sleep 1000
	Tooltip
}
}


;--------------------------------------------------------------------------------------------------------------------
;		SUBMIT offline-bunker.txt
;--------------------------------------------------------------------------------------------------------------------

try { 												; check connection and upload
	testURL := "https://script.google.com/macros/s/AKfycbwnX_LKtIskpp208iqoqyYYUNWQiol38UYd0PhRaA4-kYCtxoavJq--QsUozldZTaRs/exec?sheetid=%221cOyI1cq8rm85hJk0SuNahlMUaLps5N5Z4DHW3q1tzWQ%22&app=%22testconnection%22"
	whr0 := ComObject("WinHttp.WinHttpRequest.5.1")
	whr0.Open("GET", testURL, true)
	whr0.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr0.WaitForResponse()
	text0 := whr0.ResponseText
	
	if (text0 ~= "i)\A(connection to mind interface stable)\z") {
		string1 := FileRead(A_WorkingDir . "\offline-bunker.txt")
		
		if string1 {
			Tooltip "UPLOADING offline-bunker.txt"
			array1 := StrSplit(string1, "`r")

			counter := 0
			for index, value in array1 {
				if value { 							
					text0 := AppsScriptRequest(value)
					counter += 1
				}
			}
		
			Tooltip
			FileDelete(A_WorkingDir . "\offline-bunker.txt")
			Tooltip "submitted " . counter . " data point(s)."
			Sleep 2000
			Tooltip
		}
	}
}



;--------------------------------------------------------------------------------------------------------------------
;		Keybinds
;--------------------------------------------------------------------------------------------------------------------



^+!1::{
url := "https://www.google.com/search?q=" . StrReplace(InputBox(, "google","W200 H80",).value, " ","+")
Run url
}

^+!2::{
url := "https://thepiratebay10.org/search/" . StrReplace(InputBox(, "pirate bay","W200 H80",).value, " ","%20")
Run url
}

^+!3::{
url := "https://docs.google.com/spreadsheets/d/1cOyI1cq8rm85hJk0SuNahlMUaLps5N5Z4DHW3q1tzWQ/edit#gid=857549180"
Run url
}

^+!4::{
url := "https://www.autohotkey.com/docs/v2/"
Run url
}

^+!9::{
url := StrReplace(A_Clipboard, '"')
Run url
}

+^!x::{
url := A_WorkingDir . "\default-keys.ahk"
Run url
}

+^!z::{
Edit
}

+^!-::{
SendText "—"
}

+^!=::{
SendText "calvinducharme@gmail.com"
}

^+!d::{
Run "C:\Users\calvi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\open_ssd1cad.lnk"
}

^+!m::{
Run "C:\Shortcuts\Test Box.lnk"
}
+^!p::{
SendText A_Clipboard
}

+^!v::{

clip := customEncode(1,A_Clipboard)
scripturl := interface_script . interface_json . "&app=%22misc_pasteUrl%22&url=%22"
url := scripturl . clip . "%22"

A_Clipboard := url
text := AppsScriptRequest(url)

ToolTip text
Sleep 1000
ToolTip
}

+^!c::{
url := "https://script.google.com/macros/s/AKfycbxvu1pKEZGAqZhx-oJWvCoICzSRONw3Y7VCuGP_ZwtN3FbQNUtNzSQ7A16tVjsFTcso/exec?app=%22misc_copyUrl%22"
A_Clipboard := AppsScriptRequest(url)
ToolTip A_Clipboard
Sleep 1000
ToolTip
}


XButton2::{
Send "{LWin}"
}
Xbutton1::{
Send "{Alt down}{Tab}{Alt up}"
}

+^!b::{
text := "`n" . A_Now . "`n" . A_Clipboard
FileAppend text, "C:\Scripts\ahk\clipboard history.txt"
}




+^!j::{
SendText "installedxxpcqq"
}



;-----------------------------
;		cinema keys
;-----------------------------



VLC := "C:\Program Files\VideoLAN\VLC\vlc.exe"
begintime := "00:01:30"
endtime := "00:01:40"

 b := StrSplit(begintime,":")
 hours1   := (b[1]*60*60)
 minutes1 := (b[2]*60)
 seconds1 := (b[3])
 begin := (hours1+minutes1+seconds1)
 ;--
 e := StrSplit(endtime,":")
 hours2   := (e[1]*60*60)
 minutes2 := (e[2]*60)
 seconds2 := (e[3])
 ending     :=(hours2+minutes2+seconds2)

videofile := "C:\Users\calvi\Desktop\everywhere\everywhere.mp4"
options := " --qt-start-minimized --play-and-exit --width=-1 --height=-1 --video-x=0 --video-y=0 --align=0 --autoscale --input-repeat=1 --start-time " . begin . " --stop-time " . ending . " " . videofile

/**
^+!y::{					;-- VLCx example start stop repeat -- example plays twice begintime-endtime
run VLC . options
}
*/

cinemaKeys := false
Paused := false
StartTime := 0
PausedTime := 0
WhenPaused := 0
MovieTime := 0
InitialTime := "00:00:00"

^+!t::{

if !(cinemaKeys) {

Hotkey "Left", "On"
Hotkey "Right","On"

global InitialTime, StartTime
InitialTime := InputBox(, "current time","W200 H80",).value

 t := StrSplit(InitialTime,":")
 hours3   := (t[1]*60*60)
 minutes3 := (t[2]*60)
 seconds3 := (t[3])
 InitialTime := (hours3+minutes3+seconds3)

Send "{Space}"
StartTime := A_TickCount

Tooltip "cinema keys ON"
Sleep 1000
Tooltip

global cinemaKeys
cinemaKeys := true
return
}

if cinemaKeys {

Hotkey "Left", "Off"
Hotkey "Right", "Off"

Tooltip "cinema keys OFF"
Sleep 1000
Tooltip

global cinemaKeys
cinemaKeys := false
return
}

}

Left::{
global Paused
Send "{Space}"
if !(Paused) {
global WhenPaused, MovieTime
WhenPaused := A_TickCount
Tooltip "pausing at " . MovieTime
Sleep 500
Tooltip 
Paused := true
return
}
if Paused {
PauseTime := A_TickCount - WhenPaused
global PausedTime
PausedTime += PauseTime
Tooltip "unpausing"
Sleep 500
Tooltip
Paused := false
return
}
}



Hotkey "Left", "Off"
Hotkey "Right", "Off"


;-----------------------------
;		History
;-----------------------------

/*     gui menu button experiment
Browser_Forward::{
global
MyGui := Gui()
btn1 := MyGui.AddButton("h30 w80", "Live 11")
btn1.OnEvent("Click", runIt.Bind("C:\Users\calvi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Live 11.lnk"))
MouseGetPos &xPos, &yPos
xPos := xPos + 900
MyGui.Show("w200 h200 x" xPos " y" yPos)
}

runIt(yourParam, guiCtrl, RowNumber) {
   MyGui.Destroy()
   Run yourParam
}
*/

/*     old app launch keybinds
+^!q::
{
if WinExist("Chrome")
	{
	WinActivate("Chrome")
	Send "^t"
	}
else Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk"
}

+^!w::Run "spotify.exe"

+^!e::Run "C:\Users\calvi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"

+^!r::Run "C:\Users\calvi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion.lnk"

+^!f::Run "C:\Users\calvi\Documents\Scripts\ahk\installed apps 2023 new pc.txt"

Numpad4::Run "C:\Users\calvi\Documents\Scripts\Notion\add.js"

Numpad5::Run "C:\Users\calvi\Documents"

Numpad6::Run "explorer" "/root`,`,`:`:{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
*/


/*				old pedalboard usage
NumpadSub::{
global pedalboard
if numpad
Send "/"
else {if !pedalboard{
Tooltip "Pedalboard ON"
Run "C:\Users\calvi\Documents\Scripts\Pedalboard.ahk"
Sleep 1000
Tooltip
pedalboard := True
}
else {
Tooltip "Pedalboard OFF"
Send "+^!1"
Sleep 1000
Tooltip
pedalboard := False
}}
}
*/

/*				old numpad toggle
NumpadEnter::{
global numpad
if !numpad {
Tooltip "numpad active"
numpad := True
}
else {
Send "{Enter}"
ToolTip
numpad := False

}
}



+^!r::{
global abletonKeys
if abletonKeys {
abletonKeys := False
WinClose "abletonKeys.ahk - AutoHotkey"
ToolTip ,,,10
} else {
abletonKeys := True
ToolTip "Ableton Keys", 370, 9, 10
Run "C:\Scripts\ahk\abletonKeys.ahk"
}
}

*/



