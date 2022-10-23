#Include <JSON>

create_glossary(api_key, is_pro)
{
	;FileEncoding, UTF-8
	;FileRead, entries_str, glossary.csv

	entries_str := ""

	Loop, Read, glossary.csv
	{
		loop_str := A_LoopReadLine

		loop_str := StrReplace(loop_str, """", """""")
		loop_str := StrReplace(loop_str, ",", ",""",, 1)
		loop_str := loop_str . """`n"

		;StringReplace, entries_str, entries_str, ", "", All
		;StringReplace, entries_str, entries_str, ",", ","", All

		;if InStr(loop_str, "`r`n")
			;StringReplace, entries_str, entries_str, "\n", ""\n", All
			;loop_str := StrReplace(loop_str, "`r`n", """`r`n")
		;else
			;loop_str := loop_str . """"

		entries_str := entries_str . loop_str

	}

	entries_str := SubStr(entries_str, 1, -1)

	encoded_text := EncodeDecodeURI(entries_str)

	Body := "name=DQX Glossary"
			. "&source_lang=ja"
			. "&target_lang=en"
			. "&entries="
			. encoded_text
			. "&entries_format=csv"

	if is_pro = 1
	  url := "https://api.deepl.com/v2/glossaries"
	else
	  url := "https://api-free.deepl.com/v2/glossaries"

	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("POST", url, 0)
	whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	whr.SetRequestHeader("Authorization", "DeepL-Auth-Key " + api_key)
	whr.Send(Body)
	whr.WaitForResponse()

	response := JSON.Load(whr.ResponseText)
	new_id := response.glossary_id

	if(new_id != "")
	{
		IniWrite, %new_id%, settings.ini, deepl, GlossaryID
	}
	else
	{
		MsgBox % "ERROR" . whr.ResponseText . " There was an error creating a glossary id. The glossary feature will be disabled for this session."
		IniWrite, EMPTY, settings.ini, deepl, GlossaryID
	}
}

delete_glossary(glossary_id, api_key, pro)
{
	if is_pro = 1
	  url := "https://api.deepl.com/v2/glossaries/"
	else
	  url := "https://api-free.deepl.com/v2/glossaries/"

	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("DELETE", url, 0)
	whr.SetRequestHeader("Authorization", "DeepL-Auth-Key " + api_key)
	whr.Send(url . glossary_id)
	whr.WaitForResponse()
}

;https://www.autohotkey.com/board/topic/6199-url-encoding/
;~ EncodeURL( p_data, p_reserved=true, p_encode=true )
;~ {
	;~ old_FormatInteger := A_FormatInteger
	;~ SetFormat, Integer, hex

	;~ unsafe =
		;~ ( Join LTrim
			;~ 25000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
			;~ 22233C3E5B5C5D5E607B7C7D7F808182838485868788898A8B8C8D8E8F9091929394
			;~ 95969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6
			;~ B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8
			;~ D9DADBDCDDDEDF7EE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9
			;~ FAFBFCFDFEFF
		;~ )

	;~ if ( p_reserved )
		;~ unsafe = %unsafe%24262B2C2F3A3B3D3F40

	;~ if ( p_encode )
		;~ loop, % StrLen( unsafe )//2
		;~ {
			;~ StringMid, token, unsafe, A_Index*2-1, 2
			;~ StringReplace, p_data, p_data, % Chr( "0x" token ), `%%token%, all
		;~ }
	;~ else
		;~ loop, % StrLen( unsafe )//2
		;~ {
			;~ StringMid, token, unsafe, A_Index*2-1, 2
			;~ StringReplace, p_data, p_data, `%%token%, % Chr( "0x" token ), all
		;~ }

	;~ SetFormat, Integer, %old_FormatInteger%

	;~ return, p_data
;~ }

;~ UriEncode(Uri, Enc = "UTF-8")
;~ {
	;~ StrPutVar(Uri, Var, Enc)
	;~ f := A_FormatInteger
	;~ SetFormat, IntegerFast, H
	;~ Loop
	;~ {
		;~ Code := NumGet(Var, A_Index - 1, "UChar")
		;~ If (!Code)
			;~ Break
		;~ If (Code >= 0x30 && Code <= 0x39 ; 0-9
			;~ || Code >= 0x41 && Code <= 0x5A ; A-Z
			;~ || Code >= 0x61 && Code <= 0x7A) ; a-z
			;~ Res .= Chr(Code)
		;~ Else
			;~ Res .= "%" . SubStr(Code + 0x100, -1)
	;~ }
	;~ SetFormat, IntegerFast, %f%
	;~ Return, Res
;~ }

EncodeDecodeURI(str, encode := true, component := true) {
   static Doc, JS
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
      ( Doc.documentMode < 9 && JS.execScript() )
   }
   Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}