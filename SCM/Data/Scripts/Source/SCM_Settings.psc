ScriptName SCM_Settings Extends SCX_BaseQuest

;CBBE Slider Data (Muscle)

;/Int Property JM_SCM_CBBEMuscleSliders
  Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_SCM_CBBEMuscleSliders")
  If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
    ArchList = JMap.object()
    JDB.solveObjSetter(".SCX_ExtraData.JM_SCM_CBBEMuscleSliders", ArchList, True)
    JMap.setFlt(ArchList, "AnkleSize", 0)
    JMap.setFlt(ArchList, "AppleCheeks", 0)
    JMap.setFlt(ArchList, "AreolaSize", 0)
    JMap.setFlt(ArchList, "Arms", 0)
    JMap.setFlt(ArchList, "Back", 0)
    JMap.setFlt(ArchList, "BackArch", 0)
    JMap.setFlt(ArchList, "Belly", 0)
    JMap.setFlt(ArchList, "BigBelly", 0)
    JMap.setFlt(ArchList, "BigButt", 0)
    JMap.setFlt(ArchList, "BigTorso", 0)
    JMap.setFlt(ArchList, "BreastCenter", 0)
    JMap.setFlt(ArchList, "BreastCenterBig", 0)
    JMap.setFlt(ArchList, "BreastCleavage", 0)
    JMap.setFlt(ArchList, "BreastFlatness2", 0)
    JMap.setFlt(ArchList, "BreastFlatness", 0)
    JMap.setFlt(ArchList, "BreastGravity", 0)
    JMap.setFlt(ArchList, "BreastHeight", 0)
    JMap.setFlt(ArchList, "BreastPerkiness", 0)
    JMap.setFlt(ArchList, "Breasts", 0)
    JMap.setFlt(ArchList, "BreastsFantasy", 0)
    JMap.setFlt(ArchList, "BreastsGone", 0)
    JMap.setFlt(ArchList, "BreastsNewSH", 0)
    JMap.setFlt(ArchList, "BreastsSmall", 0)
    JMap.setFlt(ArchList, "BreastsSmall2", 0)
    JMap.setFlt(ArchList, "BreastsTogether", 0)
    JMap.setFlt(ArchList, "BreastsTopSlope", 0)
    JMap.setFlt(ArchList, "BreastsWidth", 0)
    JMap.setFlt(ArchList, "Butt", 0)
    JMap.setFlt(ArchList, "ButtClassic", 0)
    JMap.setFlt(ArchList, "ButtCrack", 0)
    JMap.setFlt(ArchList, "ButtShape2", 0)
    JMap.setFlt(ArchList, "ButtSmall", 0)
    JMap.setFlt(ArchList, "CalfSize", 0)
    JMap.setFlt(ArchList, "CalfSmooth", 0)
    JMap.setFlt(ArchList, "ChestDepth", 0)
    JMap.setFlt(ArchList, "ChestWidth", 0)
    JMap.setFlt(ArchList, "ChubbyArms", 0)
    JMap.setFlt(ArchList, "ChubbyButt", 0)
    JMap.setFlt(ArchList, "ChubbyLegs", 0)
    JMap.setFlt(ArchList, "ChubbyWaist", 0)
    JMap.setFlt(ArchList, "CrotchBack", 0)
    JMap.setFlt(ArchList, "DoubleMelon", 0)
    JMap.setFlt(ArchList, "ForearmSize", 0)
    JMap.setFlt(ArchList, "Groin", 0)
    JMap.setFlt(ArchList, "Hipbone", 0)
    JMap.setFlt(ArchList, "HipForward", 0)
    JMap.setFlt(ArchList, "Hips", 0)
    JMap.setFlt(ArchList, "HipUpperWidth", 0)
    JMap.setFlt(ArchList, "KneeHeight", 0)
    JMap.setFlt(ArchList, "KneeShape", 0)
    JMap.setFlt(ArchList, "LegShapeClassic", 0)
    JMap.setFlt(ArchList, "LegsThin", 0)
    JMap.setFlt(ArchList, "MuscleAbs", 2)
    JMap.setFlt(ArchList, "MuscleArms", 2)
    JMap.setFlt(ArchList, "MuscleButt", 2)
    JMap.setFlt(ArchList, "MuscleLegs", 2)
    JMap.setFlt(ArchList, "MusclePecs", 2)
    JMap.setFlt(ArchList, "NeckSeam", 0)
    JMap.setFlt(ArchList, "NipBGone", 0)
    JMap.setFlt(ArchList, "NippleDistance", 0)
    JMap.setFlt(ArchList, "NippleLength", 0)
    JMap.setFlt(ArchList, "NippleManga", 0)
    JMap.setFlt(ArchList, "NipplePerkiness", 0)
    JMap.setFlt(ArchList, "NipplePerkManga", 0)
    JMap.setFlt(ArchList, "NippleSize", 0)
    JMap.setFlt(ArchList, "NippleTip", 0)
    JMap.setFlt(ArchList, "NippleTipManga", 0)
    JMap.setFlt(ArchList, "NippleUp", 0)
    JMap.setFlt(ArchList, "PregancyBelly", 0)
    JMap.setFlt(ArchList, "PushUp", 0)
    JMap.setFlt(ArchList, "RibsProminance", 0)
    JMap.setFlt(ArchList, "RoundAss", 0)
    JMap.setFlt(ArchList, "ShoulderSmooth", 0)
    JMap.setFlt(ArchList, "ShoulderTweak", 0)
    JMap.setFlt(ArchList, "ShoulderWidth", 0)
    JMap.setFlt(ArchList, "SlimThighs", 0)
    JMap.setFlt(ArchList, "SternumDepth", 0)
    JMap.setFlt(ArchList, "SternumHeight", 0)
    JMap.setFlt(ArchList, "Thighs", 0)
    JMap.setFlt(ArchList, "TummyTuck", 0)
    JMap.setFlt(ArchList, "Waist", 0)
    JMap.setFlt(ArchList, "WaistHeight", 0)
    JMap.setFlt(ArchList, "WideWaistLine", 0)
    JMap.setFlt(ArchList, "WristSize", 0)
    JMap.setFlt(ArchList, "7B Lower", 0)
    JMap.setFlt(ArchList, "7B Upper", 0)
    JMap.setFlt(ArchList, "VanilaSSEHi", 0)
    JMap.setFlt(ArchList, "VanilaSSELo", 0)
    JMap.setFlt(ArchList, "OldBaseShape", 0)
  EndIf
  Return ArchList
