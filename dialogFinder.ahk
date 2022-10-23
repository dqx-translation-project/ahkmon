#NoEnv
#NoTrayIcon
#SingleInstance force
#Include <translate>
#Include <GetKeyPress>
#Include <classMemory>
#Include <SQLiteDB>
#Include <JSON>

SetBatchLines, -1

;; Don't let user run this script directly.
if A_Args.Length() < 1
{
    MsgBox Don't run this directly. Run ahkmon.exe instead.
    ExitApp
}

;=== Load Start GUI settings from file ======================================
IniRead, Language, settings.ini, general, Language, en
IniRead, Log, settings.ini, general, Log, 0
IniRead, JoystickEnabled, settings.ini, general, JoystickEnabled, 0
IniRead, ResizeOverlay, settings.ini, dialogoverlay, dialogResizeOverlay, 0
IniRead, RoundedOverlay, settings.ini, dialogoverlay, dialogRoundedOverlay, 0
IniRead, AutoHideOverlay, settings.ini, dialogoverlay, dialogAutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, dialogoverlay, dialogShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, dialogoverlay, dialogOverlayWidth, 930
IniRead, OverlayHeight, settings.ini, dialogoverlay, dialogOverlayHeight, 150
IniRead, OverlayColor, settings.ini, dialogoverlay, dialogOverlayColor, 000000
IniRead, FontColor, settings.ini, dialogoverlay, dialogFontColor, White
IniRead, FontSize, settings.ini, dialogoverlay, dialogFontSize, 16
IniRead, FontType, settings.ini, dialogoverlay, dialogFontType, Arial
IniRead, OverlayPosX, settings.ini, dialogoverlay, dialogOverlayPosX, 0
IniRead, OverlayPosY, settings.ini, dialogoverlay, dialogOverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, dialogoverlay, dialogOverlayTransparency, 255
IniRead, ShowFullDialog, settings.ini, advanced, ShowFullDialog, 0
IniRead, UseDeepLTranslate, settings.ini, deepl, UseDeepLTranslate, 0
IniRead, DeepLApiPro, settings.ini, deepl, DeepLApiPro, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY
IniRead, UseGoogleTranslate, settings.ini, google, UseGoogleTranslate, 0
IniRead, GoogleTranslateAPIKey, settings.ini, google, GoogleTranslateAPIKey, EMPTY
IniRead, GlossaryID, settings.ini, deepl, GlossaryID, EMPTY

;; === Global vars we'll be using elsewhere ==================================
Global Log
Global Language
Global UseDeepLTranslate
Global DeepLAPIKey
Global DeepLApiPro
Global UseGoogleTranslate
Global GoogleTranslateAPIKey
Global KeyboardKeys
Global JoystickKeys
Global GlossaryID

;=== Controller Configuration ==============================================
if (JoystickEnabled = 1)
{
  Loop 16  ; Query each joystick number to find out which ones exist.
    {
      GetKeyState, JoyName, %A_Index%JoyName
      if JoyName <>
      {
        JoystickNumber = %A_Index%
        break
      }
    }
    if JoystickNumber <= 0
    {
      MsgBox Could not find a valid joystick. Enabling ShowFullDialog instead.
      ShowFullDialog := 1
      IniWrite, %ShowFullDialog%, settings.ini, advanced, ShowFullDialog
    }
}

KeyboardKeys := "Enter,Esc,Up,Down,Left,Right"

;; Maps 1Joy1, 1Joy2, etc for the correct controller number that was found.
loop 32
  JoystickKeys .= JoystickNumber . "Joy" . A_Index . ","

;=== Save overlay POS when moved =============================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Overlay, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ;; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, dialogoverlay, dialogOverlayPosX
  IniWrite, %newOverlayY%, settings.ini, dialogoverlay, dialogOverlayPosY
}

;=== Open overlay ============================================================
overlayShow = 1
alteredOverlayWidth := OverlayWidth - 37
Gui, Default
Gui, Color, %OverlayColor%  ; Sets GUI background to user's color
Gui, Font, s%FontSize% c%FontColor%, %FontType%
Gui, Add, Text, +0x0 vOverlay h%OverlayHeight% w%alteredOverlayWidth%
Gui, Show, w%OverlayWidth% h%OverlayHeight% x%OverlayPosX% y%OverlayPosY%
WinSet, Transparent, %OverlayTransparency%, A

