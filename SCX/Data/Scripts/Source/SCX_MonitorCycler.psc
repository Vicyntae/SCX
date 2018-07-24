ScriptName SCX_MonitorCycler Extends Quest

Quest Property SCX_MonitorFinderQuest Auto

Event OnInit()
  Debug.Notification("Starting up monitor cycle")
  RegisterForMenu("Sleep/Wait Menu")
  RegisterForSingleUpdate(1)
EndEvent

Bool Function Start()
  Bool bReturn = Parent.Start()
  Debug.Notification("Starting up monitor cycle")
  RegisterForMenu("Sleep/Wait Menu")
  RegisterForSingleUpdate(1)
  Return bReturn
EndFunction

Event OnMenuOpen(String menuName)
  UnregisterForUpdate()
EndEvent

Event OnMenuClose(string menuName)
  RegisterForSingleUpdate(10)
EndEvent

Event OnUpdate()
  SCX_MonitorFinderQuest.Stop()

  Int i = 0
  While !SCX_MonitorFinderQuest.IsStopped() && i < 50
    Utility.Wait(0.1)
    i += 1
  EndWhile
  SCX_MonitorFinderQuest.Start()
  RegisterForSingleUpdate(10)
EndEvent

Function Stop()
  UnregisterForUpdate()
  Parent.Stop()
EndFunction
