#Persistent
#NoEnv
#SingleInstance force
#Include <translate>
#Include <JSON>
#Include <SQLiteDB>
SendMode Input

;=== Close any existing finder windows ======================================
Process, Close, questFinder.exe
Process, Close, dialogFinder.exe
Process, Close, mapQuestFinder.exe
Process, Close, storyFinder.exe
Process, Close, mailFinder.exe
Process, Close, voicemailFinder.exe
Process, Close, loginMessageFinder.exe

;=== Auto update ============================================================
;; Get latest version number from Github
oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
url := "https://api.github.com/repos/dqx-translation-project/ahkmon/releases/latest"
oWhr.Open("GET", url, 0)
oWhr.Send()
oWhr.WaitForResponse()
jsonResponse := JSON.Load(oWhr.ResponseText)
latestVersion := (jsonResponse.tag_name)
latestVersion := SubStr(latestVersion, 2)

;; Get current version locally from version file
FileRead, currentVersion, version

;; If the versions differ, run updater
if (latestVersion != currentVersion)
{
  if (latestVersion = "" || currentVersion = "")
    MsgBox Unable to determine latest version. Continuing without updating.
  else
  {
    Run ahkmon_updater.exe
    ExitApp
  }
}
else
{
  tmpLoc := A_ScriptDir "\tmp"
  if FileExist(tmpLoc)
    FileRemoveDir, %A_ScriptDir%\tmp, 1
    sleep 50
}

downloadFile("https://raw.githubusercontent.com/dqx-translation-project/dqx-custom-translations/main/csv/glossary.csv")

