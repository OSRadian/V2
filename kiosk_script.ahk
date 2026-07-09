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
    global CardCodeLength, CaptureTimeout, CaptureWait
    global RefreshDelay, FieldFocusDelay, FieldX, FieldY

    ; Capture card code immediately before it reaches the browser.
    ; Terminator is now SPACE (a text key) — suppressed by default,
    ; so it won't leak to the page the way the old Enter did.
    ih := InputHook("L" CardCodeLength " T" CaptureTimeout, "{Space}")
    ih.Start()
    ih.Wait()
    CardCode := ih.Input

    Click(FieldX, FieldY)	; tap the screen to wake from the screensaver
    Send("^r")                  ; refresh
    Send("{Enter}")
    Sleep(RefreshDelay)
    Send("^0")                  ; recenter and reset MS Edge zoom level
    Click(FieldX, FieldY)
    Sleep(FieldFocusDelay)      ; give field time to focus
    Send(CardCode)              ; inject captured code
    Send("{Enter}")
}