ScriptName SCX_MonitorPlayer Extends SCX_Monitor

Function Setup()
  Parent.Setup()
  RegisterForModEvent("SCXMenuKeyChange", "OnActionKeyChange")
  RegisterForKey(SCXSet.MenuKey)
  RegisterForKey(SCXSet.StatusKey)
  UnregisterForMenu("Console")
  RegisterForMenu("Console")
EndFunction

Function reloadMaintenence()
  Parent.reloadMaintenence()
  RegisterForModEvent("SCXMenuKeyChange", "OnActionKeyChange")
  UnregisterForMenu("Console")
  RegisterForMenu("Console")
EndFunction

Event OnActionKeyChange()
  Notice("Action key changed")
  UnregisterForAllKeys()
  RegisterForKey(SCXSet.MenuKey)
  RegisterForKey(SCXSet.StatusKey)
EndEvent

Event OnMenuOpen(string menuName)
  If menuName == "Console"
    RegisterForKey(28)
    RegisterForKey(156)
  EndIf
EndEvent

Event OnMenuClose(string menuName)
  If menuName == "Console"
    UnregisterForKey(28)
    UnregisterForKey(156)
  EndIf
EndEvent


Event OnKeyUp(int keyCode, float holdTime)
  If keyCode == SCXSet.StatusKey
    If Utility.IsInMenuMode()
      Return
    EndIf
    Actor CurrentRef = Game.GetCurrentCrosshairRef() as Actor
    If !CurrentRef
      CurrentRef = PlayerRef
    EndIf
    If holdTime < 0.5
      SCXLib.showQuickActorStatus(CurrentRef)
    Else
      SCXLib.showFullActorStatus(CurrentRef)
    EndIf
  EndIf
EndEvent

Event OnKeyDown(int keyCode)
  If keyCode == SCXSet.MenuKey
    If Utility.IsInMenuMode()
      Return
    EndIf
    Notice("Action Key Pressed")
    ObjectReference CurrentRef = Game.GetCurrentCrosshairRef()
    If !LockEX()
      Return
    EndIf
    If !CurrentRef
      If SCXSet.UIExtensionsInstalled
        Notice("Sending menu open event for " + nameGet(MyActor))
        SCXLib.showActorMainMenu(MyActor)
      Else
        SCXLib.showTransferMenu(MyActor)
      EndIf
    ElseIf CurrentRef as Actor
      If SCXSet.UIExtensionsInstalled
        Notice("Sending menu open event for " + nameGet(CurrentRef))
        SCXLib.showActorMainMenu(CurrentRef as Actor)
      Else
        SCXLib.showTransferMenu(MyActor)
      EndIf
    EndIf
    UnlockEX()
  ElseIf keyCode == 28 || keyCode == 156
    ;Console Interface ---------------------------------------------------------
    ;Taken from post by milzschnitte
    ;https://www.loverslab.com/topic/58600-skyrim-custom-console-commands-using-papyrus/
    Int cmdCount = UI.GetInt("Console", "_global.Console.ConsoleInstance.Commands.length")
    If cmdCount > 0
      cmdCount -= 1
      String cmdLine = UI.GetString("Console","_global.Console.ConsoleInstance.Commands."+cmdCount)
      If cmdLine != ""
        ObjectReference akTarget = Game.GetCurrentConsoleRef()
        If akTarget == None
          akTarget = PlayerRef
        EndIf
        String[] cmd = StringUtil.Split(cmdLine, " ")
        SCXLib.processConsoleInput(akTarget, cmd)
      EndIf
    EndIf
  EndIf
EndEvent
