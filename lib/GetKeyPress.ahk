;; Controller/Keyboard function to progress text
GetKeyPress(keyStr) {
  keys := StrSplit(keyStr, ",")
  loop
    for each, key in keys
      if GetKeyState(key)
      {
        KeyWait, %key%
        return key
      }
}