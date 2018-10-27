ScriptName SCX_MonitorCycler Extends Quest

Quest Property SCX_MonitorFinderQuest Auto

Event OnInit()
  ;Debug.Notification("Initializing monitor cycler.")
  RegisterForMenu("Sleep/Wait Menu")
  RegisterForSingleUpdate(1)
EndEvent

Bool Function Start()
  ;Debug.Notification("Starting monitor cycle...")
  Bool bReturn = Parent.Start()
  RegisterForMenu("Sleep/Wait Menu")
  RegisterForSingleUpdate(1)
  Return bReturn
EndFunction

;/Event OnMenuOpen(String menuName)
  UnregisterForUpdate()
EndEvent

Event OnMenuClose(string menuName)
  RegisterForSingleUpdate(1)
EndEvent/;;

Event OnUpdate()
  If !Utility.IsInMenuMode()
    ;Debug.Notification("Stopping monitor finder...")
    SCX_MonitorFinderQuest.Stop()

    Int i = 0
    While !SCX_MonitorFinderQuest.IsStopped() && i < 50
      Utility.Wait(0.1)
      i += 1
    EndWhile
    ;Debug.Notification("Monitor finder stopped? i = " + i + ". Starting Quest again.")
    SCX_MonitorFinderQuest.Start()
    ;Debug.Notification("Is Monitor Finder running? " + SCX_MonitorFinderQuest.IsRunning())
  EndIf
  RegisterForSingleUpdate(10)
EndEvent

Function Stop()
  ;Debug.Notification("Stopping Monitor Cycle...")
  UnregisterForUpdate()
  Parent.Stop()
EndFunction
