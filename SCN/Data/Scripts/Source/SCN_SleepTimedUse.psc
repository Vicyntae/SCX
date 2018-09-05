ScriptName SCN_SleepTimedUse Extends ActiveMagicEffect

SCX_Library Property SCXLib Auto
SCNLibrary Property SCNLib Auto
SCNSettings Property SCNSet Auto
SCX_Settings Property SCXSet Auto

Actor MyActor
String Property DebugName
  String Function Get()
    If MyActor
      Return "[SCNSleepUse " + MyActor.GetLeveledActorBase().GetName() + "] "
    Else
      Return "[SCNSleepUse] "
    EndIf
  EndFunction
EndProperty
Bool EnableDebugMessages

Float StartTime
Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  StartTime = Utility.GetCurrentGameTime()
  Note("Starting Sleep. Start Time = " + StartTime)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Float EndTime = Utility.GetCurrentGameTime()
  Float TimePassed = ((EndTime - StartTime)*24) ;In hours

  Note("End Time = " + EndTime + ", Time Slept: " + TimePassed)
  Int TargetData = SCNLib.getTargetData(akTarget)
  JMap.setFlt(TargetData, "SCNTimeSlept", JMap.getFlt(TargetData, "SCNTimeSlept") + TimePassed)
EndEvent

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Debug Functions
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Popup(String sMessage)
  {Shows MessageBox, then waits for menu to be closed before continuing}
  Debug.MessageBox(DebugName + sMessage)
  Halt()
EndFunction

Function Halt()
  {Wait for menu to be closed before continuing}
  While Utility.IsInMenuMode()
    Utility.Wait(0.5)
  EndWhile
EndFunction

Function Note(String sMessage)
  Debug.Notification(DebugName + sMessage)
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Notice(String sMessage)
  {Displays message in notifications and logs if globals are active}
  If EnableDebugMessages
    Debug.Notification(DebugName + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Issue(String sMessage, Int iSeverity = 0, Bool bOverride = False)
  {Displays a serious message in notifications and logs if globals are active
  Use bOverride to ignore globals}
  If bOverride || EnableDebugMessages
    String Level
    If iSeverity == 0
      Level = "Info"
    ElseIf iSeverity == 1
      Level = "Warning"
    ElseIf iSeverity == 2
      Level = "Error"
    EndIf
    Debug.Notification(DebugName + Level + " " + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage, iSeverity)
EndFunction
