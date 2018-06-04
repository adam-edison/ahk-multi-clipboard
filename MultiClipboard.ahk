#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2 ; title contains the string supplied
DetectHiddenWindows, On ; crucial when using with VirtuaWin, which hides windows to create different "screens"
CoordMode, ToolTip, Screen ; absolute screen coordinates, top left (0,0)
CoordMode, Mouse, Screen ; absolute screen coordinates, top left (0,0)


^;::
  prepareMultipleClipboardsIfNotSet()
  loadCommandsIfNotLoaded()
  promptForCommand()
return

~.::

input, char, L1 M T0.5, {;}

if InStr(ErrorLevel, "EndKey:") {
  Send {backspace}
  prepareMultipleClipboardsIfNotSet()
  loadCommandsIfNotLoaded()
  promptForCommand()
}
else {
  SendRaw %char%
}
  
return

prepareMultipleClipboardsIfNotSet() {
  global clipboardList
  
  count := getClipboardEntryCount()
  
  if (count > 0) {
    return
  }
  else {
    clipboardList := {}
  }
}

readCommandsFromFile() {
  global commands
  commands := []
  
  Loop
  {
    FileReadLine, line, commands.txt, %A_Index%
    if (ErrorLevel) {
      break
    }
    else {
      addCommand(line)
    }
  }  
}

addCommand(line) {
  global commands
  
  if (InStr(line, "#") = 1) {
    return
  }
  else if (InStr(line, ";") = 1) {
    return
  }
  else if (InStr(line, ",") > 1) {
    setting := StrSplit(line, ",", " ")
    key := setting[1]
    description := setting[2]
    functionName := setting[3]
    functionArg := setting[4]
    commands[key] := description . ", " functionName . ", " . functionArg
  }
  else {
    return
  }
}

getCommand(key) {
  global commands
  value := commands[key]
  return value
}

loadCommandsIfNotLoaded() {
  global commands
  
  if (commands.hasKey("rls")) {
    return
  }
  else {
    readCommandsFromFile()
  }
}

promptForCommand() {
  global commands
  InputBox, command, Command Prompt, Abbreviation For Command:
  
  if (ErrorLevel) { ; Cancel was clicked
    return
  }
  else if(commands.hasKey(command)) {
    contents := getCommand(command)
    parts := StrSplit(contents, ",", " ")
    functionName := parts[2]
    functionArg := parts[3]
    
    if (IsFunc(functionName)) {
      %functionName%(functionArg)
    }
    else {
      MsgBox, Function Not Found: %functionName% 
    }
  }
  else {
    MsgBox, Command Abbreviation Not Found: %command% 
  }
}

getClipboardEntryCount() {
  global clipboardList
  
  count := 0
  
  for key, value in clipboardList {
    count++
  }
  
  return count
}

setClipboard(key) {
  global clipboardList
  text := copySelection()
  
  if (hasContents(text)) {
    clipboardList[key] := text
  }
}

getClipboard(key) {
  global clipboardList
  text := clipboardList[key]
  
  if (hasContents(text)) {
    pasteSend(text)
  }
}

hasContents(text) {
  length := StrLen(text)
  if (length > 0) {
    return true
  }
  else {
    return false
  }
}

copySelection() {
  temp := clipboard
  clearClipboard() ; Start off empty to allow ClipWait to detect when the text has arrived.
  Send ^c
  ClipWait, 1  ; Wait for the clipboard to contain text for 1 second maximum.
  current := clipboard
  clipboard := temp
  return current
}

clearClipboard() {
  clipboard = 
}

pasteSend(text) {
  temp := clipboard
  clipboard = %text%
  Sleep 20
  Send +{insert}
  clipboard := temp
}

copyCurrentLine() {
  Send {End}
  Send +{Home}
  text := copySelection()
  return text
}

duplicateLine(reps) 
{
	text := copyCurrentLine()
	send {end}
	
	loop %reps%
	{
		send {enter}
		pasteSend(text)
	}
}

reload() {
  Reload
}