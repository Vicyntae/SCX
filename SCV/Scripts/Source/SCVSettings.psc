ScriptName SCVSettings Extends SCX_BaseSettings

SCV_GameLibrary Property GameLibrary Auto
GlobalVariable Property SCV_SET_OVPredPercent Auto
Int Property OVPredPercent
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "OVPredPercent")
      JMap.setInt(JM_Settings, "OVPredPercent", 30)
      SCV_SET_OVPredPercent.SetValueInt(30)
    EndIf
    Int GloVar = SCV_SET_OVPredPercent.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "OVPredPercent")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "OVPredPercent", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      JMap.setInt(JM_Settings, "OVPredPercent", a_val)
      SCV_SET_OVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_AVPredPercent Auto
Int Property AVPredPercent
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "AVPredPercent")
      JMap.setInt(JM_Settings, "AVPredPercent", 30)
      SCV_SET_AVPredPercent.SetValueInt(30)
    EndIf
    Int GloVar = SCV_SET_AVPredPercent.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "AVPredPercent")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "AVPredPercent", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      JMap.setInt(JM_Settings, "AVPredPercent", a_val)
      SCV_SET_AVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_UVPredPercent Auto
Int Property UVPredPercent
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "UVPredPercent")
      JMap.setInt(JM_Settings, "UVPredPercent", 30)
      SCV_SET_UVPredPercent.SetValueInt(30)
    EndIf
    Int GloVar = SCV_SET_UVPredPercent.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "UVPredPercent")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "UVPredPercent", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      JMap.setInt(JM_Settings, "UVPredPercent", a_val)
      SCV_SET_UVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_CVPredPercent Auto
Int Property CVPredPercent
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "CVPredPercent")
      JMap.setInt(JM_Settings, "CVPredPercent", 30)
      SCV_SET_CVPredPercent.SetValueInt(30)
    EndIf
    Int GloVar = SCV_SET_CVPredPercent.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "CVPredPercent")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "CVPredPercent", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      JMap.setInt(JM_Settings, "CVPredPercent", a_val)
      SCV_SET_CVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnablePlayerEssentialVore Auto
Bool Property EnablePlayerEssentialVore
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnablePlayerEssentialVore")
      JMap.setInt(JM_Settings, "EnablePlayerEssentialVore", 1)
      SCV_SET_EnablePlayerEssentialVore.SetValueInt(1)
    EndIf
    Bool GloVar = SCV_SET_EnablePlayerEssentialVore.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnablePlayerEssentialVore")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnablePlayerEssentialVore", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnablePlayerEssentialVore", 1)
      SCV_SET_EnablePlayerEssentialVore.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnablePlayerEssentialVore", 0)
      SCV_SET_EnablePlayerEssentialVore.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableEssentialVore Auto
Bool Property EnableEssentialVore
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableEssentialVore")
      JMap.setInt(JM_Settings, "EnableEssentialVore", 0)
      SCV_SET_EnableEssentialVore.SetValueInt(0)
    EndIf
    Bool GloVar = SCV_SET_EnableEssentialVore.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableEssentialVore")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableEssentialVore", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableEssentialVore", 1)
      SCV_SET_EnableEssentialVore.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableEssentialVore", 0)
      SCV_SET_EnableEssentialVore.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableMPreds Auto
Bool Property EnableMPreds
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableMPreds")
      JMap.setInt(JM_Settings, "EnableMPreds", 1)
      SCV_SET_EnableMPreds.SetValueInt(1)
    EndIf
    Bool GloVar = SCV_SET_EnableMPreds.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableMPreds")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableMPreds", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableMPreds", 1)
      SCV_SET_EnableMPreds.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableMPreds", 0)
      SCV_SET_EnableMPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableMTeamPreds Auto
