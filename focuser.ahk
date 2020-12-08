#Include packages\AutohotkeyJSON\JSON.ahk

counter := new FocusTimer

; -----------------
; P1
; ---------------------------
EnvSet, P1upKey, Up
EnvSet, P1leftKey, Left
EnvSet, P1rightKey, Right
EnvSet, P1downKey, Down
EnvSet, P1aKey, j
EnvSet, P1bKey, i
EnvSet, P1xKey, k
EnvSet, P1yKey, l
EnvSet, P1zKey, o

; -----------------
; P2
; ---------------------------
EnvSet, P2upKey, w
EnvSet, P2leftKey, a
EnvSet, P2rightKey, d
EnvSet, P2downKey, s
EnvSet, P2aKey, f
EnvSet, P2bKey, t
EnvSet, P2xKey, t
EnvSet, P2yKey, h
EnvSet, P2zKey, y

; -----------------
; Basic traversal buttons (two black buttons)
; ---------------------------
EnvSet, enterKey, Enter
EnvSet, escKey, Esc

; An example class for counting the seconds...
class FocusTimer {
    __New() {
        this.interval := 1500
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
        this.currentlyOpenGame := ""
        this.titleDict := {}
    }
    Start() {
        ; Known limitation: SetTimer requires a plain variable reference.
        timer := this.timer
        SetTimer % timer, % this.interval
        OutputDebug, % "Counter started"
        
        ; Read files and fill titleDict
        FileEncoding, UTF-8
        Loop, Files, %A_ScriptDir%\MOCSArcadeGames\*, D
        {
            GetFile(A_LoopFileName)
            keybinds := GetFile(gameName)
            For Key, Value in keybinds
             {
                switch Key
                {
                    case "title":
                        this.titleDict[A_LoopFileName] := Value
                }
             }
        }
        for key, value in this.titleDict
            OutputDebug, %key% %value%
    }
    Stop() {
        ; To turn off the timer, we must pass the same object as before:
        timer := this.timer
        SetTimer % timer, Off
        OutputDebug, % "Counter stopped"
    }
    ; Every time interval, focus on the main game
    Tick() {
        local gameTitle = FindOpenGameTitle(this.titleDict, this.currentlyOpenGame)
        ; Periodically focusing on open game
        ;; SetTitleMatchMode RegEx
        SetTitleMatchMode 3
        if (gameTitle == "")
            Restart_Launcher(titleDict) ; If the return is an empty string, open launcher
        else if (WinExist(gameTitle)) {
            WinActivate
            ; Starting new game
            OutputDebug, % "Comparing " gameTitle " and " this.currentlyOpenGame
            if (gameTitle != this.currentlyOpenGame) {
                this.currentlyOpenGame := gameTitle
                ; Open config and set keybinds
                OutputDebug, % "Changing config"
                ConfigNewGame(this.titleDict, gameTitle)
            }
        }
        else
            KillAllGames(this.titleDict) ; If the game title returned doesn't exist, clean restart
    }
}

; Goes through titleDict and checks if any games with those titles are open
FindOpenGameTitle(titleDict, currentlyOpenGame) {
    
    local gameTitle = 0
    local numGamesFound = 0

    ; Find all open games
    for key, value in titleDict
    {
        SetTitleMatchMode 3
        if (WinExist(value)) {
            local foundVar
            WinGetTitle, foundVar
            gameTitle := value
            numGamesFound++
        }
    }

    if(numGamesFound > 1)
    {
        ; Close all but one game, giving precedence to the NOT currently open game
        SetTitleMatchMode 3
        if WinExist(currentlyOpenGame) {
            WinClose
            numGamesFound--
        }
        for key, value in titleDict
        {
            if (WinExist(value) && numGamesFound > 1) {
                WinClose
                numGamesFound--
            }
            ; Finally, change the game title to the remaining open game
            if (WinExist(value) && numGamesFound == 1) {
                gameTitle := value
            }
        }
    }
    else if(numGamesFound == 1)
    {
        return gameTitle
    }
    else
    {
        return ""
    }
}

