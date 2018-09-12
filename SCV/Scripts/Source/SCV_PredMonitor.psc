ScriptName SCV_PredMonitor Extends ActiveMagicEffect

SCX_Library Property SCXLib Auto
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCX_Settings Property SCXSet Auto

Spell Property OVLethal Auto
Spell Property OVNonLethal Auto

Spell Property AVLethal Auto
Spell Property AVNonLethal Auto

Spell Property UVLethal Auto
Spell Property UVNonLethal Auto

Spell Property CVLethal Auto
Spell Property CVNonLethal Auto

String[] PredTypes
Bool EnableDebugMessages
Actor MyActor

String Property DebugName
  String Function Get()
    If MyActor
      Return "[SCVPredAI " + MyActor.GetLeveledActorBase().GetName() + "] "
    Else
      Return "[SCVPredAI] "
    EndIf
  EndFunction
EndProperty

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Notice("Combat AI Started!")
  MyActor = akTarget
  ;JA_PredTypes = JValue.retain(JArray.object())
  Int ArraySize

  Bool OV_Pred
  If SCVLib.isOVPred(akTarget)
    OV_Pred = True
    ArraySize += 1
  EndIf

  Bool AV_Pred
  If SCVLib.isAVPred(akTarget)
    AV_Pred = True
    ArraySize += 1
  EndIf

  Bool UV_Pred
  If SCVLib.isUVPred(akTarget)
    UV_Pred = True
    ArraySize += 1
  EndIf

  Bool CV_Pred
  If SCVLib.isCVPred(akTarget)
    CV_Pred = True
    ArraySize += 1
  EndIf

  PredTypes = Utility.CreateStringArray(ArraySize, "")
  Int i
  If OV_Pred
    PredTypes[i] = "OV"
    i += 1
  EndIf
  If AV_Pred
    PredTypes[i] = "AV"
    i += 1
  EndIf
  If UV_Pred
    PredTypes[i] = "UV"
    i += 1
  EndIf
  If CV_Pred
    PredTypes[i] = "CV"
    i += 1
  EndIf

  RegisterForSingleUpdate(5)
EndEvent

Event OnUpdate()
  Float CastChance = Utility.RandomFloat()
  If CastChance < 0.2
    Actor Prey = MyActor.GetCombatTarget()
    Int NumPredTypes = PredTypes.length
    Int Chance
    If NumPredTypes == 1
      Chance = 0
    Else
      Chance = Utility.RandomInt(0, NumPredTypes - 1)
    EndIf
    Bool Lethal
    If MyActor.IsGuard()
      ;Note("Pred is a guard! Casting nonlethal spell.")
      Lethal = False
    Else
      ;Note("Casting lethal spell.")
      Lethal = True
    EndIf
    Spell VoreSpell = getVoreSpell(Chance, Lethal)
    VoreSpell.Cast(MyActor, Prey)
  EndIf
  RegisterForSingleUpdate(5)
EndEvent

Spell Function getVoreSpell(Int aiIndex, Bool abLethal)
  String Type = PredTypes[aiIndex]
  If Type == "OV"
    If abLethal
      Return OVLethal
    Else
      Return OVNonLethal
    EndIf
  ElseIf Type == "AV"
    If abLethal
      Return AVLethal
    Else
      Return AVNonLethal
    EndIf
  ElseIf Type == "UV"
    If abLethal
      Return UVLethal
    Else
      Return UVNonLethal
    EndIf
  ElseIf Type == "CV"
    If abLethal
      Return CVLethal
    Else
      Return CVNonLethal
    EndIf
  EndIf
EndFunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Notice("Combat AI Finished!")
  UnregisterForUpdate()
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