Bool Property EnableMTeamPreds
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableMTeamPreds")
      JMap.setInt(JM_Settings, "EnableMTeamPreds", 1)
      SCV_SET_EnableMTeamPreds.SetValueInt(1)
    EndIf
    Bool GloVar = SCV_SET_EnableMTeamPreds.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableMTeamPreds")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableMTeamPreds", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableMTeamPreds", 1)
      SCV_SET_EnableMTeamPreds.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableMTeamPreds", 0)
      SCV_SET_EnableMTeamPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableFPreds Auto
Bool Property EnableFPreds
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableFPreds")
      JMap.setInt(JM_Settings, "EnableFPreds", 1)
      SCV_SET_EnableFPreds.SetValueInt(1)
    EndIf
    Bool GloVar = SCV_SET_EnableFPreds.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableFPreds")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableFPreds", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableFPreds", 1)
      SCV_SET_EnableFPreds.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableFPreds", 0)
      SCV_SET_EnableFPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableFTeamPreds Auto
Bool Property EnableFTeamPreds
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableFTeamPreds")
      JMap.setInt(JM_Settings, "EnableFTeamPreds", 1)
      SCV_SET_EnableFTeamPreds.SetValueInt(1)
    EndIf
    Bool GloVar = SCV_SET_EnableFTeamPreds.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableFTeamPreds")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableFTeamPreds", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableFTeamPreds", 1)
      SCV_SET_EnableFTeamPreds.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableFTeamPreds", 0)
      SCV_SET_EnableFTeamPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_StruggleMod Auto ;Default 1
Float Property StruggleMod
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "StruggleMod")
      JMap.setFlt(JM_Settings, "StruggleMod", 1)
      SCV_SET_StruggleMod.SetValue(1)
    EndIf
    Float GloVar = SCV_SET_StruggleMod.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "StruggleMod")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "StruggleMod", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val >= 0
      JMap.setInt(JM_Settings, "StruggleMod", a_val as Int)
      SCV_SET_StruggleMod.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_DamageMod Auto  ;Default 1
Float Property DamageMod
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "DamageMod")
      JMap.setFlt(JM_Settings, "DamageMod", 1)
      SCV_SET_DamageMod.SetValue(1)
    EndIf
    Float GloVar = SCV_SET_DamageMod.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "DamageMod")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "DamageMod", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val >= 0
      JMap.setInt(JM_Settings, "DamageMod", a_val as Int)
      SCV_SET_DamageMod.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_AVDestinationChoice Auto
Int Property AVDestinationChoice
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "AVDestinationChoice")
      JMap.setInt(JM_Settings, "AVDestinationChoice", 0)
      SCV_SET_AVDestinationChoice.SetValueInt(30)
    EndIf
    Int GloVar = SCV_SET_AVDestinationChoice.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "AVDestinationChoice")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "AVDestinationChoice", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0
      JMap.setInt(JM_Settings, "AVDestinationChoice", a_val)
      SCV_SET_AVDestinationChoice.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

Int Property JM_VoreAnimationList
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_VoreAnimationList")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_VoreAnimationList", ArchList, True)
      Int Handle = ModEvent.Create("SCV_BuildVoreAnimationList")
      ModEvent.Send(Handle)
    EndIf
    Return ArchList
  EndFunction
EndProperty

Int Property JM_DefaultAnimList
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_DefaultAnimList")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_DefaultAnimList", ArchList, True)
      Int Handle = ModEvent.Create("SCV_BuildDefaultVoreAnimationList")
      ModEvent.Send(Handle)
    EndIf
    Return ArchList
  EndFunction
EndProperty


Spell Property FollowSpell Auto

FormList Property SCV_VoreSpellList Auto

MagicEffect Property SCV_FrenzyLevel2 Auto
MagicEffect Property SCV_FrenzyLevel1 Auto

FormList Property NourishSpells Auto
FormList Property StruggleStaminaSpells Auto
FormList Property StruggleMagickaSpells Auto
FormList Property StruggleHealthSpells Auto

Spell Property SCV_DebugSpell Auto