;=== Load Start GUI settings from file ======================================
IniRead, Language, settings.ini, general, Language, en
IniRead, Log, settings.ini, general, Log, 0
IniRead, JoystickEnabled, settings.ini, general, JoystickEnabled, 0
IniRead, enableWalkthrough, settings.ini, general, enableWalkthrough, 0
IniRead, enableDialog, settings.ini, general, enableDialog, 1
IniRead, enableQuests, settings.ini, general, enableQuests, 1
IniRead, enableStory, settings.ini, general, enableStory, 1
IniRead, enableMail, settings.ini, general, enablemail, 1
IniRead, enableloginMessage, settings.ini, general, enableloginMessage, 1
IniRead, dialogResizeOverlay, settings.ini, dialogoverlay, dialogResizeOverlay, 0
IniRead, dialogRoundedOverlay, settings.ini, dialogoverlay, dialogRoundedOverlay, 0
IniRead, dialogAutoHideOverlay, settings.ini, dialogoverlay, dialogAutoHideOverlay, 0
IniRead, dialogShowOnTaskbar, settings.ini, dialogoverlay, dialogShowOnTaskbar, 0
IniRead, dialogOverlayWidth, settings.ini, dialogoverlay, dialogOverlayWidth, 930
IniRead, dialogOverlayHeight, settings.ini, dialogoverlay, dialogOverlayHeight, 150
IniRead, dialogOverlayColor, settings.ini, dialogoverlay, dialogOverlayColor, 000000
IniRead, dialogFontColor, settings.ini, dialogoverlay, dialogFontColor, White
IniRead, dialogFontSize, settings.ini, dialogoverlay, dialogFontSize, 16
IniRead, dialogFontType, settings.ini, dialogoverlay, dialogFontType, Arial
IniRead, dialogOverlayPosX, settings.ini, dialogoverlay, dialogOverlayPosX, 0
IniRead, dialogOverlayPosY, settings.ini, dialogoverlay, dialogOverlayPosY, 0
IniRead, dialogOverlayTransparency, settings.ini, dialogoverlay, dialogOverlayTransparency, 255
IniRead, questResizeOverlay, settings.ini, questoverlay, questResizeOverlay, 0
IniRead, questRoundedOverlay, settings.ini, questoverlay, questRoundedOverlay, 1
IniRead, questAutoHideOverlay, settings.ini, questoverlay, questAutoHideOverlay, 0
IniRead, questShowOnTaskbar, settings.ini, questoverlay, questShowOnTaskbar, 0
IniRead, questOverlayWidth, settings.ini, questoverlay, questOverlayWidth, 930
IniRead, questOverlayHeight, settings.ini, questoverlay, questOverlayHeight, 150
IniRead, questOverlayColor, settings.ini, questoverlay, questOverlayColor, 000000
IniRead, questFontColor, settings.ini, questoverlay, questFontColor, White
IniRead, questFontSize, settings.ini, questoverlay, questFontSize, 16
IniRead, questFontType, settings.ini, questoverlay, questFontType, Arial
IniRead, questOverlayPosX, settings.ini, questoverlay, questOverlayPosX, 0
IniRead, questOverlayPosY, settings.ini, questoverlay, questOverlayPosY, 0
IniRead, questOverlayTransparency, settings.ini, questoverlay, questOverlayTransparency, 255
IniRead, questOverlayEn, settings.ini, questoverlay, questOverlayEn, 0
IniRead, walkthroughResizeOverlay, settings.ini, walkthroughoverlay, walkthroughResizeOverlay, 0
IniRead, walkthroughRoundedOverlay, settings.ini, walkthroughoverlay, walkthroughRoundedOverlay, 1
IniRead, walkthroughAutoHideOverlay, settings.ini, walkthroughoverlay, walkthroughAutoHideOverlay, 0
IniRead, walkthroughShowOnTaskbar, settings.ini, walkthroughoverlay, walkthroughShowOnTaskbar, 0
IniRead, walkthroughOverlayWidth, settings.ini, walkthroughoverlay, walkthroughOverlayWidth, 930
IniRead, walkthroughOverlayHeight, settings.ini, walkthroughoverlay, walkthroughOverlayHeight, 150
IniRead, walkthroughOverlayColor, settings.ini, walkthroughoverlay, walkthroughOverlayColor, 000000
IniRead, walkthroughFontColor, settings.ini, walkthroughoverlay, walkthroughFontColor, White
IniRead, walkthroughFontSize, settings.ini, walkthroughoverlay, walkthroughFontSize, 16
IniRead, walkthroughFontType, settings.ini, walkthroughoverlay, walkthroughFontType, Arial
IniRead, walkthroughOverlayPosX, settings.ini, walkthroughoverlay, walkthroughOverlayPosX, 0
IniRead, walkthroughOverlayPosY, settings.ini, walkthroughoverlay, walkthroughOverlayPosY, 0
IniRead, walkthroughOverlayTransparency, settings.ini, walkthroughoverlay, walkthroughOverlayTransparency, 255
IniRead, storyResizeOverlay, settings.ini, storyoverlay, storyResizeOverlay, 0
IniRead, storyRoundedOverlay, settings.ini, storyoverlay, storyRoundedOverlay, 1
IniRead, storyAutoHideOverlay, settings.ini, storyoverlay, storyAutoHideOverlay, 0
IniRead, storyShowOnTaskbar, settings.ini, storyoverlay, storyShowOnTaskbar, 0
IniRead, storyOverlayWidth, settings.ini, storyoverlay, storyOverlayWidth, 930
IniRead, storyOverlayHeight, settings.ini, storyoverlay, storyOverlayHeight, 150
IniRead, storyOverlayColor, settings.ini, storyoverlay, storyOverlayColor, 000000
IniRead, storyFontColor, settings.ini, storyoverlay, storyFontColor, White
IniRead, storyFontSize, settings.ini, storyoverlay, storyFontSize, 16
IniRead, storyFontType, settings.ini, storyoverlay, storyFontType, Arial
IniRead, storyOverlayPosX, settings.ini, storyoverlay, storyOverlayPosX, 0
IniRead, storyOverlayPosY, settings.ini, storyoverlay, storyOverlayPosY, 0
IniRead, storyOverlayTransparency, settings.ini, storyoverlay, storyOverlayTransparency, 255
IniRead, mailResizeOverlay, settings.ini, mailoverlay, mailResizeOverlay, 0
IniRead, mailRoundedOverlay, settings.ini, mailoverlay, mailRoundedOverlay, 1
IniRead, mailAutoHideOverlay, settings.ini, mailoverlay, mailAutoHideOverlay, 0
IniRead, mailShowOnTaskbar, settings.ini, mailoverlay, mailShowOnTaskbar, 0
IniRead, mailOverlayWidth, settings.ini, mailoverlay, mailOverlayWidth, 930
IniRead, mailOverlayHeight, settings.ini, mailoverlay, mailOverlayHeight, 150
IniRead, mailOverlayColor, settings.ini, mailoverlay, mailOverlayColor, 000000
IniRead, mailFontColor, settings.ini, mailoverlay, mailFontColor, White
IniRead, mailFontSize, settings.ini, mailoverlay, mailFontSize, 16
IniRead, mailFontType, settings.ini, mailoverlay, mailFontType, Arial
IniRead, mailOverlayPosX, settings.ini, mailoverlay, mailOverlayPosX, 0
IniRead, mailOverlayPosY, settings.ini, mailoverlay, mailOverlayPosY, 0
IniRead, mailOverlayTransparency, settings.ini, mailoverlay, mailOverlayTransparency, 255
IniRead, loginMessageResizeOverlay, settings.ini, loginMessageoverlay, loginMessageResizeOverlay, 0
IniRead, loginMessageRoundedOverlay, settings.ini, loginMessageoverlay, loginMessageRoundedOverlay, 1
IniRead, loginMessageAutoHideOverlay, settings.ini, loginMessageoverlay, loginMessageAutoHideOverlay, 0
IniRead, loginMessageShowOnTaskbar, settings.ini, loginMessageoverlay, loginMessageShowOnTaskbar, 0
IniRead, loginMessageOverlayWidth, settings.ini, loginMessageoverlay, loginMessageOverlayWidth, 930
IniRead, loginMessageOverlayHeight, settings.ini, loginMessageoverlay, loginMessageOverlayHeight, 150
IniRead, loginMessageOverlayColor, settings.ini, loginMessageoverlay, loginMessageOverlayColor, 000000
IniRead, loginMessageFontColor, settings.ini, loginMessageoverlay, loginMessageFontColor, White
IniRead, loginMessageFontSize, settings.ini, loginMessageoverlay, loginMessageFontSize, 16
IniRead, loginMessageFontType, settings.ini, loginMessageoverlay, loginMessageFontType, Arial
IniRead, loginMessageOverlayPosX, settings.ini, loginMessageoverlay, loginMessageOverlayPosX, 0
IniRead, loginMessageOverlayPosY, settings.ini, loginMessageoverlay, loginMessageOverlayPosY, 0
IniRead, loginMessageOverlayTransparency, settings.ini, loginMessageoverlay, loginMessageOverlayTransparency, 255
IniRead, ShowFullDialog, settings.ini, advanced, ShowFullDialog, 0
IniRead, UseDeepLTranslate, settings.ini, deepl, UseDeepLTranslate, 0
IniRead, DeepLApiPro, settings.ini, deepl, DeepLApiPro, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY
IniRead, UseGoogleTranslate, settings.ini, google, UseGoogleTranslate, 0
IniRead, GoogleTranslateAPIKey, settings.ini, google, GoogleTranslateAPIKey, EMPTY

