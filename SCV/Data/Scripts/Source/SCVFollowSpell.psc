ScriptName SCVFollowSpell Extends ActiveMagicEffect

Actor Prey
Actor Pred
Actor Property PlayerRef Auto
SCX_Library Property SCXLib Auto
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCX_Settings Property SCXSet Auto
Package Property SCX_ActorHoldPackage Auto
String Property DebugName
  String Function Get()
    If Prey
      Return "[SCVFollow " + Prey.GetLeveledActorBase().GetName() + "] "
    Else
      Return "[SCVFollow] "
    EndIf
  EndFunction
EndProperty
Bool EnableDebugMessages = True
Event OnEffectStart(Actor akTarget, Actor akCaster)
  Prey = akTarget
  Note("Follow spell started!")
  akTarget.SetAlpha(0, False)
  akTarget.SetGhost(True)
  Pred = SCVlib.findHighestPred(akTarget)
  ;game.DisablePlayerControls(true, true, true, false, true, true, true, false, 0)
  If akTarget == PlayerRef
    Game.DisablePlayerControls(False, False, False, False, False, True, True, False, 0)
    Game.ForceThirdPerson()
    Game.SetCameraTarget(Pred)
    If Pred.IsInFaction(SCXSet.CurrentFollowerFaction)
      Game.EnablePlayerControls()
      Pred.SetPlayerControls(True)
      Pred.EnableAI(True)
    EndIf
    PlayerRef.SetPlayerControls(False)
  EndIf
  akTarget.EnableAI(False)
  akTarget.ClearExtraArrows()
  akTarget.StopCombatAlarm()
  akTarget.StopCombat()
  ActorUtil.AddPackageOverride(akTarget, SCXSet.SCX_ActorHoldPackage)
  Pred.SetAlert(False)
  Pred.EvaluatePackage()
  SCVLib.checkPredSpells(akTarget)
  RegisterForSingleUpdate(1)
EndEvent

Event OnUpdate()
  Actor NewPred = SCVLib.findHighestPred(Prey)
  If NewPred != Pred
    If Prey == PlayerRef
      If Pred.IsInFaction(SCXSet.CurrentFollowerFaction)
        Game.DisablePlayerControls(False, False, False, False, False, True, True, False, 0)
        Pred.SetPlayerControls(False)
        Pred.EnableAI(True)
      EndIf
      If NewPred.IsInFaction(SCXSet.CurrentFollowerFaction)
        Game.EnablePlayerControls()
        NewPred.SetPlayerControls(True)
        NewPred.EnableAI(True)
      EndIf
      Game.SetCameraTarget(NewPred)
    EndIf
    Pred = NewPred
  EndIf
  Prey.SetPosition(Pred.GetPositionX() + 500, Pred.GetPositionY()+ 500, Pred.GetPositionZ())
  RegisterForSingleUpdate(1)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Note("Effect stopped!")
  If akTarget == PlayerRef
    Game.SetCameraTarget(akTarget)
    Game.EnablePlayerControls()
    If Pred.IsPlayerTeammate()
      Pred.SetPlayerControls(False)
      Pred.EnableAI(True)
    EndIf
  EndIf
  ActorUtil.RemovePackageOverride(akTarget, SCX_ActorHoldPackage)
  akTarget.SetGhost(False)
  akTarget.EnableAI(True)
  akTarget.EvaluatePackage()
  akTarget.SetAlpha(1, False)
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
