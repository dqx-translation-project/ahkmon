#Persistent
#NoEnv
#SingleInstance force
#Include <JSON>

/*
*************************************************
Used to auto update ahkmon to the latest version
*************************************************
*/

;=== Display GUI to user showing the update is happening =======================
Gui, -SysMenu +AlwaysOnTop +E0x08000000
Gui, Add, Progress, w500 h15 c0096FF Background0a2351 vProgress, 0
Gui, Font, s12
Gui, Add, Edit, vNotes w500 r10 +ReadOnly -WantCtrlA -WantReturn, Updating..
Gui, Add, Button, w60 +x225 Default +Disabled, OK
Gui, Show, Autosize
;===============================================================================

;; Make sure /tmp is clean by deleting + re-creating, then move updater into /tmp.
FileRemoveDir, %A_ScriptDir%\tmp
sleep 100
FileCreateDir, %A_ScriptDir%\tmp
sleep 100
FileMove, %A_ScriptDir%\ahkmon_updater.exe, %A_ScriptDir%\tmp\ahkmon_updater.exe

;; Download latest version
url := "https://github.com/dqx-translation-project/ahkmon/releases/latest/download/ahkmon.zip"
downloadFile(url)
GuiControl,, Progress, 25

;; Grab release notes + new version number
oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
url := "https://api.github.com/repos/dqx-translation-project/ahkmon/releases/latest"
oWhr.Open("GET", url, 0)
oWhr.Send()
oWhr.WaitForResponse()
jsonResponse := JSON.Load(oWhr.ResponseText)
releaseVersion := (jsonResponse.tag_name)
releaseVersion := SubStr(releaseVersion, 2)
releaseNotes := (jsonResponse.body)
releaseNotes := RegExReplace(releaseNotes, "\r\n", "`n")
GuiControl,, Progress, 50

;; Back up existing translation database before pulling new
GuiControl,, Notes, Backing up existing translation database..
FileCreateDir, %A_ScriptDir%\backup
FileMove, %A_ScriptDir%\dqxtrl.db, %A_ScriptDir%\backup\dqxtrl_%releaseVersion%.db

;; Unzip files that were downloaded into same directory, overwriting anything
unzipName := A_ScriptDir "\ahkmon.zip"
unzipLoc := A_ScriptDir
Unz(unzipName, unzipLoc)
GuiControl,, Progress, 75

;; Get current version locally from version file
FileRead, currentVersion, version

;; Compare local version with remote. If same, update was successful.
if (releaseVersion = currentVersion)
{
  GuiControl,, Progress, 100
  message := "UPDATE SUCCESSFUL!`n`nahkmon Version: " . releaseVersion . "`n`nRelease Notes:`n`n" . releaseNotes
  GuiControl,, Notes, % message
  FileDelete, %A_ScriptDir%\ahkmon.zip  ;; Delete the old file
  GuiControl, Enable, OK
  Return

ButtonOK:
  Run ahkmon.exe
  ExitApp

}
;; If versions are different, update failed. Make user aware and send them to github to download.
else
{
  GuiControl,, Progress, 100
  FileMove, %A_ScriptDir%\tmp\ahkmon_updater.exe, %A_ScriptDir%\ahkmon_updater.exe  ;; If failed, put updater back
  sleep 100
  FileRemoveDir, %A_ScriptDir%\tmp  ;; Remove /tmp folder
  message := "UPDATE FAILED! Version mismatch. Please update ahkmon manually."
  GuiControl,, Notes, % message
  FileDelete, %A_ScriptDir%\ahkmon.zip  ;; Delete the old file if it exists
  Run, https://github.com/dqx-translation-project/ahkmon/releases/latest
  Sleep 5000
  ExitApp
}

;=== Functions ==========================================================
downloadFile(url, dir := "", fileName := "ahkmon.zip") 
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

Unz(sZip, sUnz)
{
  FileCreateDir, %sUnz%
    psh  := ComObjCreate("Shell.Application")
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
}