;=== Create Start GUI =====================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, Tab3,, General|Dialog Overlay|Quest Overlay|Story Overlay|Mail Overlay|Login Message Overlay|Advanced|Translate APIs|Help|About
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/General-tab">General Settings Documentation</a>
Gui, Add, Text,, ahkmon: Automate your DQX text translation.
Gui, Add, Picture, x45 y140 w300 h165, imgs/dqx_logo.png
Gui, Add, Link,, Language you want to translate text to:`n<a href="https://www.andiamo.co.uk/resources/iso-language-codes/">Regional Codes</a>
Gui, Add, DDL, vLanguage, %Language%||bg|cs|da|de|el|en|es|et|fi|fr|hu|it|ko|lt|lv|nl|pl|pt|ro|ru|sk|sl|sv|zh
Gui, Add, Checkbox, vTranslateDialog Checked%enableDialog%, Enable Dialog translations?
Gui, Add, Checkbox, vTranslateQuests Checked%enableQuests%, Enable Quest translations?
;Gui, Add, Checkbox, vTranslateWalkthrough Checked%enableWalkthrough%, Enable Walkthrough translations?
Gui, Add, Checkbox, vTranslateStory Checked%enableStory%, Enable Story translations?
Gui, Add, Checkbox, vTranslateMail Checked%enableMail%, Enable Mail translations?
Gui, Add, Checkbox, vTranslateloginMessage Checked%enableloginMessage%, Enable Login Message translations?
Gui, Add, CheckBox, vLog Checked%Log%, Enable logging to file?
Gui, Add, CheckBox, vJoystickEnabled Checked%JoystickEnabled%, Do you play with a controller?
Gui, Add, Button, gSave, Run ahkmon

;; Dialog Overlay settings tab
Gui, Tab, Dialog Overlay
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Overlay-Settings-tab">Dialog Overlay Documentation</a>
Gui, Add, CheckBox, vdialogResizeOverlay Checked%dialogResizeOverlay%, Allow resize of Dialog overlay?
Gui, Add, CheckBox, vdialogRoundedOverlay Checked%dialogRoundedOverlay%, Rounded Dialog overlay?
Gui, Add, CheckBox, vdialogAutoHideOverlay Checked%dialogAutoHideOverlay%, Automatically hide Dialog overlay?
Gui, Add, CheckBox, vdialogShowOnTaskbar Checked%dialogShowOnTaskbar%, Show Dialog overlay on taskbar when active?
Gui, Add, Text,, Dialog overlay transparency`n(lower = more transparent):
Gui, Add, Slider, vdialogOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %dialogOverlayTransparency%
Gui, Add, Text, vdialogOverlayColorInfo, Dialog overlay background color`n(use hex color codes):
Gui, Add, ComboBox, vdialogOverlayColor, %dialogOverlayColor%||
Gui, Add, Text, vdialogOverlayWidthInfo, Initial Dialog overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vdialogOverlayWidth Range100-2000, %dialogOverlayWidth%
Gui, Add, Text, vdialogOverlayHeightInfo, Initial Dialog overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vdialogOverlayHeight Range100-2000, %dialogOverlayHeight%
Gui, Add, Text, vdialogOverlayPosXInfo, Initial Dialog overlay horizontal position:
Gui, Add, Edit
Gui, Add, UpDown, vdialogOverlayPosX Range0-4000, %dialogOverlayPosX%
Gui, Add, Text, vdialogOverlayPosYInfo, Initial Dialog overlay vertical position:
Gui, Add, Edit
Gui, Add, UpDown, vdialogOverlayPosY Range0-4000, %dialogOverlayPosY%
Gui, Add, Text, vdialogFontColorInfo, Dialog overlay font color:
Gui, Add, ComboBox, vdialogFontColor, %dialogFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Dialog overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vdialogFontSize Range8-30, %dialogFontSize%
Gui, Add, Text, vdialogFontInfo, Select a font or enter a custom font available`non your system to use with the Dialog overlay:
Gui, Add, ComboBox, vdialogFontType, %dialogFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Quest Overlay settings tab
Gui, Tab, Quest Overlay
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Overlay-Settings-tab">Quest Overlay Documentation</a>
Gui, Add, CheckBox, vquestResizeOverlay Checked%questResizeOverlay%, Allow resize of Quest overlay?
Gui, Add, CheckBox, vquestRoundedOverlay Checked%questRoundedOverlay%, Rounded Quest overlay?
Gui, Add, CheckBox, vquestAutoHideOverlay Checked%questAutoHideOverlay%, Automatically hide Quest overlay?
Gui, Add, CheckBox, vquestShowOnTaskbar Checked%questShowOnTaskbar%, Show Quest overlay on taskbar when active?
Gui, Add, CheckBox, vquestOverlayEn Checked%questOverlayEn%, Show cut off English quest descriptions on overlay?
Gui, Add, Text,, Quest overlay transparency`n(lower = more transparent):
Gui, Add, Slider, vquestOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %questOverlayTransparency%
Gui, Add, Text, vquestOverlayColorInfo, Quest overlay background color`n(use hex color codes):
Gui, Add, ComboBox, vquestOverlayColor, %questOverlayColor%||
Gui, Add, Text, vquestOverlayWidthInfo, Initial Quest overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vquestOverlayWidth Range100-2000, %questOverlayWidth%
Gui, Add, Text, vquestOverlayHeightInfo, Initial Quest overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vquestOverlayHeight Range100-2000, %questOverlayHeight%
Gui, Add, Text, vquestOverlayPosXInfo, Initial Quest overlay horizontal position:
Gui, Add, Edit
Gui, Add, UpDown, vquestOverlayPosX Range0-4000, %questOverlayPosX%
Gui, Add, Text, vquestOverlayPosYInfo, Initial Quest overlay vertical position:
Gui, Add, Edit
Gui, Add, UpDown, vquestOverlayPosY Range0-4000, %questOverlayPosY%
Gui, Add, Text, vquestFontColorInfo, Quest overlay font color:
Gui, Add, ComboBox, vquestFontColor, %questFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Quest overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vquestFontSize Range8-30, %questFontSize%
Gui, Add, Text, vquestFontInfo, Select a font or enter a custom font available`non your system to use with the Quest overlay:
Gui, Add, ComboBox, vquestFontType, %questFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Story Overlay settings tab
Gui, Tab, Story Overlay
Gui, Add, CheckBox, vstoryResizeOverlay Checked%storyResizeOverlay%, Allow resize of Story overlay?
Gui, Add, CheckBox, vstoryRoundedOverlay Checked%storyRoundedOverlay%, Rounded Story overlay?
Gui, Add, CheckBox, vstoryAutoHideOverlay Checked%storyAutoHideOverlay%, Automatically hide Story overlay?
Gui, Add, CheckBox, vstoryShowOnTaskbar Checked%storyShowOnTaskbar%, Show Story overlay on taskbar when active?
Gui, Add, Text,, Story overlay transparency`n(lower = more transparent):
Gui, Add, Slider, vstoryOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %storyOverlayTransparency%
Gui, Add, Text, vstoryOverlayColorInfo, Story overlay background color`n(use hex color codes):
Gui, Add, ComboBox, vstoryOverlayColor, %storyOverlayColor%||
Gui, Add, Text, vstoryOverlayWidthInfo, Initial Story overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vstoryOverlayWidth Range100-2000, %storyOverlayWidth%
Gui, Add, Text, vstoryOverlayHeightInfo, Initial Story overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vstoryOverlayHeight Range100-2000, %storyOverlayHeight%
Gui, Add, Text, vstoryOverlayPosXInfo, Initial Story overlay horizontal position:
Gui, Add, Edit
Gui, Add, UpDown, vstoryOverlayPosX Range0-4000, %storyOverlayPosX%
Gui, Add, Text, vstoryOverlayPosYInfo, Initial Story overlay vertical position:
Gui, Add, Edit
Gui, Add, UpDown, vstoryOverlayPosY Range0-4000, %storyOverlayPosY%
Gui, Add, Text, vstoryFontColorInfo, Story overlay font color:
Gui, Add, ComboBox, vstoryFontColor, %storyFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Story overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vstoryFontSize Range8-30, %storyFontSize%
Gui, Add, Text, vstorytFontInfo, Select a font or enter a custom font available`non your system to use with the Story overlay:
Gui, Add, ComboBox, vstoryFontType, %storyFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana


;; Walkthrough Overlay settings tab
; Gui, Tab, Walkthrough Overlay
; Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Overlay-Settings-tab">Walkthrough overlay Documentation</a>
; Gui, Add, CheckBox, vwalkthroughResizeOverlay Checked%walkthroughResizeOverlay%, Allow resize of Walkthrough overlay?
; Gui, Add, CheckBox, vwalkthroughRoundedOverlay Checked%walkthroughRoundedOverlay%, Rounded Walkthrough overlay?
; Gui, Add, CheckBox, vwalkthroughAutoHideOverlay Checked%walkthroughAutoHideOverlay%, Automatically hide Walkthrough overlay?
; Gui, Add, CheckBox, vwalkthroughShowOnTaskbar Checked%walkthroughShowOnTaskbar%, Show Walkthrough overlay on taskbar when active?
; Gui, Add, Text,, Walkthrough overlay transparency`n(lower = more transparent):
; Gui, Add, Slider, vwalkthroughOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %walkthroughOverlayTransparency%
; Gui, Add, Text, vwalkthroughOverlayColorInfo, Walkthrough overlay background color`n(use hex color codes):
; Gui, Add, ComboBox, vwalkthroughOverlayColor, %walkthroughOverlayColor%||
; Gui, Add, Text, vwalkthroughOverlayWidthInfo, Initial Walkthrough overlay width:
; Gui, Add, Edit
; Gui, Add, UpDown, vwalkthroughOverlayWidth Range100-2000, %walkthroughOverlayWidth%
; Gui, Add, Text, vwalkthroughOverlayHeightInfo, Initial Walkthrough overlay height:
; Gui, Add, Edit
; Gui, Add, UpDown, vwalkthroughOverlayHeight Range100-2000, %walkthroughOverlayHeight%
; Gui, Add, Text, vwalkthroughOverlayPosXInfo, Initial Walkthrough overlay horizontal position:
; Gui, Add, Edit
; Gui, Add, UpDown, vwalkthroughOverlayPosX Range0-4000, %walkthroughOverlayPosX%
; Gui, Add, Text, vwalkthroughOverlayPosYInfo, Initial Walkthrough overlay vertical position:
; Gui, Add, Edit
; Gui, Add, UpDown, vwalkthroughOverlayPosY Range0-4000, %walkthroughOverlayPosY%
; Gui, Add, Text, vwalkthroughFontColorInfo, Walkthrough overlay font color:
; Gui, Add, ComboBox, vwalkthroughFontColor, %walkthroughFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
; Gui, Add, Text,, Walkthrough overlay font size:
; Gui, Add, Edit
; Gui, Add, UpDown, vwalkthroughFontSize Range8-30, %walkthroughFontSize%
; Gui, Add, Text, vwalkthroughFontInfo, Select a font or enter a custom font available`non your system to use with the Walkthrough overlay:
; Gui, Add, ComboBox, vwalkthroughFontType, %walkthroughFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Mail Overlay settings tab
Gui, Tab, Mail Overlay
Gui, Add, CheckBox, vmailResizeOverlay Checked%mailResizeOverlay%, Allow resize of Mail overlay?
Gui, Add, CheckBox, vmailRoundedOverlay Checked%mailRoundedOverlay%, Rounded Mail overlay?
Gui, Add, CheckBox, vmailAutoHideOverlay Checked%mailAutoHideOverlay%, Automatically hide Mail overlay?
Gui, Add, CheckBox, vmailShowOnTaskbar Checked%mailShowOnTaskbar%, Show Mail overlay on taskbar when active?
Gui, Add, Text,, Mail overlay transparency`n(lower = more transparent):
Gui, Add, Slider, vmailOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %mailOverlayTransparency%
Gui, Add, Text, vmailOverlayColorInfo, Mail overlay background color`n(use hex color codes):
Gui, Add, ComboBox, vmailOverlayColor, %mailOverlayColor%||
Gui, Add, Text, vmailOverlayWidthInfo, Initial Mail overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vmailOverlayWidth Range100-2000, %mailOverlayWidth%
Gui, Add, Text, vmailOverlayHeightInfo, Initial Mail overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vmailOverlayHeight Range100-2000, %mailOverlayHeight%
Gui, Add, Text, vmailOverlayPosXInfo, Initial Mail overlay horizontal position:
Gui, Add, Edit
Gui, Add, UpDown, vmailOverlayPosX Range0-4000, %mailOverlayPosX%
Gui, Add, Text, vmailOverlayPosYInfo, Initial Mail overlay vertical position:
Gui, Add, Edit
Gui, Add, UpDown, vmailOverlayPosY Range0-4000, %mailOverlayPosY%
Gui, Add, Text, vmailFontColorInfo, Mail overlay font color:
Gui, Add, ComboBox, vmailFontColor, %mailFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Mail overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vmailFontSize Range8-30, %mailFontSize%
Gui, Add, Text, vmailtFontInfo, Select a font or enter a custom font available`non your system to use with the Mail overlay:
Gui, Add, ComboBox, vmailFontType, %mailFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Login Message Overlay settings tab
Gui, Tab, Login Message Overlay
Gui, Add, CheckBox, vloginMessageResizeOverlay Checked%loginMessageResizeOverlay%, Allow resize of Login Message overlay?
Gui, Add, CheckBox, vloginMessageRoundedOverlay Checked%loginMessageRoundedOverlay%, Rounded Login Message overlay?
Gui, Add, CheckBox, vloginMessageAutoHideOverlay Checked%loginMessageAutoHideOverlay%, Automatically hide Login Message overlay?
Gui, Add, CheckBox, vloginMessageShowOnTaskbar Checked%loginMessageShowOnTaskbar%, Show Login Message overlay on taskbar when active?
Gui, Add, Text,, Login Message overlay transparency`n(lower = more transparent):
Gui, Add, Slider, vloginMessageOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %loginMessageOverlayTransparency%
Gui, Add, Text, vloginMessageOverlayColorInfo, Login Message overlay background color`n(use hex color codes):
Gui, Add, ComboBox, vloginMessageOverlayColor, %loginMessageOverlayColor%||
Gui, Add, Text, vloginMessageOverlayWidthInfo, Initial Login Message overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vloginMessageOverlayWidth Range100-2000, %loginMessageOverlayWidth%
Gui, Add, Text, vloginMessageOverlayHeightInfo, Initial Login Message overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vloginMessageOverlayHeight Range100-2000, %loginMessageOverlayHeight%
Gui, Add, Text, vloginMessageOverlayPosXInfo, Initial Login Message overlay horizontal position:
Gui, Add, Edit
Gui, Add, UpDown, vloginMessageOverlayPosX Range0-4000, %loginMessageOverlayPosX%
Gui, Add, Text, vloginMessageOverlayPosYInfo, Initial Login Message overlay vertical position:
Gui, Add, Edit
Gui, Add, UpDown, vloginMessageOverlayPosY Range0-4000, %loginMessageOverlayPosY%
Gui, Add, Text, vloginMessageFontColorInfo, Login Message overlay font color:
Gui, Add, ComboBox, vloginMessageFontColor, %loginMessageFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Login Message overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vloginMessageFontSize Range8-30, %loginMessageFontSize%
Gui, Add, Text, vloginMessagetFontInfo, Select a font or enter a custom font available`non your system to use with the Login Message overlay:
Gui, Add, ComboBox, vloginMessageFontType, %loginMessageFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Advanced tab
Gui, Tab, Advanced
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Advanced-tab">Advanced Settings Documentation</a>
Gui, Add, CheckBox, vShowFullDialog Checked%ShowFullDialog%, Show all text at once instead of line by line?
Gui, Add, Text, w+300 vLogLink,
Gui, Add, Text,, Download latest database`n(this will overwrite your current database!)
Gui, Add, Button, gDownloadDb, Download Database
Gui, Add, Text, w+300 vDatabaseStatusMessage,

