; ============================================
;  Kiosk auto-login script (AHK v2)
;  Reads its settings from config.ini
; ============================================

; --- Load configuration -------------------------------------
global ConfigFile := A_ScriptDir "\config.ini"

UserId   := IniRead(ConfigFile, "Login", "UserId")
Kiosk    := IniRead(ConfigFile, "Login", "Kiosk")
Password := IniRead(ConfigFile, "Login", "Password")

StartupDelay      := Integer(IniRead(ConfigFile, "Timing", "StartupDelay", 20000))
CameraPromptDelay := Integer(IniRead(ConfigFile, "Timing", "CameraPromptDelay", 10000))
RefreshDelay      := Integer(IniRead(ConfigFile, "Timing", "RefreshDelay", 1500))
FieldFocusDelay   := Integer(IniRead(ConfigFile, "Timing", "FieldFocusDelay", 200))

CardCodeLength := IniRead(ConfigFile, "Input", "CardCodeLength", 32)
CaptureTimeout := IniRead(ConfigFile, "Input", "CaptureTimeout", 2)

FieldX := Integer(IniRead(ConfigFile, "Click", "FieldX", 954))
FieldY := Integer(IniRead(ConfigFile, "Click", "FieldY", 592))

; --- Auto-login on startup ----------------------------------
Sleep(StartupDelay)             ; wait for Edge and page to fully load
Send(UserId)                    ; first field is auto in focus on load
Send("{Tab}")
Send(Kiosk)
Send("{Tab}")
Send(Password)
Send("{Enter}")
Sleep(CameraPromptDelay)        ; wait for camera permissions prompt to open
Send("{Tab}")
Send("{Tab}")
Send("{Tab}")
Send("{Enter}")                 ; tab 3 times to the "approve" button

global CardBuffer := ""

#HotIf
0::AppendDigit("0")
1::AppendDigit("1")
2::AppendDigit("2")
3::AppendDigit("3")
4::AppendDigit("4")
5::AppendDigit("5")
6::AppendDigit("6")
7::AppendDigit("7")
8::AppendDigit("8")
9::AppendDigit("9")

Space::FinishScan()

AppendDigit(digit)
{
    global CardBuffer
    CardBuffer .= digit
}

FinishScan()
{
    global CardBuffer, ConfigFile
    global RefreshDelay, FieldFocusDelay, FieldX, FieldY
    
    if (CardBuffer = "")
        return
        
    CardCode := CardBuffer
    

    RefreshNeeded := false

    if FileExist(ConfigFile)
    {
        FileText := FileRead(ConfigFile)
        Lines := StrSplit(RTrim(FileText, "`r`n"), "`n", "`r")
        LastLine := Trim(Lines[Lines.Length])

        if (LastLine = "" || DateDiff(A_Now, LastLine, "Hours") >= 2)
            RefreshNeeded := true
    }
    else
    {
        Lines := []
        RefreshNeeded := true
    }

    if (RefreshNeeded)
    {
        Click(FieldX, FieldY)
        Sleep(100)
        Send("^r")
        Send("{Enter}")
        Sleep(50)
        Sleep(RefreshDelay)

        if (Lines.Length)
            Lines[Lines.Length] := A_Now
        else
            Lines.Push(A_Now)

        FileDelete(ConfigFile)
        for _, line in Lines
            FileAppend(line "`r`n", ConfigFile)

        Sleep(100)
    }

    Click(FieldX, FieldY)
    Sleep(300)
    Send("^0")
    Click(FieldX, FieldY)
    Sleep(FieldFocusDelay)

    Sleep(1000)

    SendText(CardCode)
    Send("{Enter}")

    CardBuffer := ""
}