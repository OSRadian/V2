Set WshShell = CreateObject("WScript.Shell")

' Press Caps Lock 4 times, 100ms apart
For i = 1 To 4
    WshShell.SendKeys "{CAPSLOCK}"
    WScript.Sleep 100
Next

' Ctrl+R to reload
WshShell.SendKeys "^r"

' Wait half a second
WScript.Sleep 500

' Press Enter
WshShell.SendKeys "{ENTER}"