
counter := new FocusTimer
launcherName := "MOCSARCADE"
; gameIdentifier := "MocsArcade_.+"
gameIdentifier := "Cubix"

EnvSet, upKey, {Up}
EnvSet, leftKey, {Left}
EnvSet, rightKey, {Right}
EnvSet, downKey, {Down}
EnvSet, aKey, {j}
EnvSet, bKey, {i}

; An example class for counting the seconds...
class FocusTimer {
    __New() {
        this.interval := 1500
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
        this.currentlyOpenGame := ""
    }
    Start() {
        ; Known limitation: SetTimer requires a plain variable reference.
        timer := this.timer
        SetTimer % timer, % this.interval
        OutputDebug, % "Counter started"
    }
    Stop() {
        ; To turn off the timer, we must pass the same object as before:
        timer := this.timer
        SetTimer % timer, Off
        OutputDebug, % "Counter stopped"
    }
    ; Every time interval, focus on the main game
    Tick() {
	    global gameIdentifier
	    global launcherName
        
        SetTitleMatchMode RegEx
        ; TODO: Use a game list rather than a prefix identifier
        if (WinExist(gameIdentifier)) {
            WinActivate
            WinGet, numGames, Count, % gameIdentifier
            ; Test for more than one currently open game
            ;if (numGames > 1) {
                ; TODO: Search again excluding currently open game (by ID) and close all others
                ; WinClose
            ;} else {
                ; Test for if the current window is a new window
                WinGetTitle, selectedGameName
                if (selectedGameName != this.currentlyOpenGame) {
                    this.currentlyOpenGame := selectedGameName
                    ; Open config and set keybinds
                    ; TODO: Open config.txt from game folder
                    OutputDebug, % "config.txt"
                    Loop, Read, config.txt
                    {
                        OutputDebug, % A_LoopReadLine
                        Keybind := StrSplit(A_LoopReadLine, "->", " `t")
                        mapKey := Keybind[2]
                        switch Keybind[1]
                        {
                            case "Up":      EnvSet, upKey, %mapKey%
                            case "Down":    EnvSet, downKey, %mapKey%
                            case "Left":    EnvSet, leftKey, %mapKey%
                            case "Right":   EnvSet, rightKey, %mapKey%
                            case "A":       EnvSet, aKey, %mapKey%
                            case "B":       EnvSet, bKey, %mapKey%
                        }
                    }
                }
            ;}
        }
        else if (WinExist(launcherName))
            WinActivate
        else
            Restart_Launcher()
    }
}

Restart_Launcher() {
    OutputDebug, % "Run the launcher" ; TODO: Open launcher
}

KillAllGames() {
    global gameIdentifier
    global launcherName
    
    SetTitleMatchMode RegEx
	While, WinExist(gameIdentifier)
	{
        WinClose
	}
    if WinExist(launcherName)
        WinActivate
	
	;restart the launcher
	If !WinExist(launcherName)
		Restart_Launcher()
}


; TODO: Start focus counter on startup. Automatically
!s::
counter.Start()
return

!e::
counter.Stop()
return

Esc & Enter::
KillAllGames()
return

Up::
    sendUp() {
        EnvGet, upVar, upKey
        Send %upVar%
    }

Left::
    sendLeft() {
        EnvGet, leftVar, leftKey
        Send %leftVar%
    }

Right::
    sendRight() {
        EnvGet, rightVar, rightKey
        Send %rightVar%
    }

Down::
    sendDown() {
        EnvGet, downVar, downKey
        Send %downVar%
    }

1::
    sendA() {
        EnvGet, aVar, aKey
        Send %aVar%
    }

2::
    sendB() {
        EnvGet, bVar, bKey
        Send %bVar%
    }