Restart_Launcher(titleDict) {
    OutputDebug, % "Run the launcher"
    ; TODO: Open launcher

    ; ConfigNewGame("Launcher")
}

GetFile(gameName) {
    if(FileExist("MOCSArcadeGames/" gameName "/config.json") == "")
    {
        req := ComObjCreate("Msxml2.XMLHTTP")
        req.open("GET", "https://mocsarcade.herokuapp.com/user/Keybinds/Cubix", false)
        req.send()
        FileAppend, % req.responseText, MOCSArcadeGames/%gameName%/config.json
    }
    FileRead, keybinds_json, MOCSArcadeGames/%gameName%/config.json
    keybinds := JSON.Load( keybinds_json )
    
    return keybinds
}

ConfigNewGame(titleDict, gameTitle) {
    ; Get game NAME (of folder) from dictionary
    local gameName = ""
    for key, value in titleDict
    {
        if(value == gameTitle)
            gameName := key
    }
    
    keybinds := GetFile(gameName)
    For Key, Value in keybinds
    {
        OutputDebug, % Key . " -> " . Value
        switch Key
        {
            case "P1Up":      EnvSet, P1upKey, Value
            case "P1Down":    EnvSet, P1downKey, Value
            case "P1Left":    EnvSet, P1leftKey, Value
            case "P1Right":   EnvSet, P1rightKey, Value
            case "P1A":       EnvSet, P1aKey, Value
            case "P1B":       EnvSet, P1bKey, Value
            case "P1X":       EnvSet, P1xKey, Value
            case "P1Y":       EnvSet, P1yKey, Value
            case "P1Z":       EnvSet, P1zKey, Value
            
            case "P2Up":      EnvSet, P2upKey, Value
            case "P2Down":    EnvSet, P2downKey, Value
            case "P2Left":    EnvSet, P2leftKey, Value
            case "P2Right":   EnvSet, P2rightKey, Value
            case "P2A":       EnvSet, P2aKey, Value
            case "P2B":       EnvSet, P2bKey, Value
            case "P2X":       EnvSet, P2xKey, Value
            case "P2Y":       EnvSet, P2yKey, Value
            case "P2Z":       EnvSet, P2zKey, Value
            
            case "Enter":       EnvSet, enterKey, Value
            case "Escape":       EnvSet, escKey, Value
        }
    }
}

KillAllGames(titleDict) {
    ; Kill all games using dictionary
    for key, value in titleDict
    {
        if (WinExist(value)) {
            WinClose
        }
    }
    Restart_Launcher(titleDict)
}


; TODO: Start focus counter on startup. Automatically
!s::
counter.Start()
return

!e::
counter.Stop()
return

~Esc & ~Enter::
KillAllGames(counter.titleDict)
return

$Up::
    sendUp() {
        EnvGet, keyVar, P1upKey
        Send {%keyVar% down}
    }
$Up UP::
    releaseUp() {
        EnvGet, keyVar, P1upKey
        Send, {%keyVar% up}
    }

$Left::
    sendLeft() {
        EnvGet, keyVar, P1leftKey
        Send {%keyVar% down}
    }
$Left UP::
    releaseLeft() {
        EnvGet, keyVar, P1leftKey
        Send, {%keyVar% up}
    }

$Right::
    sendRight() {
        EnvGet, keyVar, P1rightKey
        Send, {%keyVar% down}
    }
$Right UP::
    releaseRight() {
        EnvGet, keyVar, P1rightKey
        Send, {%keyVar% up}
    }

$Down::
    sendDown() {
        EnvGet, keyVar, P1downKey
        Send, {%keyVar% down}
    }
$Down UP::
    releaseDown() {
        EnvGet, keyVar, P1downKey
        Send, {%keyVar% up}
    }

$1::
    sendA() {
        EnvGet, keyVar, P1aKey
        Send, {%keyVar% down}
    }
