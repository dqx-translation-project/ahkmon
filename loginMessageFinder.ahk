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
IniRead, ResizeOverlay, settings.ini, loginMessageoverlay, loginMessageResizeOverlay, 0
IniRead, RoundedOverlay, settings.ini, loginMessageoverlay, loginMessageRoundedOverlay, 0
IniRead, AutoHideOverlay, settings.ini, loginMessageoverlay, loginMessageAutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, loginMessageoverlay, loginMessageShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, loginMessageoverlay, loginMessageOverlayWidth, 930
IniRead, OverlayHeight, settings.ini, loginMessageoverlay, loginMessageOverlayHeight, 150
IniRead, OverlayColor, settings.ini, loginMessageoverlay, loginMessageOverlayColor, 000000
IniRead, FontColor, settings.ini, loginMessageoverlay, loginMessageFontColor, White
IniRead, FontSize, settings.ini, loginMessageoverlay, loginMessageFontSize, 16
IniRead, FontType, settings.ini, loginMessageoverlay, loginMessageFontType, Arial
IniRead, OverlayPosX, settings.ini, loginMessageoverlay, loginMessageOverlayPosX, 0
IniRead, OverlayPosY, settings.ini, loginMessageoverlay, loginMessageOverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, loginMessageoverlay, loginMessageOverlayTransparency, 255
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

;; === "Login Messages" text ===================================================
loginMessageAddress := 0x01F7794C
loginMessageOffsets := [0x4C, 0x40, 0x48, 0x78, 0x0, 0x0, 0x0, 0x0, 0x58, 0x0]

;== Save overlay POS when moved =============================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  Gui, Default
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Overlay, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ;; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, loginMessageoverlay, loginMessageOverlayPosX
  IniWrite, %newOverlayY%, settings.ini, loginMessageoverlay, loginMessageOverlayPosY
}

;=== Open overlay ============================================================
overlayShow = 1
alteredOverlayWidth := OverlayWidth - 37
Gui, Default
Gui, Color, %OverlayColor%  ; Sets GUI background to user's color
Gui, Font, s%FontSize% c%FontColor%, %FontType%
Gui, Add, Link, +0x0 vOverlay h%OverlayHeight% w%alteredOverlayWidth%
Gui, Show, w%OverlayWidth% h%OverlayHeight% x%OverlayPosX% y%OverlayPosY%
Winset, Transparent, %OverlayTransparency%, A

if (RoundedOverlay = 1)
{
  WinGetPos, X, Y, W, H, A
  WinSet, Region, R30-30 w%W% h%H% 0-0, A
}

Gui, +LastFound
Gui, Hide

OnMessage(0x201,"WM_LBUTTONDOWN")  ;; Allows dragging the window

flags := "-caption +alwaysontop -Theme -DpiScale -Border "

if (ResizeOverlay = 1)
  customFlags := "+Resize -MaximizeBox "

if (ShowOnTaskbar = 0)
  customFlags .= "+ToolWindow "
else
  customFlags .= "-ToolWindow "

Gui, % flags . customFlags
;=== End overlay =============================================================
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
      newloginMessage := dqx.readString(baseAddress + loginMessageAddress , sizeBytes := 0, encoding := "utf-8", loginMessageOffsets*)

      RegExReplace(newloginMessage, "(*UCP)\w",, utfcount)

      if (newloginMessage != "") && (utfcount > 10)
        if (lastloginMessage != newloginMessage)
		  if (utfcount > 10)
		  {
            ;; Read string at address and sanitize before sending for translation

            GuiControl, Text, Overlay, ...
            Gui, Show

            loginMessage := translate(newloginMessage, "false")
            loginMessage := RegExReplace(loginMessage, "<PAGE>", "`n`n")
            loginMessage := RegExReplace(loginMessage, "({.+?})", "")

            GuiControl, Text, Overlay, Important Notice to Customers`n`n%loginMessage%
            Loop {
              lastloginMessage := dqx.readString(baseAddress + loginMessageAddress, sizeBytes := 0, encoding := "utf-8", loginMessageOffsets*)
              Sleep 250
            }
            Until ((JoystickEnabled = 1 && GetKeyPress(JoystickKeys)) || (JoystickEnabled = 0 && GetKeyPress(KeyboardKeys)))
		  }
      else
      {
        if (AutoHideOverlay = 1)
          Gui, Hide

        GuiControl, Text, Overlay,
      }

      Gui, Hide

      GuiControl, Text, Overlay,

      Sleep 750

	  exit

      ;; Break out of loop if game closed
      Process, Exist, DQXGame.exe
      if (!ErrorLevel)
        break
    }
  }

  ;; Keep looking for a DQXGame.exe process
  else
  sleep 2000
}
