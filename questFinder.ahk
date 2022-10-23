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
IniRead, ResizeOverlay, settings.ini, questoverlay, questResizeOverlay, 0
IniRead, RoundedOverlay, settings.ini, questoverlay, questRoundedOverlay, 0
IniRead, AutoHideOverlay, settings.ini, questoverlay, questAutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, questoverlay, questShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, questoverlay, questOverlayWidth, 930
IniRead, OverlayHeight, settings.ini, questoverlay, questOverlayHeight, 150
IniRead, OverlayColor, settings.ini, questoverlay, questOverlayColor, 000000
IniRead, FontColor, settings.ini, questoverlay, questFontColor, White
IniRead, FontSize, settings.ini, questoverlay, questFontSize, 16
IniRead, FontType, settings.ini, questoverlay, questFontType, Arial
IniRead, OverlayPosX, settings.ini, questoverlay, questOverlayPosX, 0
IniRead, OverlayPosY, settings.ini, questoverlay, questOverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, questoverlay, questOverlayTransparency, 255
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

;; === General Quest Text ====================================================
questAddress := 0x01F7794C
questNameOffsets := [0xC, 0x8, 0x4C4]
questSubQuestNameOffsets := [0xC, 0x8, 0x48C]
questDescriptionOffsets := [0xC, 0x8, 0x4FC]

;== Save overlay POS when moved =============================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  Gui, Default
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Overlay, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ;; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, questoverlay, questOverlayPosX
  IniWrite, %newOverlayY%, settings.ini, questoverlay, questOverlayPosY
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
      newQuestName := dqx.readString(baseAddress + questAddress, sizeBytes := 0, encoding := "utf-8", questNameOffsets*)

      if (newQuestName != "")
        if (lastQuestName != newQuestName)
        {
          questDescription := dqx.readString(baseAddress + questAddress , sizeBytes := 0, encoding := "utf-8", questDescriptionOffsets*)
          questSubQuestName := dqx.readString(baseAddress + questAddress , sizeBytes := 0, encoding := "utf-8", questSubQuestNameOffsets*)
          questNumber := dqx.readString(baseAddress + questAddress , sizeBytes := 0, encoding := "utf-8", questNumberOffsets*)

          RegExReplace(questDescription, "(*UCP)\w",, utfcount)
          RegExReplace(questDescription, "\w",, ansicount)

          if (questDescription != "")
		    if (utfcount > 20) && (ansicount < 10)
			{
              GuiControl, Text, Overlay, ...
              Gui, Show
              if (questSubQuestName != "")
                questSubQuestName := translate(questSubQuestName, "false")

              questName := translate(newQuestName, "false")
              questDescription := translate(questDescription, "false")
              questDescription := StrReplace(questDescription, "{color=yellow}", "")
              questDescription := StrReplace(questDescription, "{reset}", "")
              questNumber := StrReplace(questNumber, "", "")

              if (questSubQuestName != "")
                GuiControl, Text, Overlay, SubQuest: %questSubQuestName%`nQuest: %questName%`n`n%questDescription%
              else
                GuiControl, Text, Overlay, Quest: %questName%`n`n%questDescription%
            }
          Loop {
            lastQuestName := dqx.readString(baseAddress + questAddress, sizeBytes := 0, encoding := "utf-8", questNameOffsets*)
            Sleep 250
          }
          Until (lastQuestName != newQuestName)
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

      lastQuestName := questName
      Sleep 750

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
