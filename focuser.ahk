
counter := new FocusTimer

; TODO:
; reading config of other files
; reseting keybinds on close
; reading filetitles from config
; starting by default

; -----------------
; P1
; ---------------------------
EnvSet, P1upKey, {Up}
EnvSet, P1leftKey, {Left}
EnvSet, P1rightKey, {Right}
EnvSet, P1downKey, {Down}
EnvSet, P1aKey, {j}
EnvSet, P1bKey, {i}
EnvSet, P1xKey, {k}
EnvSet, P1yKey, {l}
EnvSet, P1zKey, {o}

; -----------------
; P2
; ---------------------------
EnvSet, P2upKey, {w}
EnvSet, P2leftKey, {a}
EnvSet, P2rightKey, {d}
EnvSet, P2downKey, {s}
EnvSet, P2aKey, {f}
EnvSet, P2bKey, {t}
EnvSet, P2xKey, {t}
EnvSet, P2yKey, {h}
EnvSet, P2zKey, {y}

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
        Loop, Files, %A_ScriptDir%\MOCSArcadeGames\*, D
        {
            Loop, Read, MOCSArcadeGames/%A_LoopFileName%/config.txt
             {
                configLine := StrSplit(A_LoopReadLine, "->", " `t")
                switch configLine[1]
                {
                    case "title":
                        this.titleDict[A_LoopFileName] := configLine[2]
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
        if (WinExist(gameTitle)) {
            WinActivate
            ; Starting new game
            if (gameTitle != this.currentlyOpenGame) {
                this.currentlyOpenGame := gameTitle
                ; Open config and set keybinds
                ConfigNewGame(gameTitle)
            }
        }
        else if (gameTitle != "") ; If the game title returned doesn't exist, clean restart
            KillAllGames(this.titleDict)
        else
            Restart_Launcher(titleDict) ; If the return is an empty string, open launcher
    }
}

; Goes through titleDict and checks if any games with those titles are open
FindOpenGameTitle(titleDict, currentlyOpenGame) {
    
    SetTitleMatchMode RegEx
    ; TODO: return open game based on titleDict

    ; TODO: Test for more than one currently open game
    ;if (numGames > 1) {
        ; TODO: Search again excluding currently open game and close all others
        ; WinClose
    ;} else {
}

Restart_Launcher(titleDict) {
    OutputDebug, % "Run the launcher"
    ; TODO: Open launcher

    ConfigNewGame("Launcher")
}

ConfigNewGame(gameTitle) {
    ; TODO: Get game NAME (of folder) from dictionary
    local gameName := "Cubix"

    OutputDebug, % MOCSArcadeGames/%gameName%/config.txt
    Loop, Read, MOCSArcadeGames/%gameName%/config.txt
    {
        OutputDebug, % A_LoopReadLine
        Keybind := StrSplit(A_LoopReadLine, "->", " `t")
        mapKey := Keybind[2]
        switch Keybind[1]
        {
            case "Up":      EnvSet, P1upKey, %mapKey%
            case "Down":    EnvSet, P1downKey, %mapKey%
            case "Left":    EnvSet, P1leftKey, %mapKey%
            case "Right":   EnvSet, P1rightKey, %mapKey%
            case "A":       EnvSet, P1aKey, %mapKey%
            case "B":       EnvSet, P1bKey, %mapKey%
            case "X":       EnvSet, P1xKey, %mapKey%
            case "Y":       EnvSet, P1yKey, %mapKey%
            case "Z":       EnvSet, P1zKey, %mapKey%
            
            case "P2Up":      EnvSet, P2upKey, %mapKey%
            case "P2Down":    EnvSet, P2downKey, %mapKey%
            case "P2Left":    EnvSet, P2leftKey, %mapKey%
            case "P2Right":   EnvSet, P2rightKey, %mapKey%
            case "P2A":       EnvSet, P2aKey, %mapKey%
            case "P2B":       EnvSet, P2bKey, %mapKey%
            case "P2X":       EnvSet, P2xKey, %mapKey%
            case "P2Y":       EnvSet, P2yKey, %mapKey%
            case "P2Z":       EnvSet, P2zKey, %mapKey%
        }
    }
}

KillAllGames(titleDict) {
    ; TODO: Kill all games using dictionary
    SetTitleMatchMode RegEx
	While, WinExist(gameIdentifier)
	{
        WinClose
	}
    if WinExist(launcherName)
        WinActivate
	
    Restart_Launcher(titleDict)
}


; TODO: Start focus counter on startup. Automatically
!s::
counter.Start()
return

!e::
counter.Stop()
return

Esc & Enter::
KillAllGames(titleDict)
return

Up::
    sendUp() {
        EnvGet, upVar, upKey
        Send %P1upVar%
    }

Left::
    sendLeft() {
        EnvGet, leftVar, leftKey
        Send %P1leftVar%
    }

Right::
    sendRight() {
        EnvGet, rightVar, rightKey
        Send %P1rightVar%
    }

Down::
    sendDown() {
        EnvGet, downVar, downKey
        Send %P1downVar%
    }

1::
    sendA() {
        EnvGet, aVar, aKey
        Send %P1aVar%
    }

2::
    sendB() {
        EnvGet, bVar, bKey
        Send %P1bVar%
    }

3::
    sendX() {
        EnvGet, bVar, bKey
        Send %P1xVar%
    }

4::
    sendY() {
        EnvGet, bVar, bKey
        Send %P1yVar%
    }

5::
    sendZ() {
        EnvGet, bVar, bKey
        Send %P1zVar%
    }


w::
    P2sendUp() {
        EnvGet, upVar, upKey
        Send %P2upVar%
    }

a::
    P2sendLeft() {
        EnvGet, leftVar, leftKey
        Send %P2leftVar%
    }

d::
    P2sendRight() {
        EnvGet, rightVar, rightKey
        Send %P2rightVar%
    }

s::
    P2sendDown() {
        EnvGet, downVar, downKey
        Send %P2downVar%
    }

f::
    P2sendA() {
        EnvGet, aVar, aKey
        Send %P2aVar%
    }

t::
    P2sendB() {
        EnvGet, bVar, bKey
        Send %P2bVar%
    }

g::
    P2sendX() {
        EnvGet, bVar, bKey
        Send %P2xVar%
    }

h::
    P2sendY() {
        EnvGet, bVar, bKey
        Send %P2yVar%
    }

y::
    P2sendZ() {
        EnvGet, bVar, bKey
        Send %P2zVar%
    }