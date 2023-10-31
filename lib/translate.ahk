#Include <glossary>

translate(dqText, isDialog)
{
  ;; Open database connection.
  dbFileName := A_ScriptDir . "\dqxtrl.db"
  db := New SQLiteDB

  ;; Iterate through each line returned.
  fullDialog :=
  for index, sentence in StrSplit(dqText, "`n`n", "`r")
  {
    if sentence = ""
      continue
    else
    {
      ;; See if we have an entry available to grab from the database before sending the request to translate.
      result :=
      sentence := StrReplace(sentence, "'", "''")  ;; Escape single quotes found in contractions before sending to database

      query := "SELECT " . Language . " FROM dialog WHERE jp = '" . sentence . "';"

      if !db.OpenDB(dbFileName)
        MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

      if !db.GetTable(query, result)
        MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

      result := result.Rows[1,1]
    }

    ;; If no matching line was found in the database, query the translation service.
    if !result
    {
      ;; Replace text with glossary before sending off to be translated
      glossified_sentence := glossify(sentence)
      StringReplace,glossified_sentence,glossified_sentence,`n,,A
      StringReplace,glossified_sentence,glossified_sentence,`r,,A

      ;; If not found locally, make a call to the translate API to get translated text.
      if UseDeepLTranslate = 1
      {
        if Language = "en"
          Language := "en-us"

        StringUpper, languageUpper, Language
        Body := "auth_key="
              . DeepLAPIKey
              . "&source_lang=JA"
              . "&target_lang="
              . languageUpper
              . "&text="
              . glossified_sentence

        if DeepLApiPro = 1
          url := "https://api.deepl.com/v2/translate"
        else
          url := "https://api-free.deepl.com/v2/translate"

        oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        oWhr.Open("POST", url, 0)
        oWhr.SetRequestHeader("User-Agent", "DQXTranslator")
        oWhr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
        oWhr.Send(Body)
        oWhr.WaitForResponse()

        ;; Translated dialog text. We want to convert the response to UTF-8, as we support
        ;; multiple languages with different glyphs/characters.
        arr := oWhr.responseBody
        pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
        length := arr.MaxIndex() + 1
        response := StrGet(pData, length, "utf-8")
        jsonResponse := JSON.Load(response)
        translatedText := jsonResponse.translations[1].text

        ;;Change back to en for general purpose
        if Language = "en-us"
          Language := "en"
      }

      if (UseGoogleTranslate = 1)
      {
        body := "&source=ja" . "&target=" . Language . "&q=" . glossified_sentence

        url := "https://www.googleapis.com/language/translate/v2?key=" . GoogleTranslateAPIKey . body
        oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        oWhr.Open("POST", url, 0)
        oWhr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        oWhr.Send()
        oWhr.WaitForResponse()

        ;; We want to convert the response to UTF-8, as we support
        ;; multiple languages with different glyphs/characters.
        arr := oWhr.responseBody
        pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
        length := arr.MaxIndex() + 1
        response := StrGet(pData, length, "utf-8")
        jsonResponse := JSON.Load(response)
        translatedText := jsonResponse.data.translations[1].translatedText
      }

      if (translatedText = "")
      {
        fullDialog := "Failed to talk to the configured translation service. Your API key is likely invalid or your glossary ID could be invalid."
        if (Log = 1)
          FileAppend, JP: %sentence%`nEN: Did not translate.`n`n, txtout.txt, UTF-8
        return fullDialog
        continue
      }

      ;; Replace encoded text with actual characters
      translatedText := StrReplace(translatedText, "&quot;", """")
      translatedText := StrReplace(translatedText, "&#39;", "'")
      translatedText := StrReplace(translatedText, "…", "...")

      ;; Sanitize text that comes back
      if (Language = "en")
        translatedText := StrReplace(translatedText, "ã"," ")

      translatedText := StrReplace(translatedText, "'","''")  ;; Escape single quotes found in contractions before sending to database

      ;; Write new entry to the database if it doesn't exist.
      ;; If we're in this block, jp was found, but translation for another language
      ;; doesn't, so we update it here.

      selectQuery := "SELECT jp FROM dialog WHERE jp = '" . sentence . "'"
      insertQuery := "INSERT INTO dialog (jp, " . Language . ") VALUES ('" . sentence . "', '" . translatedText . "');"
      updateQuery := "UPDATE dialog SET " . Language . " = '" . translatedText . "' WHERE jp = '" . sentence . "'"

      db.Exec("BEGIN TRANSACTION;")
      db.GetTable(selectQuery, result)

      result := result.Rows[1,1]

      if !result
        db.Exec(insertQuery)
      else
        db.Exec(updatequery)

      db.Exec("COMMIT TRANSACTION;")

      ;; Remove escaped single quotes that were escaped for the SQLite transation.
      translatedText := StrReplace(translatedText, "''","'")

      ;; Don't add newlines if it isn't dialog text.
      if (isDialog = "true")
        fullDialog .= translatedText "`n`n"
      else
        fullDialog .= translatedText

      if (Log = 1)
        FileAppend, JP: %sentence%`nEN: %translatedText%`n`n, txtout.txt, UTF-8
    }
    ;; An entry in the database was found, so add to it here.
    ;; Don't add newlines if it isn't dialog text.
    else
    {
      if isDialog = "true"
        fullDialog .= result "`n`n"
      else
        fullDialog .= result

      if Log = 1
        FileAppend, JP: %sentence%`nEN: %result%`n`n, txtout.txt, UTF-8
    }
  }

  ;; Close database connection.
  db.CloseDB()

  return fullDialog
}
