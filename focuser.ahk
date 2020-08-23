
counter := new FocusTimer
launcherName := "MOCSARCADE"
; gameIdentifier := "MocsArcade_.+"
gameIdentifier := "Cubix"

!s::
counter.Start()
return

!e::
counter.Stop()
return

Esc & Enter::
KillAllGames()
return

; An example class for counting the seconds...
class FocusTimer {
    __New() {
        this.interval := 1500
        this.count := 0
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
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
        OutputDebug, % "Counter stopped at " this.count
    }
    ; Every time interval, focus on the main game
    Tick() {
	    global gameIdentifier
	    global launcherName
        
        SetTitleMatchMode RegEx
        if (WinExist(gameIdentifier)) {
            WinActivate
            WinGet, numGames, Count, % gameIdentifier
            OutputDebug, % numGames
            if (numGames > 1) {
                WinClose
            }
        }
        else if (WinExist(launcherName))
            WinActivate
        else
            Restart_Launcher()
    }
}

Restart_Launcher(){
    OutputDebug, % "Run the launcher" ; TODO: Open launcher
}

KillAllGames(){

    global gameIdentifier
    global launcherName
    
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