;; Translate API tab
Gui, Tab, Translate APIs
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Translate-APIs-tab">Translate APIs Documentation</a>
Gui, Add, Text, y+2, Configure one or the other - not both!
Gui, Add, Text,, DeepL Configuration:
Gui, Add, CheckBox, vUseDeepLTranslate Checked%UseDeepLTranslate%, Use DeepL Translate
Gui, Add, CheckBox, vDeepLApiPro Checked%DeepLApiPro%, Use DeepL Pro APIs
Gui, Add, Text,, DeepL API Key:
Gui, Add, Edit, r1 vDeepLAPIKey w135, %DeepLAPIKey%
Gui, Add, Button, gDeepLWordsLeft, Check remaining character count
Gui, Add, Text, w+300 vDeepLWords,
Gui, Add, Text,, ----------------------------------------------------
Gui, Add, Text,, Google Translate Configuration:
Gui, Add, CheckBox, vUseGoogleTranslate Checked%UseGoogleTranslate%, Use Google Translate
Gui, Add, Text,, Google Translate API Key:
Gui, Add, Edit, r1 vGoogleTranslateAPIKey w135, %GoogleTranslateAPIKey%
Gui, Add, Button, gGoogleTranslateValidate, Test Google Translate API Key
Gui, Add, Text, w+300 vGoogleTranslateValidate,