if (RoundedOverlay = 1)
{
  WinGetPos, X, Y, W, H, A
  WinSet, Region, R30-30 w%W% h%H% 0-0, A
}

Gui, +LastFound
Gui, Hide

OnMessage(0x201,"WM_LBUTTONDOWN")  ; Allows dragging the window

flags := "-caption +alwaysontop -Theme -DpiScale -Border "

if (ResizeOverlay = 1)
  customFlags := "+Resize -MaximizeBox "

if (ShowOnTaskbar = 0)
  customFlags .= "+ToolWindow "
else
  customFlags .= "-ToolWindow "

Gui, % flags . customFlags
;=== End overlay =============================================================
;; Array of Bytes pattern that tells us if the dialog box is open or closed, as well as
;; the partial location of the address where the dialog text is.
aAOBPattern := [255, 255, 255, 127, 255, 255, 255, 127, 0, 0, 0, 0, 0, 0, 0, 0, 253, "?", 168, 153]

loop
{
  Process, Exist, DQXGame.exe
  if ErrorLevel
  {
    dqx := new _ClassMemory("ahk_exe DQXGame.exe", "", hProcessCopy)
    baseAddress := dqx.getProcessBaseAddress("ahk_exe DQXGame.exe")

    ;; Start searching for text.
    loop
    {
      dialogPatternResult := dqx.processPatternScan(,, aAOBPattern*)

      if (dialogPatternResult == 0)
      {
        if (AutoHideOverlay = 1)
          Gui, Hide

        GuiControl, Text, Overlay,
      }

      dialogBaseAddress := dialogPatternResult + 32 + 4
      dialogActualAddress := dqx.read(dialogBaseAddress, "UInt")

      if (dialogActualAddress != dialogLastAddress && dialogActualAddress != "")
      {

        ;; Read string at address and sanitize before sending for translation
        dialogText := dqx.readString(dialogActualAddress, sizeBytes := 0, encoding := "utf-8")
        dialogText := RegExReplace(dialogText, "\n", "")
        dialogText := RegExReplace(dialogText, "<br>", "`n`n")
        dialogText := RegExReplace(dialogText, "(<.+?>)", "")
        dialogText := StrReplace(dialogText, "「", "")
        dialogText := StrReplace(dialogText, "", "")

        ;; Iterate through each line in the dialog if line by line disabled.
        ;; Otherwise, spit all the text out at once.
        dialogText := RTrim(dialogText, "`n")  ;; Remove new lines at end of string.
        if (ShowFullDialog != 1)
        {
          ;; Determine whether to listen for joystick or keyboard keys
          ;; to continue the dialog.
          for index, sentence in StrSplit(dialogText, "`n`n", "`r")
          {
            if (sentence = "")
              continue

            RegExReplace(sentence, "[^a-zA-Z0-9,'.!?:;&#_-~ー～"" 　\Q/\()[]`a\E]",, count)
            checkNum := StrLen(sentence)/4
            if (count <= checkNum)
            {
                Gui, Hide
                continue
            }

            sentence := translate(sentence, "true")

            Gui, Show

            GuiControl, Text, Overlay, %sentence%
            if (JoystickEnabled = 1)
            {
              WinActivate, ahk_class AutoHotkeyGUI
              Input := GetKeyPress(JoystickKeys)
            }
            else
            {
              WinActivate, ahk_exe DQXGame.exe
              Input := GetKeyPress(KeyboardKeys)
            }
          }
        }
        else
        {
          RegExReplace(dialogText, "[^a-zA-Z0-9,'.!?:;&#_-~ー～"" 　\Q/\()[]`a\E]",, count)
          checkNum := StrLen(dialogText)/4
          if (count <= checkNum)
          {
            Gui, Hide
            continue
          }
          dialogText := translate(dialogText, "true")
          Gui, Show

          WinActivate, ahk_exe DQXGame.exe
          GuiControl, Text, Overlay, %dialogText%
        }

        ;; Set LastAddress to ActualAddress so we aren't reading the same string over and over.
        dialogLastAddress := dialogActualAddress
      }

      ;; Exit app if DQX closed
      Process, Exist, DQXGame.exe
      if !ErrorLevel
        ExitApp
    }
  }

  ;; Keep looking for a DQXGame.exe process
  else
  sleep 2000
}