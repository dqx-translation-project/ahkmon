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
IniRead, ResizeOverlay, settings.ini, mailoverlay, mailResizeOverlay, 0
IniRead, RoundedOverlay, settings.ini, mailoverlay, mailRoundedOverlay, 0
IniRead, AutoHideOverlay, settings.ini, mailoverlay, mailAutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, mailoverlay, mailShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, mailoverlay, mailOverlayWidth, 930
IniRead, OverlayHeight, settings.ini, mailoverlay, mailOverlayHeight, 150
IniRead, OverlayColor, settings.ini, mailoverlay, mailOverlayColor, 000000
IniRead, FontColor, settings.ini, mailoverlay, mailFontColor, White
IniRead, FontSize, settings.ini, mailoverlay, mailFontSize, 16
IniRead, FontType, settings.ini, mailoverlay, mailFontType, Arial
IniRead, OverlayPosX, settings.ini, mailoverlay, mailOverlayPosX, 0
IniRead, OverlayPosY, settings.ini, mailoverlay, mailOverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, mailoverlay, mailOverlayTransparency, 255
IniRead, UseDeepLTranslate, settings.ini, deepl, UseDeepLTranslate, 0
IniRead, DeepLApiPro, settings.ini, deepl, DeepLApiPro, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY
IniRead, UseGoogleTranslate, settings.ini, google, UseGoogleTranslate, 0
IniRead, GoogleTranslateAPIKey, settings.ini, google, GoogleTranslateAPIKey, EMPTY

;; === Global vars we'll be using elsewhere ==================================
Global Log
Global Language
Global UseDeepLTranslate
Global DeepLAPIKey
Global DeepLApiPro
Global UseGoogleTranslate
Global GoogleTranslateAPIKey

;; === "Mail" text ===================================================
mailAddress := 0x01F87988
mailOffsets := [0x4C, 0x44, 0x8, 0xFC, 0x0, 0x10, 0x0, 0x0, 0x0, 0x10]
voiceOffsets := [0x4C, 0x44, 0x20, 0x28, 0x90, 0x4, 0x20, 0x4, 0x44, 0x0]

;== Save overlay POS when moved =============================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  Gui, Default
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Overlay, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ;; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, mailoverlay, mailOverlayPosX
  IniWrite, %newOverlayY%, settings.ini, mailoverlay, mailOverlayPosY
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
      newMail := dqx.readString(baseAddress + mailAddress , sizeBytes := 0, encoding := "utf-8", mailOffsets*)
      voiceMail := dqx.readString(baseAddress + mailAddress , sizeBytes := 0, encoding := "utf-8", voiceOffsets*)

      RegExReplace(voiceMail, "(*UCP)\w",, utfcount)
      RegExReplace(voiceMail, "\w",, ansicount)

      if (voiceMail != "") && (if InStr(newMail, "sound"))
        if (lastMail != voiceMail)
          if (utfcount > 45) && (ansicount <1)
          {
            GuiControl, Text, Overlay, ...
            Gui, Show

            mail := translate(voiceMail, "false")

            GuiControl, Text, Overlay, %mail%
            Loop {
              lastMail := dqx.readString(baseAddress + mailAddress, sizeBytes := 0, encoding := "utf-8", voiceOffsets*)
              Sleep 250
            }
            Until (lastMail != voiceMail)
          }
      else
      {
        if (AutoHideOverlay = 1)
          Gui, Hide

        GuiControl, Text, Overlay,
      }

      if (AutoHideOverlay = 1)
          Gui, Hide

      GuiControl, Text, Overlay,

      lastMail := mail
      Sleep 100

      ;; Break out of loop if game closed
      Process, Exist, DQXGame.exe
      if !ErrorLevel
        break
    }
  }

  ;; Keep looking for a DQXGame.exe process
  else
  sleep 2000
}