;; Help tab
Gui, Tab, Help
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Troubleshooting">Troubleshooting ahkmon</a>

;; About tab
Gui, Tab, About
Gui, Add, Link,, Join the unofficial Dragon Quest X <a href="https://discord.gg/UFaUHBxKMY">Discord</a>!
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon">Get the Source</a>
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki">Documentation</a>
Gui, Add, Text,, Originally developed by Serany.
Gui, Add, Text,, We appreciate all the work you've done for us!

;=== Misc Start GUI =======================================================
Gui, Show, Autosize
Return

DeepLWordsLeft:
  GuiControlGet, DeepLApiPro
  GuiControlGet, DeepLAPIKey

  if DeepLApiPro = 1
    url := "https://api.deepl.com/v2"
  else
    url := "https://api-free.deepl.com/v2"

  oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  url := url . "/usage?auth_key=" . DeepLAPIKey
  oWhr.Open("POST", url, 0)
  oWhr.SetRequestHeader("User-Agent", "DQXTranslator")
  oWhr.Send()
  oWhr.WaitForResponse()
  jsonResponse := JSON.Load(oWhr.ResponseText)
  charRemaining := (jsonResponse.character_limit - jsonResponse.character_count)
  if (charRemaining != "")
    GuiControl, Text, DeepLWords, %charRemaining% characters remaining
  else
    GuiControl, Text, DeepLWords, Key validation failed
  return

GoogleTranslateValidate:
  GuiControlGet, GoogleTranslateAPIKey

  body := "&source=ja" . "&target=" . Language . "&q=" . ""
  url := "https://www.googleapis.com/language/translate/v2?key=" . GoogleTranslateAPIKey . body
  oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  oWhr.Open("POST", url, 0)
  oWhr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
  oWhr.Send()
  oWhr.WaitForResponse()
  arr := oWhr.responseBody
  pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
  length := arr.MaxIndex() + 1
  response := StrGet(pData, length, "utf-8")
  jsonResponse := JSON.Load(response)
  validate := jsonResponse.data.translations[1].translatedText
  if (validate = "")
    GuiControl, Text, GoogleTranslateValidate, Success!
  else
    GuiControl, Text, GoogleTranslateValidate, Failed to validate

DownloadDb:
  UrlDownloadToFile, https://github.com/dqx-translation-project/ahkmon/raw/main/dqxtrl.db, dqxtrl.db
  if ErrorLevel
    GuiControl, Text, DatabaseStatusMessage, Database failed to update.
  else
    GuiControl, Text, DatabaseStatusMessage, Database updated!
  return

;; What to do when the app is gracefully closed
GuiEscape:
GuiClose:
{
  Process, Close, dialogFinder.exe
  Process, Close, questFinder.exe
  Process, Close, walkthroughFinder.exe
  Process, Close, mapQuestFinder.exe
  Process, Close, storyFinder.exe
  Process, Close, mailFinder.exe
  Process, Close, voicemailFinder.exe
  Process, Close, loginMessageFinder.exe
  ExitApp
}

