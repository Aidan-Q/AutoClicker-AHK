#Requires AutoHotkey v2.0
#SingleInstance Force
; ===== Global Variables =====
isClicking := false
currentHotkey := "F6"

; ===== Window Creation =====
MyGui := Gui("+AlwaysOnTop", "AutoClicker")
MyGui.SetFont("s8", "Trebuchet MS")

; ===== [SECTION]: Time Interval =====
MyGui.Add("GroupBox", "w320 h50 y-1 Section", "Time Interval ⏳")
; --- Hours ---
MyGui.Add("Text", "xs+10 ys+21", "Hours:")
edtHrs := MyGui.Add("Edit", "w42 x+1 yp-3 Number", 0)
; --- Minutes ---
MyGui.Add("Text", "x+8 yp+3", "Mins:")
edtMins := MyGui.Add("Edit", "w42 x+1 yp-3 Number", 0)
; --- Seconds ---
MyGui.Add("Text", "x+8 yp+3", "Secs:")
edtSecs := MyGui.Add("Edit", "w42 x+1 yp-3 Number", 0)
; --- Milliseconds ---
MyGui.Add("Text", "x+8 yp+3", "Ms:")
edtMs := MyGui.Add("Edit", "w42 x+1 yp-3 Number", 0)
edtMs.Focus()

; ===== [SECTION]: Other Settings =====
MyGui.Add("GroupBox", "w320 h50 xs y+8 Section", "Other Settings ⚙️")
; --- Toggle Hotkey ---
MyGui.Add("Text", "xs+23 ys+21", "Toggle Hotkey:")
hk := MyGui.Add("Hotkey", "w41 x+1 yp-3", currentHotkey)
hk.OnEvent("Change", updateHotkey)
; --- Mouse Button ---
MyGui.Add("Text", "x+23 yp+3", "Mouse Button:")
ddlButton := MyGui.Add("DropDownList", "w60 x+1 yp-3 Choose1", ["Left", "Right", "Middle"])

; ===== Register Initial Hotkey =====
Hotkey(currentHotkey, toggleClicker)

; ===== Display Window =====
MyGui.Show()

; ===== Functions =====
updateHotkey(CtrlObj, *) {
    global currentHotkey
    newHotkey := CtrlObj.Value
    if (newHotkey != "" && newHotkey != currentHotkey) {
        try {
            DllCall("user32\SetFocus", "Ptr", 0) ; Unfocus hotkey box
            Hotkey(currentHotkey, "Off") ; Disable old hotkey
            Hotkey(newHotkey, toggleClicker, "On") ; Bind and enable the new hotkey
            currentHotkey := newHotkey ; Update global hotkey tracker
        } catch { ; Ignore errors with hotkey input
        }
    }
}
toggleClicker(ThisHotkey) {
    global isClicking
    isClicking := !isClicking
    if (isClicking) {
        h  := Number(edtHrs.Value = "" ? 0 : edtHrs.Value)
        m  := Number(edtMins.Value = "" ? 0 : edtMins.Value)
        s  := Number(edtSecs.Value = "" ? 0 : edtSecs.Value)
        ms := Number(edtMs.Value = "" ? 0 : edtMs.Value)
        ; Calculate the click interval in ms
        totalMs := (h * 3600000) + (m * 60000) + (s * 1000) + ms
        if (totalMs < 15) { ; Enforce minimum click interval
            totalMs := 15
        }
        SetTimer(ClickLoop, totalMs)
    } else {
        SetTimer(ClickLoop, 0) ; Stops the click loop
    }
}
ClickLoop() {
    Click(ddlButton.Text) ; Click mouse button selected in ddlButton
}