Spell Property SCV_PredMarker Auto
Spell Property SCV_OVPredMarker Auto
Spell Property SCV_AVPredMarker Auto
Spell Property SCV_UVPredMarker Auto
Spell Property SCV_CVPredMarker Auto

Spell Property SCV_HasStrugglePrey Auto
Spell Property SCV_HasOVStrugglePrey Auto
Spell Property SCV_HasAVStrugglePrey Auto
Spell Property SCV_HasUVStrugglePrey Auto
Spell Property SCV_HasCVStrugglePrey Auto
Spell Property IsStrugglingSpell Auto

FormList Property SCV_OVPredSpellList Auto
FormList Property SCV_AVPredSpellList Auto
FormList Property SCV_UVPredSpellList Auto
FormList Property SCV_CVPredSpellList Auto

Spell Property SCV_HasOVBreakdownPrey Auto
Spell Property SCV_HasAVBreakdownPrey Auto
Spell Property SCV_HasUVBreakdownPrey Auto
Spell Property SCV_HasCVBreakdownPrey Auto

LeveledItem Property SCV_LeveledHumanItems Auto
LeveledItem Property SCV_LeveledDragonItems Auto
LeveledItem Property SCV_LeveledDwarvenItems Auto
LeveledItem Property SCV_LeveledGhostItems Auto
LeveledItem Property SCV_LeveledUndeadItems Auto
LeveledItem Property SCV_LeveledDaedraItems Auto
LeveledItem Property SCV_LeveledBossItems Auto

Formlist Property SCV_VIPreyList Auto
FormList Property SCV_EssentialTrackingList Auto
ObjectReference Property SCV_EssentialTrackerCellMarker Auto

Faction Property SCV_FACT_OVPredBlocked Auto
Faction Property SCV_FACT_AVPredBlocked Auto
Faction Property SCV_FACT_PreyProtected Auto
Faction Property SCV_FACT_Animated Auto

ReferenceAlias Property SCV_FollowPred Auto

Potion Property SCV_DummyFoodItem Auto
;/SCVInsertPreyThreadManager Property InsertPreyThreadManager Auto
SCVProcessPreyThreadManager Property ProcessPreyThreadManager Auto
SCVAnimationThreadHandler Property AnimationThreadHandler Auto
SCVInsertItemsContainer Property SCV_InsertItemsChest Auto
SCVEssentialTracker Property SCVEssential Auto/;

;Size Matters ------------------------------------------------------------------
Bool Property SizeMatters_Initialized = False Auto
Bool Property SizeMattersActive = True Auto

;Sound Effects *****************************************************************
Topic Property SCV_SwallowSound Auto
Topic Property SCV_TakeInSound Auto

Topic Property SCV_BurpSound Auto
Topic Property SCV_HurtSound Auto
Topic Property SCV_AFinishSound Auto
Topic Property SCV_UVFinishSound Auto
Topic Property SCV_CVFinishSound Auto

Float _FollowTimer = 0.5
Float Property FollowTimer
  Float Function Get()
    Return _FollowTimer
  EndFunction
  Function Set(Float a_val)
    If a_val > 0
      _FollowTimer = a_val
    EndIf
  EndFunction
EndProperty

Bool _SCL_Installed
Bool Property SCL_Installed
  Bool Function Get()
    Return _SCL_Installed
  EndFunction
  Function Set(Bool abValue)
    If abValue != _SCL_Installed
      If abValue == True
        ;Add stuff for SCL Here
      Else
        ;Remove stuff for SCL Here
      EndIf
      _SCL_Installed = abValue
    EndIf
  EndFunction
EndProperty

Bool _SCW_Installed
Bool Property SCW_Installed
  Bool Function Get()
    Return _SCW_Installed
  EndFunction
  Function Set(Bool abValue)
    If abValue != _SCW_Installed
      If abValue == True
        ;Add stuff for SCW Here
      Else
        ;Remove stuff for SCW Here
      EndIf
      _SCW_Installed = abValue
    EndIf
  EndFunction
EndProperty