;=== Save Start GUI settings to ini ==========================================
Save:
  Gui, Submit, Hide
  IniWrite, %Language%, settings.ini, general, Language
  IniWrite, %Log%, settings.ini, general, Log
  IniWrite, %JoystickEnabled%, settings.ini, general, JoystickEnabled
  IniWrite, %translateWalkthrough%, settings.ini, general, enableWalkthrough
  IniWrite, %translateDialog%, settings.ini, general, enableDialog
  IniWrite, %translateQuests%, settings.ini, general, enableQuests
  IniWrite, %translateStory%, settings.ini, general, enableStory
  IniWrite, %translateMail%, settings.ini, general, enableMail
  IniWrite, %translateloginMessage%, settings.ini, general, enableloginMessage
  IniWrite, %dialogOverlayWidth%, settings.ini, dialogoverlay, dialogOverlayWidth
  IniWrite, %dialogRoundedOverlay%, settings.ini, dialogoverlay, dialogRoundedOverlay
  IniWrite, %dialogOverlayHeight%, settings.ini, dialogoverlay, dialogOverlayHeight
  IniWrite, %dialogOverlayColor%, settings.ini, dialogoverlay, dialogOverlayColor
  IniWrite, %dialogResizeOverlay%, settings.ini, dialogoverlay, dialogResizeOverlay
  IniWrite, %dialogAutoHideOverlay%, settings.ini, dialogoverlay, dialogAutoHideOverlay
  IniWrite, %dialogFontColor%, settings.ini, dialogoverlay, dialogFontColor
  IniWrite, %dialogFontSize%, settings.ini, dialogoverlay, dialogFontSize
  IniWrite, %dialogFontType%, settings.ini, dialogoverlay, dialogFontType
  IniWrite, %dialogOverlayTransparency%, settings.ini, dialogoverlay, dialogOverlayTransparency
  IniWrite, %dialogShowOnTaskbar%, settings.ini, dialogoverlay, dialogShowOnTaskbar
  IniWrite, %dialogOverlayPosX%, settings.ini, dialogoverlay, dialogOverlayPosX
  IniWrite, %dialogOverlayPosY%, settings.ini, dialogoverlay, dialogOverlayPosY
  IniWrite, %questOverlayWidth%, settings.ini, questoverlay, questOverlayWidth
  IniWrite, %questRoundedOverlay%, settings.ini, questoverlay, questRoundedOverlay
  IniWrite, %questOverlayHeight%, settings.ini, questoverlay, questOverlayHeight
  IniWrite, %questOverlayColor%, settings.ini, questoverlay, questOverlayColor
  IniWrite, %questResizeOverlay%, settings.ini, questoverlay, questResizeOverlay
  IniWrite, %questAutoHideOverlay%, settings.ini, questoverlay, questAutoHideOverlay
  IniWrite, %questFontColor%, settings.ini, questoverlay, questFontColor
  IniWrite, %questFontSize%, settings.ini, questoverlay, questFontSize
  IniWrite, %questFontType%, settings.ini, questoverlay, questFontType
  IniWrite, %questOverlayTransparency%, settings.ini, questoverlay, questOverlayTransparency
  IniWrite, %questShowOnTaskbar%, settings.ini, questoverlay, questShowOnTaskbar
  IniWrite, %questOverlayPosX%, settings.ini, questoverlay, questOverlayPosX
  IniWrite, %questOverlayPosY%, settings.ini, questoverlay, questOverlayPosY
  IniWrite, %questOverlayEn%, settings.ini, questoverlay, questOverlayEn
  IniWrite, %walkthroughOverlayWidth%, settings.ini, walkthroughoverlay, walkthroughOverlayWidth
  IniWrite, %walkthroughRoundedOverlay%, settings.ini, walkthroughoverlay, walkthroughRoundedOverlay
  IniWrite, %walkthroughOverlayHeight%, settings.ini, walkthroughoverlay, walkthroughOverlayHeight
  IniWrite, %walkthroughOverlayColor%, settings.ini, walkthroughoverlay, walkthroughOverlayColor
  IniWrite, %walkthroughResizeOverlay%, settings.ini, walkthroughoverlay, walkthroughResizeOverlay
  IniWrite, %walkthroughAutoHideOverlay%, settings.ini, walkthroughoverlay, walkthroughAutoHideOverlay
  IniWrite, %walkthroughFontColor%, settings.ini, walkthroughoverlay, walkthroughFontColor
  IniWrite, %walkthroughFontSize%, settings.ini, walkthroughoverlay, walkthroughFontSize
  IniWrite, %walkthroughFontType%, settings.ini, walkthroughoverlay, walkthroughFontType
  IniWrite, %walkthroughOverlayTransparency%, settings.ini, walkthroughoverlay, walkthroughOverlayTransparency
  IniWrite, %walkthroughOverlayPosX%, settings.ini, walkthroughoverlay, walkthroughOverlayPosX
  IniWrite, %walkthroughOverlayPosY%, settings.ini, walkthroughoverlay, walkthroughOverlayPosY
  IniWrite, %storyResizeOverlay%, settings.ini, storyoverlay, storyResizeOverlay
  IniWrite, %storyRoundedOverlay%, settings.ini, storyoverlay, storyRoundedOverlay
  IniWrite, %storyAutoHideOverlay%, settings.ini, storyoverlay, storyAutoHideOverlay
  IniWrite, %storyShowOnTaskbar%, settings.ini, storyoverlay, storyShowOnTaskbar
  IniWrite, %storyOverlayWidth%, settings.ini, storyoverlay, storyOverlayWidth
  IniWrite, %storyOverlayHeight%, settings.ini, storyoverlay, storyOverlayHeight
  IniWrite, %storyOverlayColor%, settings.ini, storyoverlay, storyOverlayColor
  IniWrite, %storyFontColor%, settings.ini, storyoverlay, storyFontColor
  IniWrite, %storyFontSize%, settings.ini, storyoverlay, storyFontSize
  IniWrite, %storyFontType%, settings.ini, storyoverlay, storyFontType
  IniWrite, %storyOverlayTransparency%, settings.ini, storyoverlay, storyOverlayTransparency
  IniWrite, %storyOverlayPosX%, settings.ini, storyoverlay, storyOverlayPosX
  IniWrite, %storyOverlayPosY%, settings.ini, storyoverlay, storyOverlayPosY
  IniWrite, %mailOverlayWidth%, settings.ini, mailoverlay, mailOverlayWidth
  IniWrite, %mailRoundedOverlay%, settings.ini, mailoverlay, mailRoundedOverlay
  IniWrite, %mailOverlayHeight%, settings.ini, mailoverlay, mailOverlayHeight
  IniWrite, %mailOverlayColor%, settings.ini, mailoverlay, mailOverlayColor
  IniWrite, %mailResizeOverlay%, settings.ini, mailoverlay, mailResizeOverlay
  IniWrite, %mailAutoHideOverlay%, settings.ini, mailoverlay, mailAutoHideOverlay
  IniWrite, %mailFontColor%, settings.ini, mailoverlay, mailFontColor
  IniWrite, %mailFontSize%, settings.ini, mailoverlay, mailFontSize
  IniWrite, %mailFontType%, settings.ini, mailoverlay, mailFontType
  IniWrite, %mailOverlayTransparency%, settings.ini, mailoverlay, mailOverlayTransparency
  IniWrite, %mailShowOnTaskbar%, settings.ini, mailoverlay, mailShowOnTaskbar
  IniWrite, %mailOverlayPosX%, settings.ini, mailoverlay, mailOverlayPosX
  IniWrite, %mailOverlayPosY%, settings.ini, mailoverlay, mailOverlayPosY
  IniWrite, %loginMessageResizeOverlay%, settings.ini, loginMessageoverlay, loginMessageResizeOverlay
  IniWrite, %loginMessageRoundedOverlay%, settings.ini, loginMessageoverlay, loginMessageRoundedOverlay
  IniWrite, %loginMessageAutoHideOverlay%, settings.ini, loginMessageoverlay, loginMessageAutoHideOverlay
  IniWrite, %loginMessageShowOnTaskbar%, settings.ini, loginMessageoverlay, loginMessageShowOnTaskbar
  IniWrite, %loginMessageOverlayWidth%, settings.ini, loginMessageoverlay, loginMessageOverlayWidth
  IniWrite, %loginMessageOverlayHeight%, settings.ini, loginMessageoverlay, loginMessageOverlayHeight
  IniWrite, %loginMessageOverlayColor%, settings.ini, loginMessageoverlay, loginMessageOverlayColor
  IniWrite, %loginMessageFontColor%, settings.ini, loginMessageoverlay, loginMessageFontColor
  IniWrite, %loginMessageFontSize%, settings.ini, loginMessageoverlay, loginMessageFontSize
  IniWrite, %loginMessageFontType%, settings.ini, loginMessageoverlay, loginMessageFontType
  IniWrite, %loginMessageOverlayTransparency%, settings.ini, loginMessageoverlay, loginMessageOverlayTransparency
  IniWrite, %loginMessageOverlayPosX%, settings.ini, loginMessageoverlay, loginMessageOverlayPosX
  IniWrite, %loginMessageOverlayPosY%, settings.ini, loginMessageoverlay, loginMessageOverlayPosY
  IniWrite, %ShowFullDialog%, settings.ini, advanced, ShowFullDialog
  IniWrite, %UseDeepLTranslate%, settings.ini, deepl, UseDeepLTranslate
  IniWrite, %DeepLApiPro%, settings.ini, deepl, DeepLApiPro
  IniWrite, %DeepLAPIKey%, settings.ini, deepl, DeepLAPIKey
  IniWrite, %UseGoogleTranslate%, settings.ini, google, UseGoogleTranslate
  IniWrite, %GoogleTranslateAPIKey%, settings.ini, google, GoogleTranslateAPIKey

