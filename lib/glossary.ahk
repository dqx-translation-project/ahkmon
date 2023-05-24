;; UTF-8-BOM encoding

; Pass 'text' to glossify to return a string passed through glossary.csv.
glossify(text)
{
    FileEncoding, UTF-8
    Loop, Read, glossary.csv
    {
        array := StrSplit(A_LoopReadLine, ",", , 2)  ; split row on first instance of comma
        if array[2] = """"""  ; escape double quotes
            array[2] := ""
        text := StrReplace(text, array[1], array[2])
    }
    Return text
}
