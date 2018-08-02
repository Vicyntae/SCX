ScriptName SCX_BodyEditBellyTracker Extends ActiveMagicEffect

Actor MyActor
Int ActorData
Bool Gender ;False for male, True for female
SCX_BodyEditBelly Property Belly Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
String Property DebugName
  String Function Get()
    Return "[SCX_BellyTracker " + MyActor.GetLeveledActorBase().GetName() + "] "
  EndFunction
EndProperty
Bool EnableDebugMessages = False

String ShortModKey = "SCX.esp"
String FullModKey = "Skyrim Character Extended"

Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  ActorData = SCXLib.getTargetData(MyActor)
  Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
  String Method = JMap.getStr(ActorData, Belly.MethodKey, Belly.CurrentMethod)
  Notice("Belly tracker starting! Starting method = " + Method)
  GoToState(Method)
  RegisterForModEvent("SCX_BodyEditBellySpellMethodUpdate", "OnMethodUpdate")
EndEvent

Event OnMethodUpdate()
  Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
  String Method = JMap.getStr(ActorData, Belly.MethodKey, Belly.CurrentMethod)
  If Method != GetState()
    GoToState(Method)
  EndIf
  RegisterForSingleUpdate(0.1)
EndEvent

State Disabled
  ;Remove all scaling methods
  Event OnBeginState()
    Notice("Starting Disabled State")
    purgeMethods()
  EndEvent
EndState

State NiOverride
  Event OnBeginState()
    Notice("Starting NiOverride State")
    purgeMethods()
    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    CurrentSize = NiOverride.GetNodeTransformScale(MyActor, False, Gender, "NPC Belly", ShortModKey)
    Float TargetValue = JMap.getFlt(ActorData, "SCX_BodyEditBellyTargetValue", 1)
    Float Inc = Belly.Increment
    If TargetValue == CurrentSize
      Return
    ElseIf Math.abs(TargetValue - CurrentSize) < Inc
      CurrentSize == TargetValue
    ElseIf TargetValue > CurrentSize
      CurrentSize += Inc
    ElseIf TargetValue < CurrentSize
      CurrentSize -= Inc
    EndIf
    NiOverride.AddNodeTransformScale(MyActor, False, Gender, "NPC Belly", ShortModKey, CurrentSize)
    NiOverride.UpdateNodeTransform(MyActor, False, Gender, "NPC Belly")
    RegisterForSingleUpdate(Inc/Belly.IncrementRate)
  EndEvent
EndState

State SLIF
  Event OnBeginState()
    Notice("Starting SILF State")
    purgeMethods()
    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    If SCXSet.SLIF_Installed
      Float TargetValue = JMap.getFlt(ActorData, "SCX_BodyEditBellyTargetValue")
      String sKey = SLIF_Main.ConvertToKey("NPC Belly")
      SLIF_Main.inflate(MyActor, FullModKey, sKey, TargetValue, oldModName = ShortModKey)
    EndIf
    RegisterForSingleUpdate(5)
  EndEvent
EndState

