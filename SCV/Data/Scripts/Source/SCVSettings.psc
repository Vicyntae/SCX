ScriptName SCVSettings Extends SCX_BaseQuest

GlobalVariable Property SCV_SET_OVPredPercent Auto
Int Property OVPredPercent
  Int Function Get()
    Return SCV_SET_OVPredPercent.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      SCV_SET_OVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_AVPredPercent Auto
Int Property AVPredPercent
  Int Function Get()
    Return SCV_SET_AVPredPercent.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      SCV_SET_AVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_UVPredPercent Auto
Int Property UVPredPercent
  Int Function Get()
    Return SCV_SET_UVPredPercent.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      SCV_SET_UVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_CVPredPercent Auto
Int Property CVPredPercent
  Int Function Get()
    Return SCV_SET_CVPredPercent.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 100
      SCV_SET_CVPredPercent.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnablePlayerEssentialVore Auto
Bool Property EnablePlayerEssentialVore
  Bool Function Get()
    Return SCV_SET_EnablePlayerEssentialVore.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCV_SET_EnablePlayerEssentialVore.SetValueInt(1)
    Else
      SCV_SET_EnablePlayerEssentialVore.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableEssentialVore Auto
Bool Property EnableEssentialVore
  Bool Function Get()
    Return SCV_SET_EnableEssentialVore.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCV_SET_EnableEssentialVore.SetValueInt(1)
    Else
      SCV_SET_EnableEssentialVore.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableMPreds Auto
Bool Property EnableMPreds
  Bool Function Get()
    Return SCV_SET_EnableMPreds.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCV_SET_EnableMPreds.SetValueInt(1)
    Else
      SCV_SET_EnableMPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableMTeamPreds Auto
Bool Property EnableMTeamPreds
  Bool Function Get()
    Return SCV_SET_EnableMTeamPreds.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCV_SET_EnableMTeamPreds.SetValueInt(1)
    Else
      SCV_SET_EnableMTeamPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableFPreds Auto
Bool Property EnableFPreds
  Bool Function Get()
    Return SCV_SET_EnableFPreds.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCV_SET_EnableFPreds.SetValueInt(1)
    Else
      SCV_SET_EnableFPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_EnableFTeamPreds Auto
Bool Property EnableFTeamPreds
  Bool Function Get()
    Return SCV_SET_EnableFTeamPreds.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCV_SET_EnableFTeamPreds.SetValueInt(1)
    Else
      SCV_SET_EnableFTeamPreds.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_StruggleMod Auto ;Default 1
Float Property StruggleMod
  Float Function Get()
    Return SCV_SET_StruggleMod.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      SCV_SET_StruggleMod.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_DamageMod Auto  ;Default 1
Float Property DamageMod
  Float Function Get()
    Return SCV_SET_DamageMod.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      SCV_SET_DamageMod.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCV_SET_AVDestinationChoice Auto
Int Property AVDestinationChoice
  Int Function Get()
    Return SCV_SET_AVDestinationChoice.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    SCV_SET_AVDestinationChoice.SetValueInt(a_val)
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
