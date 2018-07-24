ScriptName SCX_BodyEditBellyTracker Extends ActiveMagicEffect

Actor MyActor
Int ActorData
Bool Gender ;False for male, True for female
SCX_BodyEditBelly Property Belly Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto

String ShortModKey = "SCX.esp"
String FullModKey = "Skyrim Character Extended"

Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  ActorData = SCXLib.getTargetData(MyActor)
  Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
  String Method = JMap.getStr(ActorData, Belly.MethodKey)
  GoToState(Method)
  RegisterForModEvent("SCX_BodyEditBellySpellMethodUpdate", "OnMethodUpdate")
EndEvent

Event OnMethodUpdate()
  Gender = MyActor.GetLeveledActorBase().GetSex() as Bool
  String Method = JMap.getStr(ActorData, Belly.MethodKey)
  If Method != GetState()
    GoToState(Method)
  EndIf
  RegisterForSingleUpdate(0.1)
EndEvent

State Disabled
  ;Remove all scaling methods
  Event OnBeginState()
    purgeMethods()
  EndEvent
EndState

State NiOverride
  Event OnBeginState()
    purgeMethods()
    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    CurrentSize = NiOverride.GetNodeTransformScale(MyActor, False, Gender, "NPC Belly", ShortModKey)
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
    NiOverride.AddNodeTransformScale(MyActor, False, Gender, "NPC Belly", ShortModKey, CurrentSize)
    RegisterForSingleUpdate(0.1)
  EndEvent
EndState

State SLIF
  Event OnBeginState()
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

    UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
    LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
    RegisterForSingleUpdate(0.1)
  EndEvent

  Event OnUpdate()
    Int NewSet = JMap.getInt(ActorData, Belly.EquipmentSetKey)
    If NewSet && NewSet != CurrentSet
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

      UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
      LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
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
    If CurrentSize > UpperThreshold || CurrentSize < LowerThreshold
      If CurrentEquip
        If MyActor.IsEquipped(CurrentEquip)
          (CurrentEquip[1] as SCX_BaseEquipment).removeMorphs(MyActor)
          MyActor.UnequipItem(CurrentEquip, False, True)
          MyActor.RemoveItem(CurrentEquip, 1, True)
        EndIf
      EndIf
      Armor NewArmor
      If CurrentSize > UpperThreshold
        NewArmor = CurrentEquip[2]
        CurrentEquip[0] = CurrentEquip[1]
        CurrentEquip[1] = NewArmor
        CurrentEquip[2] = Belly.getEquipment(NewSet, CurrentTier + 1)
      ElseIf CurrentSize < LowerThreshold
        NewArmor = CurrentEquip[0]
        CurrentEquip[2] = CurrentEquip[1]
        CurrentEquip[1] = NewArmor
        CurrentEquip[2] = Belly.getEquipment(NewSet, CurrentTier - 1)
      EndIf
      If NewArmor
        If !MyActor.IsEquipped(NewArmor)
          MyActor.AddItem(NewArmor, 1, True)
          MyActor.EquipItem(NewArmor, True)
        EndIf
      EndIf
      UpperThreshold = (CurrentEquip[2] as SCX_BaseEquipment).Threshold
      LowerThreshold = (CurrentEquip[1] as SCX_BaseEquipment).Threshold
    EndIf ;Apply new armor

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