;=== Verify user picked one of the API options ===============================
if (UseDeepLTranslate = 1 && UseGoogleTranslate = 1)
{
  MsgBox You enabled both DeepL and Google Translate. Please select one or the other.
  ExitApp
}

if (UseDeepLTranslate = 0 && UseGoogleTranslate = 0)
{
  MsgBox You didn't enable a translation service. Please enable the one you want to use and try again.
  ExitApp
}

;=== Start DQ memreads =======================================================
;; Pass arbitrary arg. Don't want user to run these directly.
if (translateDialog = 1)
  Run, dialogFinder.exe "nothing"
Sleep 500
if (translateQuests = 1)
{
  Run, questFinder.exe "nothing"
  Run, mapQuestFinder.exe "nothing"
}
; Disabling Story and Mail for now, as no consistent pointers could be found as of game version 6.5.0
/*
if (translateStory = 1)
{
  Run, storyFinder.exe "nothing"
}
if (translateMail = 1)
{
  Run, mailFinder.exe "nothing"
  Run, voicemailFinder.exe "nothing"
}
*/
if (translateloginMessage = 1)
{
  Run, loginMessageFinder.exe "nothing"
}

;; If ahkmon is closed, kill the child processes it spawned as well.
OnExit("ExitSub")

ExitSub()
{
  Process, Close, questFinder.exe
  Process, Close, dialogFinder.exe
  Process, Close, mapQuestFinder.exe
  Process, Close, storyFinder.exe
  Process, Close, mailFinder.exe
  Process, Close, voicemailFinder.exe
  Process, Close, loginMessageFinder.exe
  ExitApp
}

downloadFile(url, dir := "", fileName := "glossary.csv")
{
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  whr.Open("GET", url, true)
  whr.Send()
  whr.WaitForResponse()

  body := whr.ResponseBody
  data := NumGet(ComObjValue(body) + 8 + A_PtrSize, "UInt")
  size := body.MaxIndex() + 1

  if !InStr(FileExist(dir), "D")
    FileCreateDir % dir

  SplitPath url, urlFileName
  f := FileOpen(dir (fileName ? fileName : urlFileName), "w")
  f.RawWrite(data + 0, size)
  f.Close()
}