Float UpperThreshold
Float LowerThreshold
Armor[] CurrentEquip
Float CurrentSize
Int CurrentSet
String CurrentBodyMorph
Int CurrentTier
State Equipment
  Event OnBeginState()
    Notice("Starting Equipment State")
    purgeMethods()
    If CurrentEquip.length != 3
      CurrentEquip = New Armor[3]
    EndIf
    CurrentSet = JMap.getInt(ActorData, Belly.EquipmentSetKey)
    Float TargetValue = JMap.getFlt(ActorData, "SCX_BodyEditBellyTargetValue")
    ;Get current armor level and jump to it
    Int Tier = Belly.findEquipTier(CurrentSet, TargetValue)
    CurrentTier = Tier
    Armor NewArmor = Belly.getEquipment(CurrentSet, Tier)
    If NewArmor
      If !MyActor.IsEquipped(NewArmor)
        MyActor.AddItem(NewArmor, 1, True)
        MyActor.EquipItem(NewArmor, True)
      EndIf
      CurrentEquip[1] = NewArmor
      CurrentEquip[0] = Belly.getEquipment(CurrentSet, Tier - 1)
      CurrentEquip[2] = Belly.getEquipment(CurrentSet, Tier + 1)
    EndIf

    If CurrentEquip[2] as SCX_BaseEquipment
      UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
    Else
      UpperThreshold = -1
    EndIf
    If CurrentEquip[0] as SCX_BaseEquipment
      LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
    Else
      LowerThreshold = -1
    EndIf

    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    Int NewSet = JMap.getInt(ActorData, Belly.EquipmentSetKey)
    If NewSet && NewSet != CurrentSet
      Notice("New set has been activated!")
      If MyActor.IsEquipped(CurrentEquip)
        (CurrentEquip[1] as SCX_BaseEquipment).removeMorphs(MyActor)
        MyActor.UnequipItem(CurrentEquip, False, True)
        MyActor.RemoveItem(CurrentEquip, 1, False)
      EndIf
      Int Tier = Belly.findEquipTier(NewSet, CurrentSize)
      CurrentTier = Tier
      Armor NewArmor = Belly.getEquipment(NewSet, Tier)
      If !MyActor.IsEquipped(NewArmor)
        MyActor.AddItem(NewArmor, 1, True)
        MyActor.EquipItem(NewArmor, True)
      EndIf
      CurrentSet = NewSet
      CurrentEquip[1] = NewArmor
      CurrentEquip[0] = Belly.getEquipment(NewSet, Tier - 1)
      CurrentEquip[2] = Belly.getEquipment(NewSet, Tier + 1)

      If CurrentEquip[2] as SCX_BaseEquipment
        UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
      Else
        UpperThreshold = -1
      EndIf
      If CurrentEquip[0] as SCX_BaseEquipment
        LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
      Else
        LowerThreshold = -1
      EndIf
    EndIf

    Float TargetValue = JMap.getFlt(ActorData, "SCX_BodyEditBellyTargetValue")
    Float Inc = Belly.Increment
    If TargetValue == CurrentSize
      Return
    ElseIf Math.abs(TargetValue - CurrentSize) < Inc
      CurrentSize == TargetValue
    ElseIf TargetValue > CurrentSize
      CurrentSize += Inc
    ElseIf TargetValue < CurrentSize
      CurrentSize -= Inc
    EndIf
    ;Can only move between tiers if upper/lower Threshold isn't -1
    If UpperThreshold != -1 && CurrentSize > UpperThreshold
      CurrentTier += 1
      If CurrentEquip
        If MyActor.IsEquipped(CurrentEquip)
          (CurrentEquip[1] as SCX_BaseEquipment).removeMorphs(MyActor)
          MyActor.UnequipItem(CurrentEquip, False, True)
          MyActor.RemoveItem(CurrentEquip, 1, True)
        EndIf
      EndIf
      Armor NewArmor
      NewArmor = CurrentEquip[2]
      CurrentEquip[0] = CurrentEquip[1]
      CurrentEquip[1] = NewArmor
      CurrentEquip[2] = Belly.getEquipment(NewSet, CurrentTier + 1)
      If NewArmor
        If !MyActor.IsEquipped(NewArmor)
          MyActor.AddItem(NewArmor, 1, True)
          MyActor.EquipItem(NewArmor, True)
        EndIf
      EndIf
      If CurrentEquip[2] as SCX_BaseEquipment
        UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
      Else
        UpperThreshold = -1
      EndIf
      If CurrentEquip[0] as SCX_BaseEquipment
        LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
      Else
        LowerThreshold = -1
      EndIf
    ElseIf LowerThreshold != -1 && CurrentSize < LowerThreshold
      CurrentTier -= 1
      If CurrentEquip
        If MyActor.IsEquipped(CurrentEquip)
          (CurrentEquip[1] as SCX_BaseEquipment).removeMorphs(MyActor)
          MyActor.UnequipItem(CurrentEquip, False, True)
          MyActor.RemoveItem(CurrentEquip, 1, True)
        EndIf
      EndIf
      Armor NewArmor
      NewArmor = CurrentEquip[0]
      CurrentEquip[0] = Belly.getEquipment(NewSet, CurrentTier - 1)
      CurrentEquip[1] = NewArmor
      CurrentEquip[2] = CurrentEquip[1]
      If NewArmor
        If !MyActor.IsEquipped(NewArmor)
          MyActor.AddItem(NewArmor, 1, True)
          MyActor.EquipItem(NewArmor, True)
        EndIf
      EndIf
      UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
      LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
    EndIf
    (CurrentEquip[1] as SCX_BaseEquipment).ApplyMorphs(MyActor, CurrentSize)
    RegisterForSingleUpdate(0.1)
  EndEvent
EndState

Function purgeMethods()
  NiOverride.RemoveNodeTransformScale(MyActor, False, Gender, "NPC Belly", ShortModKey)
  String sKey = SLIF_Main.ConvertToKey("NPC Belly")
  If SLIF_Main.HasScale(MyActor, FullModKey, sKey)
    SLIF_Main.resetActor(MyActor, FullModKey, sKey)
  EndIf
  SCX_BaseEquipment Equip = CurrentEquip[1] as SCX_BaseEquipment
  If Equip
    If MyActor.IsEquipped(Equip)
      Equip.removeMorphs(MyActor)
      MyActor.UnequipItem(Equip, False, True)
      MyActor.RemoveItem(Equip, 1, True)
    EndIf
  EndIf
  CurrentEquip[0] = None
  CurrentEquip[1] = None
  CurrentEquip[2] = None
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
