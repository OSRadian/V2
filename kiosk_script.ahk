; ============================================
;  Kiosk auto-login script (AHK v2)
;  Reads its settings from config.ini
; ============================================

; --- Load configuration -------------------------------------
global ConfigFile := A_ScriptDir "\config.ini"
global CardCaptureEnabled := false
global CardBuffer := ""

global UserId   := IniRead(ConfigFile, "Login", "UserId")
global Kiosk    := IniRead(ConfigFile, "Login", "Kiosk")
global Password := IniRead(ConfigFile, "Login", "Password")

global StartupDelay      := Integer(IniRead(ConfigFile, "Timing", "StartupDelay", 20000))
global CameraPromptDelay := Integer(IniRead(ConfigFile, "Timing", "CameraPromptDelay", 10000))
global RefreshDelay      := Integer(IniRead(ConfigFile, "Timing", "RefreshDelay", 1500))
global FieldFocusDelay   := Integer(IniRead(ConfigFile, "Timing", "FieldFocusDelay", 200))

global CardCodeLength := IniRead(ConfigFile, "Input", "CardCodeLength", 32)
globalCaptureTimeout := IniRead(ConfigFile, "Input", "CaptureTimeout", 2)

global FieldX := Integer(IniRead(ConfigFile, "Click", "FieldX", 954))
global FieldY := Integer(IniRead(ConfigFile, "Click", "FieldY", 592))

; --- Auto-login on startup ----------------------------------
Sleep(StartupDelay)             ; wait for Edge and page to fully load
Send("^r")
Sleep(100)
Send("{Enter}")
Sleep(1500)
; Click(980, 302)
Sleep(10000)
Send(UserId)                    ; first field is auto in focus on load
Send("{Tab}")
Send(Kiosk)
Send("{Tab}")
Send(Password)
Send("{Enter}")
Sleep(CameraPromptDelay)        ; wait for camera permissions prompt to openg
Send("{Tab}")
Send("{Tab}")
Send("{Tab}")
Send("{Enter}")                 ; tab 3 times to the "approve" button
CardCaptureEnabled := true

#HotIf CardCaptureEnabled
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
    global CardBuffer, ConfigFile, FieldX, FieldY

    if (CardBuffer = "")
        return

    RefreshNeeded := false

    CardCode := CardBuffer

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
        Sleep(750)
        Send("^r")
        Sleep(400)
        Send("{Enter}")

        Sleep(40)

        if (Lines.Length)
            Lines[Lines.Length] := A_Now
        else
            Lines.Push(A_Now)

        FileDelete(ConfigFile)
        for _, line in Lines
            FileAppend(line "`r`n", ConfigFile)

        Sleep(3500)
    }

    enterCardInfo(CardCode)
}



enterCardInfo(CardCode)
{
    global CardBuffer, FieldX, FieldY, FieldFocusDelay

    Sleep(300)
    Click(FieldX, FieldY)
    Sleep(300)
    Send("^0")

    Sleep(FieldFocusDelay)

    SendText(CardCode)
    Sleep(300)
    Send("{Enter}")
    Sleep(100)
    Send("{Enter}")

    CardBuffer := ""
}