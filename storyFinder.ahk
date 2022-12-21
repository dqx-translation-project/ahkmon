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
IniRead, ResizeOverlay, settings.ini, storyoverlay, storyResizeOverlay, 0
IniRead, RoundedOverlay, settings.ini, storyoverlay, storyRoundedOverlay, 0
IniRead, AutoHideOverlay, settings.ini, storyoverlay, storyAutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, storyoverlay, storyShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, storyoverlay, storyOverlayWidth, 930
IniRead, OverlayHeight, settings.ini, storyoverlay, storyOverlayHeight, 150
IniRead, OverlayColor, settings.ini, storyoverlay, storyOverlayColor, 000000
IniRead, FontColor, settings.ini, storyoverlay, storyFontColor, White
IniRead, FontSize, settings.ini, storyoverlay, storyFontSize, 16
IniRead, FontType, settings.ini, storyoverlay, storyFontType, Arial
IniRead, OverlayPosX, settings.ini, storyoverlay, storyOverlayPosX, 0
IniRead, OverlayPosY, settings.ini, storyoverlay, storyOverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, storyoverlay, storyOverlayTransparency, 255
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

;; === "Story So Far" text ===================================================
storyAddress := 0x01F76CF0
storyDescriptionOffsets := [0x34, 0xB0, 0xE4, 0x30, 0x8, 0x0, 0x10, 0x4, 0x44, 0x0]

;== Save overlay POS when moved =============================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  Gui, Default
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Overlay, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ;; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, storyoverlay, storyOverlayPosX
  IniWrite, %newOverlayY%, settings.ini, storyoverlay, storyOverlayPosY
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
      newStoryDescription := dqx.readString(baseAddress + storyAddress , sizeBytes := 0, encoding := "utf-8", storyDescriptionOffsets*)

      RegExReplace(newStoryDescription, "(*UCP)\w",, utfcount)
      RegExReplace(newStoryDescription, "\w",, ansicount)
      RegExReplace(newStoryDescription, "・",, bulletcount)
      RegExReplace(newStoryDescription, "戦いのきろく",, badstring)

      if (newStoryDescription != "")
        if (lastStoryDescription != newStoryDescription)
          if (utfcount > 12) && (ansicount < 1) && (bulletcount < 1) && (badstring < 1)
          {
            GuiControl, Text, Overlay, ...
            Gui, Show

            storyDescription := translate(newStoryDescription, "false")

            GuiControl, Text, Overlay, %storyDescription%
            Loop {
              lastStoryDescription := dqx.readString(baseAddress + storyAddress, sizeBytes := 0, encoding := "utf-8", storyDescriptionOffsets*)
              Sleep 250
            }
            Until (lastStoryDescription != newStoryDescription)
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

      lastStoryDescription := storyDescription
      Sleep 50

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