EndProperty/;

Bool Property SCN_Installed Auto
Bool Property UseSCNCalories Auto
;Fat ***************************************************************************
;/Float Property FatHealthRating Auto
Float Property FatStaminaRating Auto
Float Property FatMagickaRating Auto
Float Property FatMin Auto
Float Property FatMax Auto

Int Property JM_FatActorValueRatings
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM__SCM_FatActorValueRatings")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_FatActorValueRatings", ArchList, True)
      JMap.setFlt(ArchList, "OneHanded", 0)
      JMap.setFlt(ArchList, "TwoHanded", 0)
      JMap.setFlt(ArchList, "Marksman", 0)
      JMap.setFlt(ArchList, "Block", 0)
      JMap.setFlt(ArchList, "Smithing", 0)
      JMap.setFlt(ArchList, "HeavyArmor", 0)
      JMap.setFlt(ArchList, "LightArmor", 0)
      JMap.setFlt(ArchList, "Pickpocket", 0)
      JMap.setFlt(ArchList, "Lockpicking", 0)
      JMap.setFlt(ArchList, "Sneak", 0)
      JMap.setFlt(ArchList, "Alchemy", 0)
      JMap.setFlt(ArchList, "Speechcraft", 0)
      JMap.setFlt(ArchList, "Alteration", 0)
      JMap.setFlt(ArchList, "Conjuration", 0)
      JMap.setFlt(ArchList, "Destruction", 0)
      JMap.setFlt(ArchList, "Illusion", 0)
      JMap.setFlt(ArchList, "Restoration", 0)
      JMap.setFlt(ArchList, "Enchanting", 0)
    EndIf
    Return ArchList
  EndFunction
EndProperty

;Weight ************************************************************************
Float Property WeightHealthRating Auto
Float Property WeightStaminaRating Auto
Float Property WeightMagickaRating Auto
Float Property WeightMin Auto
Float Property WeightMax Auto

Int Property JM_WeightActorValueRatings
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_WeightActorValueRatings")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_WeightActorValueRatings", ArchList, True)
      JMap.setFlt(ArchList, "OneHanded", 0)
      JMap.setFlt(ArchList, "TwoHanded", 0)
      JMap.setFlt(ArchList, "Marksman", 0)
      JMap.setFlt(ArchList, "Block", 0)
      JMap.setFlt(ArchList, "Smithing", 0)
      JMap.setFlt(ArchList, "HeavyArmor", 0)
      JMap.setFlt(ArchList, "LightArmor", 0)
      JMap.setFlt(ArchList, "Pickpocket", 0)
      JMap.setFlt(ArchList, "Lockpicking", 0)
      JMap.setFlt(ArchList, "Sneak", 0)
      JMap.setFlt(ArchList, "Alchemy", 0)
      JMap.setFlt(ArchList, "Speechcraft", 0)
      JMap.setFlt(ArchList, "Alteration", 0)
      JMap.setFlt(ArchList, "Conjuration", 0)
      JMap.setFlt(ArchList, "Destruction", 0)
      JMap.setFlt(ArchList, "Illusion", 0)
      JMap.setFlt(ArchList, "Restoration", 0)
      JMap.setFlt(ArchList, "Enchanting", 0)
    EndIf
    Return ArchList
  EndFunction
EndProperty

;Weight ************************************************************************
Float Property HeightHealthRating Auto
Float Property HeightStaminaRating Auto
Float Property HeightMagickaRating Auto
Float Property HeightMin Auto
Float Property HeightMax Auto

Int Property JM_HeightActorValueRatings
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_HeightActorValueRatings")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_HeightActorValueRatings", ArchList, True)
      JMap.setFlt(ArchList, "OneHanded", 0)
      JMap.setFlt(ArchList, "TwoHanded", 0)
      JMap.setFlt(ArchList, "Marksman", 1)
      JMap.setFlt(ArchList, "Block", 0)
      JMap.setFlt(ArchList, "Smithing", 0)
      JMap.setFlt(ArchList, "HeavyArmor", 0)
      JMap.setFlt(ArchList, "LightArmor", 0)
      JMap.setFlt(ArchList, "Pickpocket", 1)
      JMap.setFlt(ArchList, "Lockpicking", 1)
      JMap.setFlt(ArchList, "Sneak", 1)
      JMap.setFlt(ArchList, "Alchemy", 0)
      JMap.setFlt(ArchList, "Speechcraft", 0)
      JMap.setFlt(ArchList, "Alteration", 0)
      JMap.setFlt(ArchList, "Conjuration", 0)
      JMap.setFlt(ArchList, "Destruction", 0)
      JMap.setFlt(ArchList, "Illusion", 0)
      JMap.setFlt(ArchList, "Restoration", 0)
      JMap.setFlt(ArchList, "Enchanting", 0)
    EndIf
    Return ArchList
  EndFunction
EndProperty/;