$1 UP::
    releaseA() {
        EnvGet, keyVar, P1aKey
        Send, {%keyVar% up}
    }

$2::
    sendB() {
        EnvGet, keyVar, P1bKey
        Send, {%keyVar% down}
    }
$2 UP::
    releaseB() {
        EnvGet, keyVar, P1bKey
        Send, {%keyVar% up}
    }

$3::
    sendX() {
        EnvGet, keyVar, P1xKey
        Send, {%keyVar% down}
    }
$3 UP::
    releaseX() {
        EnvGet, keyVar, P1bKey
        Send, {%keyVar% up}
    }

$4::
    sendY() {
        EnvGet, keyVar, P1yKey
        Send, {%keyVar% down}
    }
$4 UP::
    releaseY() {
        EnvGet, keyVar, P1yKey
        Send, {%keyVar% up}
    }

$5::
    sendZ() {
        EnvGet, keyVar, P1zKey
        Send, {%keyVar% down}
    }
$5 UP::
    releaseZ() {
        EnvGet, keyVar, P1zKey
        Send, {%keyVar% up}
    }


$w::
    P2sendUp() {
        EnvGet, keyVar, P2upKey
        Send, {%keyVar% down}
    }
$w UP::
    P2releaseUp() {
        EnvGet, keyVar, P2upKey
        Send, {%keyVar% up}
    }

$a::
    P2sendLeft() {
        EnvGet, keyVar, P2leftKey
        Send, {%keyVar% down}
    }
$a UP::
    P2releaseLeft() {
        EnvGet, keyVar, P2leftKey
        Send, {%keyVar% up}
    }

$d::
    P2sendRight() {
        EnvGet, keyVar, P2rightKey
        Send, {%keyVar% down}
    }
$d UP::
    P2releaseRight() {
        EnvGet, keyVar, P2rightKey
        Send, {%keyVar% up}
    }

$s::
    P2sendDown() {
        EnvGet, keyVar, P2downKey
        Send, {%keyVar% down}
    }
$s UP::
    P2releaseDown() {
        EnvGet, keyVar, P2downKey
        Send, {%keyVar% up}
    }

$f::
    P2sendA() {
        EnvGet, keyVar, P2aKey
        Send, {%keyVar% down}
    }
$f UP::
    P2releaseA() {
        EnvGet, keyVar, P2aKey
        Send, {%keyVar% up}
    }

$t::
    P2sendB() {
        EnvGet, keyVar, P2bKey
        Send, {%keyVar% down}
    }
$t UP::
    P2releaseB() {
        EnvGet, keyVar, P2bKey
        Send, {%keyVar% up}
    }

$g::
    P2sendX() {
        EnvGet, keyVar, P2xKey
        Send, {%keyVar% down}
    }
$g UP::
    P2releaseX() {
        EnvGet, keyVar, P2xKey
        Send, {%keyVar% up}
    }

$h::
    P2sendY() {
        EnvGet, keyVar, P2yKey
        Send, {%keyVar% down}
    }
$h UP::
    P2releaseY() {
        EnvGet, keyVar, P2yKey
        Send, {%keyVar% up}
    }

$y::
    P2sendZ() {
        EnvGet, keyVar, P2zKey
        Send, {%keyVar% down}
    }
$y UP::
    P2releaseZ() {
        EnvGet, keyVar, P2zKey
        Send, {%keyVar% up}
    }
    
$Enter::
    sendEnter() {
        EnvGet, keyVar, enterKey
        Send, {%keyVar% down}
    }
$Enter UP::
    releaseEnter() {
        EnvGet, keyVar, enterKey
        Send, {%keyVar% up}
    }
    
$Esc::
    sendEsc() {
        EnvGet, keyVar, escKey
        Send, {%keyVar% down}
    }
$Esc UP::
    releaseEsc() {
        EnvGet, keyVar, escKey
        Send, {%keyVar% up}
    }