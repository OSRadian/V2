; ============================================
;  Kiosk auto-login script (AHK v2)
;  Reads its settings from config.ini
; ============================================

; --- Load configuration -------------------------------------
configFile := A_ScriptDir "\config.ini"

UserId   := IniRead(configFile, "Login", "UserId")
Kiosk    := IniRead(configFile, "Login", "Kiosk")
Password := IniRead(configFile, "Login", "Password")

StartupDelay      := Integer(IniRead(configFile, "Timing", "StartupDelay", 20000))
CameraPromptDelay := Integer(IniRead(configFile, "Timing", "CameraPromptDelay", 10000))
RefreshDelay      := Integer(IniRead(configFile, "Timing", "RefreshDelay", 1500))
FieldFocusDelay   := Integer(IniRead(configFile, "Timing", "FieldFocusDelay", 200))

CardCodeLength := IniRead(configFile, "Input", "CardCodeLength", 32)
CaptureTimeout := IniRead(configFile, "Input", "CaptureTimeout", 2)

FieldX := Integer(IniRead(configFile, "Click", "FieldX", 954))
FieldY := Integer(IniRead(configFile, "Click", "FieldY", 592))

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

; --- RFID badge read ----------------------------------------
+F1:: {
    Sleep(200)
    global CardCodeLength, CaptureTimeout, CaptureWait
    global RefreshDelay, FieldFocusDelay, FieldX, FieldY

    ConfigFile := "config.ini"

    ; Read the last line of config.ini (timestamp in YYYYMMDDHH24MISS format)
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
        ; File doesn't exist yet
        Lines := []
        RefreshNeeded := true
    }

    ; Capture card code immediately before it reaches the browser.
    ih := InputHook("L" CardCodeLength " T" CaptureTimeout, "{Space}")
    ih.Start()
    ih.Wait()
    CardCode := ih.Input

    ; Refresh Edge only if the timestamp is 2+ hours old
    if (RefreshNeeded)
    {
        Click(FieldX, FieldY)      ; wake screen if needed
        Sleep(100)
        Send("^r")                 ; refresh page
        Send("{Enter}")
        Sleep(50)
        Sleep(RefreshDelay)

        ; Update the timestamp (replace the last line)
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
    Send("^0")                     ; reset Edge zoom
    Click(FieldX, FieldY)
    Sleep(FieldFocusDelay)

    Send(CardCode)
    Sleep(500)
    Send("{Enter}")
}