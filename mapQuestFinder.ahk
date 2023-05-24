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

;; === Global vars we'll be using elsewhere ==================================
Global Log
Global Language
Global UseDeepLTranslate
Global DeepLAPIKey
Global DeepLApiPro
Global UseGoogleTranslate
Global GoogleTranslateAPIKey

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

;; === General Quest Text ====================================================
questAddress := 0x01F86D30
questNameOffsets := [0x34, 0xCC, 0x108]
questSubQuestNameOffsets := [0x34, 0xCC, 0xD0]
questDescriptionOffsets := [0x34, 0xCC, 0x140]
mapOpenPointer := 0x01F831F8
mapOpenOffsets := [0x8, 0x38, 0x4, 0x4, 0x4, 0x104]

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

          if (questDescription != "")
            questDescription := StrReplace(questDescription, "{color=yellow}", "")
            questDescription := StrReplace(questDescription, "{reset}", "")
            RegExReplace(questDescription, "(*UCP)\w",, utfcount)
            RegExReplace(questDescription, "\w",, ansicount)
            if (utfcount > 20) && (ansicount < 10)
            {
              GuiControl, Text, Overlay, ...
              Gui, Show
              if (questSubQuestName != "")
                questSubQuestName := translate(questSubQuestName, "false")

              questName := translate(newQuestName, "false")
              questDescription := translate(questDescription, "false")
              questNumber := StrReplace(questNumber, "", "")

              if (questSubQuestName != "")
                GuiControl, Text, Overlay, SubQuest: %questSubQuestName%`nQuest: %questName%`n`n%questDescription%
              else
                GuiControl, Text, Overlay, Quest: %questName%`n`n%questDescription%
            }
          Loop {
            mapOpenByte := dqx.read(baseAddress + mapOpenPointer, "UInt", mapOpenOffsets*)

            if (mapOpenByte = 1)
            {
              newQuestName := dqx.WriteString(baseAddress + questAddress, "", "UTF-8", questNameOffsets*)
              Gui, Hide
            }
            else if ((JoystickEnabled = 1 && GetKeyPress(JoystickKeys)) || (JoystickEnabled = 0 && GetKeyPress(KeyboardKeys)))
            {
              newQuestName := dqx.WriteString(baseAddress + questAddress, "", "UTF-8", questNameOffsets*)
              Gui, Hide
            }

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
