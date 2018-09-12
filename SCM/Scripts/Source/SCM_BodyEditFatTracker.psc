ScriptName SCM_BodyEditFatTracker Extends ActiveMagicEffect

Actor MyActor
Int ActorData
Bool Gender ;False for male, True for female
SCM_BodyEditFat Property Fat Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
SCM_Library Property SCMLib Auto
SCM_Settings Property SCMSet Auto

String Property DebugName
  String Function Get()
    If MyActor
      Return "[SCM_FatTracker " + MyActor.GetLeveledActorBase().GetName() + "] "
    Else
      Return "[SCM_FatTracker] "
    EndIf
  EndFunction
EndProperty
Bool EnableDebugMessages = False
Bool RapidChange

String ShortModKey = "SCM_Fat"
String FullModKey = "Skyrim Character Morphs"

Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  ActorData = SCXLib.getTargetData(MyActor)
  Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
  ;Notice("Fat tracker starting! Starting method = " + Gender)
  If Gender
    ;GoToState("Female")
  Else
    GoToState("Male")
  EndIf
  RegisterForModEvent("SCM_BodyEditFatSpellUpdate", "OnEditUpdate")
  RegisterForSingleUpdate(0.1)
EndEvent

Event OnEditUpdate(Form akTarget, Bool abRapid)
  If akTarget == MyActor
    Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
    If Gender && GetState() != "Female"
      GoToState("Female")
    ElseIf GetState() != "Male"
      GoToState("Male")
    EndIf
    RegisterForSingleUpdate(0.1)
    If abRapid
      RapidChange = True
    EndIf
  EndIf
EndEvent

State Female
  Event OnBeginState()
    purgeMethods()
    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    Float TargetValue = JMap.getFlt(ActorData, "SCM_BodyEditFatTargetValue", 1)
    Int JM_Fat = JMap.getObj(ActorData, "SCM_MorphEffectFatRating")
    If !JValue.isExists(JM_Fat) || !JValue.isMap(JM_Fat)
      JM_Fat = Fat.JM_MorphEffectRating
    EndIf
    Float Inc = Fat.Increment
    If RapidChange
      Inc *= 10
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
    String i = JMap.nextKey(JM_Fat)
    While i
      NiOverride.SetBodyMorph(MyActor, i, ShortModKey, CurrentSize * (JMap.getFlt(JM_Fat, i) / 100))
      i = JMap.nextKey(JM_Fat, i)
    EndWhile
    NiOverride.UpdateModelWeight(MyActor)
    Float Rate = Fat.IncrementRate
    If RapidChange
      Rate *= 5
    EndIf
    RegisterForSingleUpdate(Inc/Rate)
  EndEvent
EndState

Float CurrentSize
Int iMode
Quest akQuest
State Male
  Event OnBeginState()
    purgeMethods()
    If SCX_Library.isModInstalled("RaceMenuPluginSAM.esp")
      iMode = 2
      akQuest = Game.GetFormFromFile(0x01000800, "RaceMenuPluginSAM.esp") as Quest
      ;Note("SAM Racemenu plugin found! iMode = 2")
    ElseIf SCX_Library.isModInstalled("SAM - Shape Atlas for Men.esp")
      akQuest = Game.GetFormFromFile(0x02000d62, "SAM - Shape Atlas for Men.esp") as Quest
      ;Note("SAM Found! iMode = 1")
      SavedSamson = SAM_Data.GetSamson(MyActor)
      SavedSamuel = SAM_Data.GetSamuel(MyActor)
      iMode = 1
    Else
      ;Note("No plugin found! iMode = 0")
      iMode = 0
    EndIf
    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    Float TargetValue = JMap.getFlt(ActorData, "SCM_BodyEditFatTargetValue", 1)
    Int JM_Muscle = JMap.getInt(ActorData, "SCM_MorphEffectRating")
    If !JValue.isExists(JM_Muscle) || !JValue.isMap(JM_Muscle)
      JM_Muscle = Fat.JM_MorphEffectRating
    EndIf
    Float Samson = JMap.getFlt(JM_Muscle, "Samson")
    Float Samuel = JMap.getFlt(JM_Muscle, "Samuel")
    Float Inc = Fat.Increment
    If RapidChange
      Inc *= 10
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
    Float FinalSamson = CurrentSize * (Samson)
    Float FinalSamuel = CurrentSize * (Samuel)
    If iMode == 1
      SAM_Data.setSamson(MyActor, FinalSamson)
      SAM_Data.setSamson(MyActor, FinalSamuel)
      (akQuest as SAM_QuestScript).UpdateActor(MyActor, False, True, False, True, False, False)
    ElseIf iMode == 2
      NiOverride.SetBodyMorph(MyActor, "Samson", ShortModKey, FinalSamson / 100)
      NiOverride.SetBodyMorph(MyActor, "Samuel", ShortModKey, FinalSamuel / 100)
      (akQuest as RaceMenuPluginSAM).setSAMBodyScale(MyActor)
    EndIf
    NiOverride.UpdateModelWeight(MyActor)
    Float Rate = Fat.IncrementRate
    If RapidChange
      Rate *= 5
    EndIf
    RegisterForSingleUpdate(Inc/Rate)
  EndEvent
EndState

Float SavedSamuel
Float SavedSamson
Function purgeMethods()
  If iMode == 1
    SAM_Data.setSamson(MyActor, SavedSamson)
    SAM_Data.setSamson(MyActor, SavedSamuel)
    (akQuest as SAM_QuestScript).UpdateActor(MyActor, False, True, False, True, False, False)
  ElseIf iMode == 2
    NiOverride.ClearBodyMorph(MyActor, "Samson", ShortModKey)
    NiOverride.ClearBodyMorph(MyActor, "Samuel", ShortModKey)
    (akQuest as RaceMenuPluginSAM).setSAMBodyScale(MyActor)
    NiOverride.UpdateModelWeight(MyActor)
  EndIf
EndFunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  purgeMethods()
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
