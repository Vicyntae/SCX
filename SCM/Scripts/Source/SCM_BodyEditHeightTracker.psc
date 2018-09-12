ScriptName SCM_BodyEditHeightTracker Extends ActiveMagicEffect

Actor MyActor
Int ActorData
Bool Gender ;False for male, True for female
SCM_BodyEditHeight Property Height Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
SCM_Library Property SCMLib Auto
SCM_Settings Property SCMSet Auto

String Property DebugName
  String Function Get()
    If MyActor
      Return "[SCM_HeightTracker " + MyActor.GetLeveledActorBase().GetName() + "] "
    Else
      Return "[SCM_HeightTracker] "
    EndIf
  EndFunction
EndProperty
Bool EnableDebugMessages = True
Bool RapidChange

String ShortModKey = "SCM_Height"
String FullModKey = "Skyrim Character Morphs"

Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  ActorData = SCXLib.getTargetData(MyActor)
  Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
  ;Notice("Height tracker starting! Starting method = " + Gender)
  RegisterForModEvent("SCM_BodyEditHeightSpellUpdate", "OnEditUpdate")
  RegisterForSingleUpdate(0.1)
EndEvent

Event OnEditUpdate(Form akTarget, Bool abRapid)
  If akTarget == MyActor
    Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
    RegisterForSingleUpdate(0.1)
    If abRapid
      RapidChange = True
    EndIf
  EndIf
EndEvent

Float CurrentSize = -1.0
Event OnUpdate()
  Float TargetValue = JMap.getFlt(ActorData, "SCM_BodyEditHeightTargetValue", 1)
  Float Inc = Height.Increment
  If RapidChange
    Inc *= 5
  EndIf
  If CurrentSize == -1
    CurrentSize = NetImmerse.GetNodeScale(MyActor, "NPC Root [Root]", False)
  EndIf
  If TargetValue == CurrentSize
    RapidChange = False
    Return
  ElseIf Math.abs(TargetValue - CurrentSize) < Inc
    CurrentSize == TargetValue
  ElseIf TargetValue > CurrentSize
    CurrentSize += Inc
  ElseIf TargetValue < CurrentSize
    CurrentSize -= Inc
  EndIf
  Float FinalSize = (CurrentSize * (Height.HeightWeighting)) + 1
  NiOverride.AddNodeTransformScale(MyActor, False, Gender, "NPC Root [Root]", ShortModKey, FinalSize)
  If MyActor == Game.GetPlayer()
    ;Taken from Macromancy 4 Reborn: https://www.nexusmods.com/skyrimspecialedition/mods/15081
    NiOverride.AddNodeTransformScale(MyActor, True, Gender, "NPC Root [Root]", ShortModKey, FinalSize)
    If FinalSize < 1
      Utility.SetINIFloat("fDefaultWorldFOV?isplay", FinalSize * -50 + 120 )
    Else
      Utility.SetINIFloat("fDefaultWorldFOV?isplay", 70 )
    EndIf
    Utility.SetINIFloat("fOverShoulderPosZ:Camera", FinalSize * 126 - 122 )
    Utility.SetINIFloat("fOverShoulderCombatPosZ:Camera", FinalSize * 136 - 122)

    Game.SetGameSettingFloat("fJumpHeightMin", FinalSize * 76 )
    Game.SetGameSettingFloat("fJumpFallHeightMin", FinalSize * 600 )
    Game.SetGameSettingFloat("fJumpFallHeightExponent", 1.45 / FinalSize )
    Game.UpdateThirdPerson()
    NiOverride.UpdateNodeTransform(MyActor, True, Gender, "NPC Root [Root]")
  EndIf
  NiOverride.UpdateNodeTransform(MyActor, False, Gender, "NPC Root [Root]")
  Float Rate = Height.IncrementRate
  If RapidChange
    Rate *= 5
  EndIf
  RegisterForSingleUpdate(Inc/Rate)
EndEvent

Function purgeMethods()
  NiOverride.RemoveNodeTransformScale(MyActor, False, Gender, "NPC Root [Root]", ShortModKey)
  NiOverride.RemoveNodeTransformScale(MyActor, True, Gender, "NPC Root [Root]", ShortModKey)
EndFunction

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
