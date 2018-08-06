ScriptName SCVLibrary Extends SCX_BaseLibrary
;*******************************************************************************
;Variables and Properties
;*******************************************************************************
SCVSettings Property SCVSet Auto
SCVStrugglingArchetype Property Struggling Auto
SCX_BasePerk Property StruggleSorcery Auto
;*******************************************************************************
;Library Functions
;*******************************************************************************
Function genActorProfile(Actor akTarget, Bool abBasic, Int aiTargetData)
  If JMap.getInt(aiTargetData, "SCLBasicProfile") > 0
    JMap.setInt(aiTargetData, "SCV_IsOVPred", 0)
    JMap.setInt(aiTargetData, "SCV_OVLevel", 1)
    JMap.setInt(aiTargetData, "SCV_AVLevel", 1)
    JMap.setInt(aiTargetData, "SCV_Allure", 0)

    JMap.setInt(aiTargetData, "SCV_ResLevel", 10)
    JMap.setInt(aiTargetData, "SCV_PredDamageRating", JMap.getInt(aiTargetData, "SCV_PredDamageRating") + 5)
    JMap.setInt(aiTargetData, "SCV_PreyDamageRating", JMap.getInt(aiTargetData, "SCV_PreyDamageRating") + 10)

  Else
    Bool bPred = False
    Bool bOVPred = False
    If SCVSet.OVPredPercent
      Int PredChance = Utility.RandomInt()
      If PredChance <= SCVSet.OVPredPercent
        JMap.setInt(aiTargetData, "SCV_IsOVPred", 1)
        bOVPred = True
        bPred = True
      EndIf
    EndIf
    Bool bAVPred = False
    If SCVSet.AVPredPercent
      Int PredChance = Utility.RandomInt()
      If PredChance <= SCVSet.AVPredPercent
        JMap.setInt(aiTargetData, "SCV_IsAVPred", 1)
        bAVPred = True
        bPred = True
      EndIf
    endIf
    Float[] Chances = genNormalDist()
    Float Chance1 = Chances[0]
    Float Chance2 = Chances[1]
    ;Changes range from +-1 to +- 30
    Chance1 = Math.abs(Chance1)
    Chance2 = Math.abs(Chance2)

    Chance1 *= 30
    Chance2 *= 30
    ;Shift mean to difficulty
    Chance1 += getPredDifficulty()
    Chance2 += getPreyDifficulty()

    PapyrusUtil.ClampFloat(Chance1, 1, 100)
    PapyrusUtil.ClampFloat(Chance2, 1, 100)

    If bPred
      If bOVPred
        JMap.setInt(aiTargetData, "SCV_OVLevel", Math.Ceiling(Chance1))
        If SCVSet.SCL_Installed
          JMap.setFlt(aiTargetData, "SCLStomachCapacity", JMap.getFlt(aiTargetData, "SCLStomachCapacity") + (Math.pow(2, Chance1 / 10)))
          JMap.setFlt(aiTargetData, "SCLDigestRate", JMap.getFlt(aiTargetData, "SCLDigestRate") + (Math.pow(1.3, Chance1 / 11) - 1))
        EndIf
      EndIf
      If bAVPred
        JMap.setInt(aiTargetData, "SCV_AVLevel", Math.Ceiling((Chance1 + Chance2) / 2))
        If SCVSet.SCW_Installed
          takeUpPerks(akTarget, "SCWBasementStorage", 1)
          Int PerkPlus = Utility.RandomInt(1, 10)
          JMap.setInt(aiTargetData, "WF_BasementStorage", JMap.getInt(aiTargetData, "WF_BasementStorage") + PerkPlus)
        EndIf
      EndIf

      ;/initializePerk(akTarget, "SCV_IntenseHunger", Chance1)
      initializePerk(akTarget, "SCV_MetalMuncher", Chance1)
      initializePerk(akTarget, "SCV_ExpiredEpicurian", Chance1)
      initializePerk(akTarget, "SCV_FollowerofNamira", Chance1)
      initializePerk(akTarget, "SCV_DaedraDieter", Chance1)
      initializePerk(akTarget, "SCV_DragonDevourer", Chance1)
      initializePerk(akTarget, "SCV_Constriction", Chance1)
      initializePerk(akTarget, "SCV_SpiritSwallower", Chance1)
      initializePerk(akTarget, "SCV_RemoveLimits", Chance1)
      initializePerk(akTarget, "SCV_Nourish", Chance1)
      initializePerk(akTarget, "SCV_Acid", Chance1)
      initializePerk(akTarget, "SCV_Stalker", Chance1)
      takeUpPerks(akTarget, "SCV_FollowerofNamira", 1)/;
    EndIf

    JMap.setInt(aiTargetData, "SCV_ResLevel", Math.Ceiling(Chance2))
    ;/initializePerk(akTarget, "SCV_CorneredRat", Chance2)
    initializePerk(akTarget, "SCV_StrokeOfLuck", Chance2)
    initializePerk(akTarget, "SCV_ExpectPushback", Chance2)
    initializePerk(akTarget, "SCV_FillingMeal", Chance2)
    initializePerk(akTarget, "SCV_ThrillingStruggle", Chance2)/;
    JMap.setInt(aiTargetData, "SCV_PredDamageRating", JMap.getInt(aiTargetData, "SCV_PredDamageRating") + 10)
    JMap.setInt(aiTargetData, "SCV_PreyDamageRating", JMap.getInt(aiTargetData, "SCV_PreyDamageRating") + 10)
    Int B = Utility.RandomInt(0, 10)
    Int AllureLevel
    If B <= 2
      AllureLevel = -1
    ElseIf B >= 9
      AllureLevel = 1
    Else
      AllureLevel = 0
    EndIf
    JMap.setInt(aiTargetData, "SCV_Allure", AllureLevel)
  ;ElseIf ActorDataVersion >= 2 && StoredVersion < 2
  ;Stuff here
  EndIf
  checkPredAbilities(akTarget)
EndFunction

Function addMCMActorInformation(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  MCM.AddHeaderOption("Vore Stats")
  MCM.AddEmptyOption()
  Bool DEnable = SCXSet.DebugEnable
  String SKey = _getStrKey()

  If DEnable
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Resistance Level", getVoreLevel(akTarget, "Resistance", aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditResLevel")
  Else
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Resistance Vore Level", getVoreLevel(akTarget, "Resistance", aiTargetData)), "Stats." + SKey + ".SCVShowResLevel")
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Resistance Vore EXP", getVoreEXP(akTarget, "Resistance", aiTargetData)), "Stats." + SKey + ".SCVShowResEXP")

  Int JM_PreyCounts = Struggling.getPreyCounts(akTarget, aiTargetData)
  Bool isPred
  Bool isOVPred = isOVPred(akTarget, aiTargetData)
  If (isOVPred && isOVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Set Is Oral Pred", isOVPred), "Stats." + SKey + "SCVEditOVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Oral Vore Level", getVoreLevel(akTarget, "Oral", False, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditOVLevel")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Extra Oral Vore Level", getVoreLevel(akTarget, "Oral", True, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditOVLevelExtra")
    Else
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Is Oral Pred", isOVPred), "Stats." + SKey + "SCVShowOVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Oral Vore Level", getVoreLevel(akTarget, "Oral", False, aiTargetData)), "Stats." + SKey + ".SCVShowOVLevel")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Oral Vore Level Extra", getVoreLevel(akTarget, "Oral", True,  aiTargetData)), "Stats." + SKey + ".SCVShowOVLevelExtra")
    EndIf
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Oral Vore EXP", getVoreEXP(akTarget, "Oral", aiTargetData)), "Stats." + SKey + ".SCVShowOVEXP")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Oral Prey", JMap.getInt(JM_PreyCounts, "Oral")), "Stats." + SKey + ".SCVShowNumOVPrey")
    JIntMap.setStr(JI_Options, MCM.AddMenuOption("Show Oral Prey", ""), "Stats." + SKey + ".SCVShowOVPrey")
  EndIf

  Bool isAVPred = isAVPred(akTarget, aiTargetData)
  If (isAVPred && isAVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Set Is Anal Pred", isAVPred), "Stats." + SKey + "SCVEditAVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Anal Vore Level", getVoreLevel(akTarget, "Anal", False, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditAVLevel")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Extra Anal Vore Level", getVoreLevel(akTarget, "Anal", True, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditAVLevelExtra")
    Else
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Is Anal Pred", isAVPred), "Stats." + SKey + "SCVShowAVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Anal Vore Level", getVoreLevel(akTarget, "Anal", False, aiTargetData)), "Stats." + SKey + ".SCVShowAVLevel")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Anal Vore Level Extra", getVoreLevel(akTarget, "Anal", True, aiTargetData)), "Stats." + SKey + ".SCVShowAVLevelExtra")
    EndIf
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Anal Vore EXP", getVoreEXP(akTarget, "Anal", aiTargetData)), "Stats." + SKey + ".SCVShowAVEXP")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Anal Prey", JMap.getInt(JM_PreyCounts, "Anal")), "Stats." + SKey + ".SCVShowNumAVPrey")
    JIntMap.setStr(JI_Options, MCM.AddMenuOption("Show Anal Prey", ""), "Stats." + SKey + ".SCVShowAVPrey")
  EndIf

  Bool isUVPred = isUVPred(akTarget, aiTargetData)
  If (isUVPred && isUVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Set Is Unbirth Pred", isUVPred), "Stats." + SKey + "SCVEditUVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Unbirth Vore Level", getVoreLevel(akTarget, "Unbirth", False, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditUVLevel")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Extra Unbirth Vore Level", getVoreLevel(akTarget, "Unbirth", True, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditUVLevelExtra")
    Else
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Is Unbirth Pred", isUVPred), "Stats." + SKey + "SCVShowUVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Unbirth Vore Level", getVoreLevel(akTarget, "Unbirth", False, aiTargetData)), "Stats." + SKey + ".SCVShowUVLevel")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Unbirth Vore Level Extra", getVoreLevel(akTarget, "Unbirth", True, aiTargetData)), "Stats." + SKey + ".SCVShowUVLevelExtra")
    EndIf
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Unbirth Vore EXP", getVoreEXP(akTarget, "Unbirth", aiTargetData)), "Stats." + SKey + ".SCVShowUVEXP")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Unbirth Prey", JMap.getInt(JM_PreyCounts, "Unbirth")), "Stats." + SKey + ".SCVShowNumUVPrey")
    JIntMap.setStr(JI_Options, MCM.AddMenuOption("Show Unbirth Prey", ""), "Stats." + SKey + ".SCVShowUVPrey")
  EndIf

  Bool isCVPred = isCVPred(akTarget, aiTargetData)
  If (isCVPred && isCVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Set Is Cock Pred", isCVPred), "Stats." + SKey + "SCVEditCVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Cock Vore Level", getVoreLevel(akTarget, "Cock", False, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditCVLevel")
      JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Extra Cock Vore Level", getVoreLevel(akTarget, "Cock", True, aiTargetData), "{0}"), "Stats." + SKey + ".SCVEditCVLevelExtra")
    Else
      JIntMap.setStr(JI_Options, MCM.AddToggleOption("Is Cock Pred", isCVPred), "Stats." + SKey + "SCVShowCVPredStatus")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Cock Vore Level", getVoreLevel(akTarget, "Cock", False, aiTargetData)), "Stats." + SKey + ".SCVShowUVLevel")
      JIntMap.setStr(JI_Options, MCM.AddTextOption("Cock Vore Level Extra", getVoreLevel(akTarget, "Cock", True, aiTargetData)), "Stats." + SKey + ".SCVShowCVLevelExtra")
    EndIf
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Cock Vore EXP", getVoreEXP(akTarget, "Cock", aiTargetData)), "Stats." + SKey + ".SCVShowCVEXP")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Cock Prey", JMap.getInt(JM_PreyCounts, "Cock")), "Stats." + SKey + ".SCVShowNumCVPrey")
    JIntMap.setStr(JI_Options, MCM.AddMenuOption("Show Cock Prey", ""), "Stats." + SKey + ".SCVShowCVPrey")
  EndIf
EndFunction

Function addMCMActorRecords(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  String SKey = _getStrKey()
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Avoided Being Devoured: ", JMap.getInt(aiTargetData, "SCV_NumTimesAvoidedVore")), "Records." + SKey + ".SCVNumAvoidedVore")

  Int LuckNum = JMap.getInt(aiTargetData, "SCV_StrokeOfLuckActivate")
  If LuckNum
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Strokes of Luck: ", LuckNum), "Records." + SKey + ".SCVNumStokesOfLuck")
  Else
    MCM.AddTextOption("?????", "?????")
  EndIf
  Int DragonGems = JMap.getInt(aiTargetData, "SCV_DragonGemsConsumed")
  If DragonGems
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Num Dragon Gems Consumed: ", DragonGems), "Records." + SKey + ".SCVNumDragonGems")
  Else
    MCM.AddTextOption("?????", "?????")
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Devoured Prey: ", JMap.getInt(aiTargetData, "SCV_NumPreyEaten")), "Records." + SKey + ".SCVNumAllPreyDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Swallowed Prey: ", JMap.getInt(aiTargetData, "SCV_NumOVPreyEaten")), "Records." + SKey + ".SCVNumOVPreyDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Taken In Prey: ", JMap.getInt(aiTargetData, "SCV_NumAVPreyEaten")), "Records." + SKey + ".SCVNumAVPreyDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Unbirthed Prey: ", JMap.getInt(aiTargetData, "SCV_NumUVPreyEaten")), "Records." + SKey + ".SCVNumUVPreyDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Engulfed In Prey: ", JMap.getInt(aiTargetData, "SCV_NumCVPreyEaten")), "Records." + SKey + ".SCVNumCVPreyDevoured")

  JIntMap.setStr(JI_Options, MCM.AddTextOption("Humans Devoured: ", JMap.getInt(aiTargetData, "SCV_NumHumansEaten")), "Records." + SKey + ".SCVNumHumansDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Dragons Devoured: ", JMap.getInt(aiTargetData, "SCV_NumDragonsEaten")), "Records." + SKey + ".SCVNumDragonsDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Dwarven Automatons Devoured: ", JMap.getInt(aiTargetData, "SCV_NumDwarvenEaten")), "Records." + SKey + ".SCVNumDwarvenDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Ghosts Devoured: ", JMap.getInt(aiTargetData, "SCV_NumGhostsEaten")), "Records." + SKey + ".SCVNumGhostsDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Daedra Devoured: ", JMap.getInt(aiTargetData, "SCV_NumUndeadEaten")), "Records." + SKey + ".SCVNumDaedraDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Undead Devoured: ", JMap.getInt(aiTargetData, "SCV_NumDaedraEaten")), "Records." + SKey + ".SCVNumUndeadDevoured")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Important Prey Devoured: ", JMap.getInt(aiTargetData, "SCV_NumImportantEaten")), "Records." + SKey + ".SCVNumImportantDevoured")
EndFunction

Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SCVShowResLevel"
    MCM.ShowMessage("This actor's experience in dealing with predators.", False, "OK")
  ElseIf asValue == "SCVShowResEXP"
    MCM.ShowMessage("Accumulated points towards the next resistance level.", False, "OK")
  ElseIf asValue == "SCVEditOVPredStatus"
    togOVPred(MCM.SelectedActor)
    MCM.ForcePageReset()
  ElseIf asValue == "SCVShowOVPredStatus"
    MCM.ShowMessage("Is this actor an Oral Predator?", False, "OK")
  ElseIf asValue == "SCVShowOVLevel"
    MCM.ShowMessage("This actor's learned experience in swallowing others.", False, "OK")
  ElseIf asValue == "SCVShowOVLevelExtra"
    MCM.ShowMessage("This actor's obtained experience in swallowing others.", False, "OK")
  ElseIf asValue == "SCVShowOVEXP"
    MCM.ShowMessage("Accumulated points towards the next oral vore level.", False, "OK")
  ElseIf asValue == "SCVShowNumOVPrey"
    MCM.ShowMessage("Number of actors swallowed and still struggling.", False, "OK")
  ElseIf asValue == "SCVEditAVPredStatus"
    togAVPred(MCM.SelectedActor)
    MCM.ForcePageReset()
  ElseIf asValue == "SCVShowAVPredStatus"
    MCM.ShowMessage("Is this actor an Anal Predator?", False, "OK")
  ElseIf asValue == "SCVShowAVLevel"
    MCM.ShowMessage("This actor's learned experience in taking in others.", False, "OK")
  ElseIf asValue == "SCVShowAVLevelExtra"
    MCM.ShowMessage("This actor's obtained experience in taking in others.", False, "OK")
  ElseIf asValue == "SCVShowAVEXP"
    MCM.ShowMessage("Accumulated points towards the next anal vore level.", False, "OK")
  ElseIf asValue == "SCVShowNumAVPrey"
    MCM.ShowMessage("Number of actors taken in and still struggling.", False, "OK")
  ElseIf asValue == "SCVEditUVPredStatus"
    togUVPred(MCM.SelectedActor)
    MCM.ForcePageReset()
  ElseIf asValue == "SCVShowUVPredStatus"
    MCM.ShowMessage("Is this actor an Unbirthing Predator?", False, "OK")
  ElseIf asValue == "SCVShowUVLevel"
    MCM.ShowMessage("This actor's learned experience in unbirthing others.", False, "OK")
  ElseIf asValue == "SCVShowUVLevelExtra"
    MCM.ShowMessage("This actor's obtained experience in unbirthing others.", False, "OK")
  ElseIf asValue == "SCVShowUVEXP"
    MCM.ShowMessage("Accumulated points towards the next unbirth vore level.", False, "OK")
  ElseIf asValue == "SCVShowNumUVPrey"
    MCM.ShowMessage("Number of actors unbirthed and still struggling.", False, "OK")
  ElseIf asValue == "SCVEditCVPredStatus"
    togCVPred(MCM.SelectedActor)
    MCM.ForcePageReset()
  ElseIf asValue == "SCVShowCVPredStatus"
    MCM.ShowMessage("Is this actor an Cock Predator?", False, "OK")
  ElseIf asValue == "SCVShowCVLevel"
    MCM.ShowMessage("This actor's learned experience in engulfing others.", False, "OK")
  ElseIf asValue == "SCVShowCVLevelExtra"
    MCM.ShowMessage("This actor's obtained experience in engulfing others.", False, "OK")
  ElseIf asValue == "SCVShowCVEXP"
    MCM.ShowMessage("Accumulated points towards the next cock vore level.", False, "OK")
  ElseIf asValue == "SCVShowNumCVPrey"
    MCM.ShowMessage("Number of actors engulfed and still struggling.", False, "OK")
  ElseIf asValue == "SCVNumAvoidedVore"
    MCM.ShowMessage("Number of times this actor avoided being eaten.", False, "OK")
  ElseIf asValue == "SCVNumStokesOfLuck"
    MCM.ShowMessage("Number of times this actor had very lucky breaks.", False, "OK")
  ElseIf asValue == "SCVNumDragonGems"
    MCM.ShowMessage("Number of times this actor used a very rare dragon gem.", False, "OK")
  ElseIf asValue == "SCVNumAllPreyDevoured"
    MCM.ShowMessage("Number of times this actor devoured another and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumOVPreyDevoured"
    MCM.ShowMessage("Number of times this actor devoured another and subdued them by swallowing them.", False, "OK")
  ElseIf asValue == "SCVNumAVPreyDevoured"
    MCM.ShowMessage("Number of times this actor devoured another and subdued them by taking them in.", False, "OK")
  ElseIf asValue == "SCVNumUVPreyDevoured"
    MCM.ShowMessage("Number of times this actor devoured another and subdued them by unbirthing them.", False, "OK")
  ElseIf asValue == "SCVNumCVPreyDevoured"
    MCM.ShowMessage("Number of times this actor devoured another and subdued them by engulfing them.", False, "OK")
  ElseIf asValue == "SCVNumHumansDevoured"
    MCM.ShowMessage("Number of times this actor devoured humans and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumDragonsDevoured"
    MCM.ShowMessage("Number of times this actor devoured dragons and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumDwarvenDevoured"
    MCM.ShowMessage("Number of times this actor devoured dwarven and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumGhostsDevoured"
    MCM.ShowMessage("Number of times this actor devoured ghosts and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumDaedraDevoured"
    MCM.ShowMessage("Number of times this actor devoured daedra and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumUndeadDevoured"
    MCM.ShowMessage("Number of times this actor devoured undead and subdued them using any method.", False, "OK")
  ElseIf asValue == "SCVNumImportantDevoured"
    MCM.ShowMessage("Number of times this actor devoured VIPs (Very Important Prey) and subdued them using any method.", False, "OK")
  EndIf
EndFunction

Float[] Function getSliderOptions(SCX_ModConfigMenu MCM, String asValue)
  Float[] SliderValues = New Float[5]
  Int ActorData = MCM.SelectedData

  If asValue == "SCVEditResLevel"
    Int Res = getVoreLevel(MCM.SelectedActor, "Resistance", False, MCM.SelectedData)
    SliderValues[0] = Res ;Start Value
    SliderValues[1] = Res ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 100 ;Range Max
  ElseIf asValue == "SCVEditOVLevel"
    Int OVLevel = getVoreLevel(MCM.SelectedActor, "Oral", False, MCM.SelectedData)
    SliderValues[0] = OVLevel ;Start Value
    SliderValues[1] = OVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 100 ;Range Max
  ElseIf asValue == "SCVEditOVLevelExtra"
    Int OVLevel = getVoreLevel(MCM.SelectedActor, "Oral", True, MCM.SelectedData)
    SliderValues[0] = OVLevel ;Start Value
    SliderValues[1] = OVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 1000 ;Range Max
  ElseIf asValue == "SCVEditAVLevel"
    Int AVLevel = getVoreLevel(MCM.SelectedActor, "Anal", False, MCM.SelectedData)
    SliderValues[0] = AVLevel ;Start Value
    SliderValues[1] = AVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 100 ;Range Max
  ElseIf asValue == "SCVEditAVLevelExtra"
    Int AVLevel = getVoreLevel(MCM.SelectedActor, "Anal", True, MCM.SelectedData)
    SliderValues[0] = AVLevel ;Start Value
    SliderValues[1] = AVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 1000 ;Range Max
  ElseIf asValue == "SCVEditUVLevel"
    Int UVLevel = getVoreLevel(MCM.SelectedActor, "Unbirth", False, MCM.SelectedData)
    SliderValues[0] = UVLevel ;Start Value
    SliderValues[1] = UVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 100 ;Range Max
  ElseIf asValue == "SCVEditUVLevelExtra"
    Int UVLevel = getVoreLevel(MCM.SelectedActor, "Unbirth", True, MCM.SelectedData)
    SliderValues[0] = UVLevel ;Start Value
    SliderValues[1] = UVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 1000 ;Range Max
  ElseIf asValue == "SCVEditCVLevel"
    Int CVLevel = getVoreLevel(MCM.SelectedActor, "Cock", False, MCM.SelectedData)
    SliderValues[0] = CVLevel ;Start Value
    SliderValues[1] = CVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 100 ;Range Max
  ElseIf asValue == "SCVEditCVLevelExtra"
    Int CVLevel = getVoreLevel(MCM.SelectedActor, "Cock", True, MCM.SelectedData)
    SliderValues[0] = CVLevel ;Start Value
    SliderValues[1] = CVLevel ;Default Value
    SliderValues[2] = 1 ;Interval
    SliderValues[3] = 1 ;Range Min
    SliderValues[4] = 1000 ;Range Max
  EndIf
  Return SliderValues
EndFunction

Function setSliderOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Float afValue)
  Int ActorData = MCM.SelectedData
  If asValue == "SCVEditResLevel"
    JMap.setInt(ActorData, "SCV_ResLevel", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditOVLevel"
    JMap.setInt(ActorData, "SCV_OVLevel", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditOVLevelExtra"
    JMap.setInt(ActorData, "SCV_OVLevelExtra", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditAVLevel"
    JMap.setInt(ActorData, "SCV_AVLevel", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditAVLevelExtra"
    JMap.setInt(ActorData, "SCV_AVLevelExtra", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditUVLevel"
    JMap.setInt(ActorData, "SCV_UVLevel", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditUVLevelExtra"
    JMap.setInt(ActorData, "SCV_UVLevelExtra", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditCVLevel"
    JMap.setInt(ActorData, "SCV_CVLevel", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCVEditCVLevelExtra"
    JMap.setInt(ActorData, "SCV_CVLevelExtra", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  EndIf
EndFunction

Int[] Function getMCMMenuOptions01(SCX_ModConfigMenu MCM, String asValue)
  Int[] MenuValues = New Int[2]
  MenuValues[0] = 0
  MenuValues[1] = 0
  Return MenuValues
EndFunction

Int JF_MCMMenuOptionsContents
String[] Function getMCMMenuOptions02(SCX_ModConfigMenu MCM, String asValue)
  JF_MCMMenuOptionsContents = JValue.releaseAndRetain(JF_MCMMenuOptionsContents, JFormMap.object())
  If asValue == "SCVShowOVPrey"
    JF_MCMMenuOptionsContents = Struggling.getPreyList(MCM.SelectedActor, "Oral", MCM.SelectedData)
  ElseIf asValue == "SCVShowAVPrey"
    JF_MCMMenuOptionsContents = Struggling.getPreyList(MCM.SelectedActor, "Anal", MCM.SelectedData)
  ElseIf asValue == "SCVShowUVPrey"
    JF_MCMMenuOptionsContents = Struggling.getPreyList(MCM.SelectedActor, "Unbirth", MCM.SelectedData)
  ElseIf asValue == "SCVShowCVPrey"
    JF_MCMMenuOptionsContents = Struggling.getPreyList(MCM.SelectedActor, "Cock", MCM.SelectedData)
  EndIf
  Int NumEntries = JFormMap.count(JF_MCMMenuOptionsContents)
  String[] MenuEntries = Utility.CreateStringArray(JFormMap.count(NumEntries), "")
  Int i = 0
  While i < NumEntries
    Form ItemKey = JFormMap.getNthKey(JF_MCMMenuOptionsContents, i)
    Int JM_ItemEntry = JFormMap.getObj(JF_MCMMenuOptionsContents, ItemKey)
    MenuEntries[i] = Struggling.getItemListDesc(ItemKey, JM_ItemEntry)
    i += 1
  EndWhile
  Return MenuEntries
EndFunction

;/Function setMenuOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Int aiIndex)
EndFunction/;

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SCVEditResLevel"
    MCM.SetInfoText("Edit this actor's experience in dealing with predators.")
  ElseIf asValue == "SCVShowResLevel"
    MCM.SetInfoText("This actor's experience in dealing with predators.")
  ElseIf asValue == "SCVShowResEXP"
    MCM.SetInfoText("Accumulated points towards the next resistance level.")
  ElseIf asValue == "SCVEditOVPredStatus"
    MCM.SetInfoText("Toggle this actor's oral predator state.")
  ElseIf asValue == "SCVEditOVLevel"
    MCM.SetInfoText("Edit this actor's oral vore level.")
  ElseIf asValue == "SCVEditOVLevelExtra"
    MCM.SetInfoText("Edit this actor's extra oral vore level.")
  ElseIf asValue == "SCVShowOVPredStatus"
    MCM.SetInfoText("Is this actor an oral predator?")
  ElseIf asValue == "SCVShowOVLevel"
    MCM.SetInfoText("This actor's learned experience in swallowing others.")
  ElseIf asValue == "SCVShowOVLevelExtra"
    MCM.SetInfoText("This actor's obtained experience in swallowing others.")
  ElseIf asValue == "SCVShowOVEXP"
    MCM.SetInfoText("Accumulated points towards the next oral vore level.")
  ElseIf asValue == "SCVShowNumOVPrey"
    MCM.SetInfoText("Number of actors swallowed and still struggling.")
  ElseIf asValue == "SCVShowOVPrey"
    MCM.SetInfoText("Display list of actors swallowed and still struggling.")
  ElseIf asValue == "SCVEditAVPredStatus"
    MCM.SetInfoText("Toggle this actor's anal predator state.")
  ElseIf asValue == "SCVEditAVLevel"
    MCM.SetInfoText("Edit this actor's anal vore level.")
  ElseIf asValue == "SCVEditAVLevelExtra"
    MCM.SetInfoText("Edit this actor's extra anal vore level.")
  ElseIf asValue == "SCVShowAVPredStatus"
    MCM.SetInfoText("Is this actor an anal predator?")
  ElseIf asValue == "SCVShowAVLevel"
    MCM.SetInfoText("This actor's learned experience in taking in others.")
  ElseIf asValue == "SCVShowAVLevelExtra"
    MCM.SetInfoText("This actor's obtained experience in taking in others.")
  ElseIf asValue == "SCVShowAVEXP"
    MCM.SetInfoText("Accumulated points towards the next anal vore level.")
  ElseIf asValue == "SCVShowNumAVPrey"
    MCM.SetInfoText("Number of actors taken in and still struggling.")
  ElseIf asValue == "SCVShowAVPrey"
    MCM.SetInfoText("Display list of actors taken in and still struggling.")
  ElseIf asValue == "SCVEditUVPredStatus"
    MCM.SetInfoText("Toggle this actor's unbirthing predator state.")
  ElseIf asValue == "SCVEditUVLevel"
    MCM.SetInfoText("Edit this actor's unbirth vore level.")
  ElseIf asValue == "SCVEditUVLevelExtra"
    MCM.SetInfoText("Edit this actor's extra unbirth vore level.")
  ElseIf asValue == "SCVShowUVPredStatus"
    MCM.SetInfoText("Is this actor an unbirthing predator?")
  ElseIf asValue == "SCVShowUVLevel"
    MCM.SetInfoText("This actor's learned experience in unbirthing others.")
  ElseIf asValue == "SCVShowUVLevelExtra"
    MCM.SetInfoText("This actor's obtained experience in unbirthing others.")
  ElseIf asValue == "SCVShowUVEXP"
    MCM.SetInfoText("Accumulated points towards the next unbirth vore level.")
  ElseIf asValue == "SCVShowNumUVPrey"
    MCM.SetInfoText("Number of actors unbirthed and still struggling.")
  ElseIf asValue == "SCVShowUVPrey"
    MCM.SetInfoText("Display list of actors unbirthed and still struggling.")
  ElseIf asValue == "SCVEditCVPredStatus"
    MCM.SetInfoText("Toggle this actor's cock predator state.")
  ElseIf asValue == "SCVEditCVLevel"
    MCM.SetInfoText("Edit this actor's cock vore level.")
  ElseIf asValue == "SCVEditCVLevelExtra"
    MCM.SetInfoText("Edit this actor's extra cock vore level.")
  ElseIf asValue == "SCVShowCVPredStatus"
    MCM.SetInfoText("Is this actor an Cock Predator?")
  ElseIf asValue == "SCVShowCVLevel"
    MCM.SetInfoText("This actor's learned experience in engulfing others.")
  ElseIf asValue == "SCVShowCVLevelExtra"
    MCM.SetInfoText("This actor's obtained experience in engulfing others.")
  ElseIf asValue == "SCVShowCVEXP"
    MCM.SetInfoText("Accumulated points towards the next cock vore level.")
  ElseIf asValue == "SCVShowNumCVPrey"
    MCM.SetInfoText("Number of actors engulfed and still struggling.")
  ElseIf asValue == "SCVShowCVPrey"
    MCM.SetInfoText("Display list of actors engulfed and still struggling.")
  ElseIf asValue == "SCVNumAvoidedVore"
    MCM.SetInfoText("Number of times this actor avoided being eaten.")
  ElseIf asValue == "SCVNumStokesOfLuck"
    MCM.SetInfoText("Number of times this actor had very lucky breaks.")
  ElseIf asValue == "SCVNumDragonGems"
    MCM.SetInfoText("Number of times this actor used a very rare dragon gem.")
  ElseIf asValue == "SCVNumAllPreyDevoured"
    MCM.SetInfoText("Number of times this actor devoured another and subdued them using any method.")
  ElseIf asValue == "SCVNumOVPreyDevoured"
    MCM.SetInfoText("Number of times this actor devoured another and subdued them by swallowing them.")
  ElseIf asValue == "SCVNumAVPreyDevoured"
    MCM.SetInfoText("Number of times this actor devoured another and subdued them by taking them in.")
  ElseIf asValue == "SCVNumUVPreyDevoured"
    MCM.SetInfoText("Number of times this actor devoured another and subdued them by unbirthing them.")
  ElseIf asValue == "SCVNumCVPreyDevoured"
    MCM.SetInfoText("Number of times this actor devoured another and subdued them by engulfing them.")
  ElseIf asValue == "SCVNumHumansDevoured"
    MCM.SetInfoText("Number of times this actor devoured humans and subdued them using any method.")
  ElseIf asValue == "SCVNumDragonsDevoured"
    MCM.SetInfoText("Number of times this actor devoured dragons and subdued them using any method.")
  ElseIf asValue == "SCVNumDwarvenDevoured"
    MCM.SetInfoText("Number of times this actor devoured dwarven and subdued them using any method.")
  ElseIf asValue == "SCVNumGhostsDevoured"
    MCM.SetInfoText("Number of times this actor devoured ghosts and subdued them using any method.")
  ElseIf asValue == "SCVNumDaedraDevoured"
    MCM.SetInfoText("Number of times this actor devoured daedra and subdued them using any method.")
  ElseIf asValue == "SCVNumUndeadDevoured"
    MCM.SetInfoText("Number of times this actor devoured undead and subdued them using any method.")
  ElseIf asValue == "SCVNumImportantDevoured"
    MCM.SetInfoText("Number of times this actor devoured VIPs (Very Important Prey) and subdued them using any method.")
  EndIf
EndFunction

;UIE Functions *****************************************************************
Function openActorMainMenu(Actor akTarget = None, Int aiMode = 0)
EndFunction

Function addUIEActorStats(Actor akTarget, UIListMenu UIList, Int JA_OptionList, Int aiMode = 0)
  Int TargetData = getTargetData(akTarget)
  String SKey = _getStrKey()
  Bool DEnable = SCXSet.DebugEnable

  Int JM_PreyCounts = Struggling.getPreyCounts(akTarget, TargetData)
  If DEnable
    UIList.AddEntryItem("Edit Resistance Level: " + getVoreLevel(akTarget, "Resistance", False, TargetData))
    JArray.addStr(JA_OptionList, SKey + ".SCVEditResLevel")

  Else
    UIList.AddEntryItem("Resistance Vore Level: " + getVoreLevel(akTarget, "Resistance", True, TargetData))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowResLevel")

  EndIf
  UIList.AddEntryItem("Resistance Vore EXP: " + getVoreEXP(akTarget, "Resistance", TargetData))
  JArray.addStr(JA_OptionList, SKey + ".SCVShowResEXP")


  Bool isPred
  Bool isOVPred = isOVPred(akTarget, TargetData)
  If (isOVPred && isOVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      UIList.AddEntryItem("Set Is Oral Pred: " + isOVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVEditOVPredStatus")

      UIList.AddEntryItem("Edit Oral Vore Level: " + getVoreLevel(akTarget, "Oral", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditOVLevel")

      UIList.AddEntryItem("Edit Extra Oral Vore Level: " + getVoreLevel(akTarget, "Oral", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditOVLevelExtra")

    Else
      UIList.AddEntryItem("Is Oral Pred: " + isOVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVShowOVPredStatus")

      UIList.AddEntryItem("Oral Vore Level: " + getVoreLevel(akTarget, "Oral", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowOVLevel")

      UIList.AddEntryItem("Oral Vore Level Extra: " + getVoreLevel(akTarget, "Oral", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowOVLevelExtra")

    EndIf
    UIList.AddEntryItem("Oral Vore EXP: " + getVoreEXP(akTarget, "Oral", TargetData))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowOVEXP")

    UIList.AddEntryItem("Number Oral Prey: " + JMap.getInt(JM_PreyCounts, "Oral"))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowNumOVPrey")

    Int ParentEntry = UIList.AddEntryItem("Show Oral Prey")
    JArray.addStr(JA_OptionList, SKey + ".SCVShowOVPrey")

    Int JF_Prey = Struggling.getPreyList(akTarget, "Oral", TargetData)
    Int i = 0
    Int NumPrey = JFormMap.count(JF_Prey)
    While i < NumPrey
      Form PreyForm = JFormMap.getNthKey(JF_Prey, i)
      UIList.AddEntryItem(Struggling.getItemListDesc(PreyForm, JFormMap.getObj(JF_Prey, PreyForm)), ParentEntry, ParentEntry, False)
      JArray.addStr(JA_OptionList, SKey + ".SCVShowOVPrey-" + i)
      i += 1
    EndWhile
  EndIf

  Bool isAVPred = isAVPred(akTarget, TargetData)
  If (isAVPred && isAVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      UIList.AddEntryItem("Set Is Anal Pred: " + isAVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVEditAVPredStatus")

      UIList.AddEntryItem("Edit Anal Vore Level: " + getVoreLevel(akTarget, "Anal", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditAVLevel")

      UIList.AddEntryItem("Edit Extra Anal Vore Level: " + getVoreLevel(akTarget, "Anal", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditAVLevelExtra")

    Else
      UIList.AddEntryItem("Is Anal Pred: " + isAVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVShowAVPredStatus")

      UIList.AddEntryItem("Anal Vore Level: " + getVoreLevel(akTarget, "Anal", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowAVLevel")

      UIList.AddEntryItem("Anal Vore Level Extra: " + getVoreLevel(akTarget, "Anal", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowAVLevelExtra")

    EndIf
    UIList.AddEntryItem("Anal Vore EXP: " + getVoreEXP(akTarget, "Anal", TargetData))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowAVEXP")

    UIList.AddEntryItem("Number Anal Prey: " + JMap.getInt(JM_PreyCounts, "Anal"))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowNumAVPrey")

    Int ParentEntry = UIList.AddEntryItem("Show Anal Prey", entryHasChildren = True)
    JArray.addStr(JA_OptionList, SKey + ".SCVShowAVPrey")

    Int JF_Prey = Struggling.getPreyList(akTarget, "Anal", TargetData)
    Int i = 0
    Int NumPrey = JFormMap.count(JF_Prey)
    While i < NumPrey
      Form PreyForm = JFormMap.getNthKey(JF_Prey, i)
      UIList.AddEntryItem(Struggling.getItemListDesc(PreyForm, JFormMap.getObj(JF_Prey, PreyForm)), ParentEntry, ParentEntry, False)
      JArray.addStr(JA_OptionList, SKey + ".SCVShowAVPrey-" + i)
      i += 1
    EndWhile
  EndIf

  Bool isUVPred = isUVPred(akTarget, TargetData)
  If (isUVPred && isUVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      UIList.AddEntryItem("Set Is Unbirth Pred: " + isUVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVEditUVPredStatus")

      UIList.AddEntryItem("Edit Unbirth Vore Level: " + getVoreLevel(akTarget, "Unbirth", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditUVLevel")

      UIList.AddEntryItem("Edit Extra Unbirth Vore Level: " + getVoreLevel(akTarget, "Unbirth", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditUVLevelExtra")

    Else
      UIList.AddEntryItem("Is Unbirth Pred: " + isUVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVShowUVPredStatus")

      UIList.AddEntryItem("Unbirth Vore Level: " + getVoreLevel(akTarget, "Unbirth", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowUVLevel")

      UIList.AddEntryItem("Unbirth Vore Level Extra: " + getVoreLevel(akTarget, "Unbirth", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowUVLevelExtra")

    EndIf
    UIList.AddEntryItem("Unbirth Vore EXP: " + getVoreEXP(akTarget, "Unbirth", TargetData))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowUVEXP")

    UIList.AddEntryItem("Number Unbirth Prey: " + JMap.getInt(JM_PreyCounts, "Unbirth"))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowNumUVPrey")

    Int ParentEntry = UIList.AddEntryItem("Show Unbirth Prey", entryHasChildren = True)
    JArray.addStr(JA_OptionList, SKey + ".SCVShowUVPrey")

    Int JF_Prey = Struggling.getPreyList(akTarget, "Unbirth", TargetData)
    Int i = 0
    Int NumPrey = JFormMap.count(JF_Prey)
    While i < NumPrey
      Form PreyForm = JFormMap.getNthKey(JF_Prey, i)
      UIList.AddEntryItem(Struggling.getItemListDesc(PreyForm, JFormMap.getObj(JF_Prey, PreyForm)), ParentEntry, ParentEntry, False)
      JArray.addStr(JA_OptionList, SKey + ".SCVShowUVPrey-" + i)
      i += 1
    EndWhile
  EndIf

  Bool isCVPred = isCVPred(akTarget, TargetData)
  If (isCVPred && isCVPred(PlayerRef)) || DEnable ;Prevents players from viewing stats if they haven't discovered it yet.
    If DEnable
      UIList.AddEntryItem("Set Is Cock Pred: " + isCVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVEditCVPredStatus")

      UIList.AddEntryItem("Edit Cock Vore Level: " + getVoreLevel(akTarget, "Cock", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditCVLevel")

      UIList.AddEntryItem("Edit Extra Cock Vore Level: " + getVoreLevel(akTarget, "Cock", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVEditCVLevelExtra")

    Else
      UIList.AddEntryItem("Is Cock Pred: " + isCVPred)
      JArray.addStr(JA_OptionList, SKey + "SCVShowCVPredStatus")

      UIList.AddEntryItem("Cock Vore Level: " + getVoreLevel(akTarget, "Cock", False, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowUVLevel")

      UIList.AddEntryItem("Cock Vore Level Extra: " + getVoreLevel(akTarget, "Cock", True, TargetData))
      JArray.addStr(JA_OptionList, SKey + ".SCVShowCVLevelExtra")

    EndIf
    UIList.AddEntryItem("Cock Vore EXP: " + getVoreEXP(akTarget, "Cock", TargetData))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowCVEXP")

    UIList.AddEntryItem("Number Cock Prey: " + JMap.getInt(JM_PreyCounts, "Cock"))
    JArray.addStr(JA_OptionList, SKey + ".SCVShowNumCVPrey")

    Int ParentEntry = UIList.AddEntryItem("Show Cock Prey: ", entryHasChildren = True)
    JArray.addStr(JA_OptionList, SKey + ".SCVShowCVPrey")

    Int JF_Prey = Struggling.getPreyList(akTarget, "Cock", TargetData)
    Int i = 0
    Int NumPrey = JFormMap.count(JF_Prey)
    While i < NumPrey
      Form PreyForm = JFormMap.getNthKey(JF_Prey, i)
      UIList.AddEntryItem(Struggling.getItemListDesc(PreyForm, JFormMap.getObj(JF_Prey, PreyForm)), ParentEntry, ParentEntry, False)
      JArray.addStr(JA_OptionList, SKey + ".SCVShowCVPrey-" + i)
      i += 1
    EndWhile
  EndIf
EndFunction

Bool Function handleUIEStatFromList(Actor akTarget, String asValue)
  Int TargetData = getTargetData(akTarget)
  If asValue == "SCVEditResLevel"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new resistance level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Resistance", Result, False, TargetData)
    Return True
  ElseIf asValue == "SCVShowResLevel"
    Debug.MessageBox("This actor's experience in dealing with predators.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowResEXP"
    Debug.MessageBox("Word")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowResLevel"
    Debug.MessageBox("Accumulated points towards the next resistance level.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVEditOVPredStatus"
    togOVPred(akTarget, TargetData)
    Debug.MessageBox("Toggled oral predator status. Oral Predator = " + isOVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
    Return True
  ElseIf asValue == "SCVEditOVLevel"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new oral vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Oral", Result, False, TargetData)
    Return True
  ElseIf asValue == "SCVEditOVLevelExtra"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new extra oral vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Oral", Result, True, TargetData)
    Return True
  ElseIf asValue == "SCVShowOVPredStatus"
    Debug.MessageBox("Is this actor an oral predator? " + isOVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowOVLevel"
    Debug.MessageBox("This actor's learned experience in swallowing others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowOVLevelExtra"
    Debug.MessageBox("This actor's obtained experience in swallowing others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowOVEXP"
    Debug.MessageBox("Accumulated points towards the next oral vore level.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowNumOVPrey"
    Debug.MessageBox("Number of actors swallowed and still struggling.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVEditAVPredStatus"
    togAVPred(akTarget, TargetData)
    Debug.MessageBox("Toggled anal predator status. Anal Predator = " + isAVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
    Return True
  ElseIf asValue == "SCVEditAVLevel"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new anal vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Anal", Result, False, TargetData)
    Return True
  ElseIf asValue == "SCVEditAVLevelExtra"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new extra anal vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Anal", Result, True, TargetData)
    Return True
  ElseIf asValue == "SCVShowAVPredStatus"
    Debug.MessageBox("Is this actor an anal predator? " + isAVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowAVLevel"
    Debug.MessageBox("This actor's learned experience in taking in others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowAVLevelExtra"
    Debug.MessageBox("This actor's obtained experience in taking in others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowAVEXP"
    Debug.MessageBox("Accumulated points towards the next anal vore level.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowNumAVPrey"
    Debug.MessageBox("Number of actors taken in and still struggling.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVEditUVPredStatus"
    togUVPred(akTarget, TargetData)
    Debug.MessageBox("Toggled unbirthing predator status. Unbirth Predator = " + isUVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
    Return True
  ElseIf asValue == "SCVEditUVLevel"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new unbirth vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Unbirth", Result, False, TargetData)
    Return True
  ElseIf asValue == "SCVEditUVLevelExtra"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new extra unbirth vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Unbirth", Result, True, TargetData)
    Return True
  ElseIf asValue == "SCVShowUVPredStatus"
    Debug.MessageBox("Is this actor an unbirthing predator? " + isUVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowUVLevel"
    Debug.MessageBox("This actor's learned experience in unbirthing others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowUVLevelExtra"
    Debug.MessageBox("This actor's obtained experience in unbirthing others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowUVEXP"
    Debug.MessageBox("Accumulated points towards the next unbirth vore level.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowNumUVPrey"
    Debug.MessageBox("Number of actors unbirthed and still struggling.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVEditCVPredStatus"
    togCVPred(akTarget, TargetData)
    Debug.MessageBox("Toggled cock predator status. Cock Predator = " + isCVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
    Return True
  ElseIf asValue == "SCVEditCVLevel"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new cock vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Cock", Result, False, TargetData)
    Return True
  ElseIf asValue == "SCVEditCVLevelExtra"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new extra cock vore level here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    setVoreLevel(akTarget, "Cock", Result, True, TargetData)
    Return True
  ElseIf asValue == "SCVShowCVPredStatus"
    Debug.MessageBox("Is this actor an Cock Predator? " + isCVPred(akTarget, TargetData) as String)
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowCVLevel"
    Debug.MessageBox("This actor's learned experience in engulfing others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowCVLevelExtra"
    Debug.MessageBox("This actor's obtained experience in engulfing others.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowCVEXP"
    Debug.MessageBox("Accumulated points towards the next cock vore level.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVShowNumCVPrey"
    Debug.MessageBox("Number of actors engulfed and still struggling.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumAvoidedVore"
    Debug.MessageBox("Number of times this actor avoided being eaten.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumStokesOfLuck"
    Debug.MessageBox("Number of times this actor had very lucky breaks.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumDragonGems"
    Debug.MessageBox("Number of times this actor used a very rare dragon gem.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumAllPreyDevoured"
    Debug.MessageBox("Number of times this actor devoured another and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumOVPreyDevoured"
    Debug.MessageBox("Number of times this actor devoured another and subdued them by swallowing them.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumAVPreyDevoured"
    Debug.MessageBox("Number of times this actor devoured another and subdued them by taking them in.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumUVPreyDevoured"
    Debug.MessageBox("Number of times this actor devoured another and subdued them by unbirthing them.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumCVPreyDevoured"
    Debug.MessageBox("Number of times this actor devoured another and subdued them by engulfing them.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumHumansDevoured"
    Debug.MessageBox("Number of times this actor devoured humans and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumDragonsDevoured"
    Debug.MessageBox("Number of times this actor devoured dragons and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumDwarvenDevoured"
    Debug.MessageBox("Number of times this actor devoured dwarven and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumGhostsDevoured"
    Debug.MessageBox("Number of times this actor devoured ghosts and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumDaedraDevoured"
    Debug.MessageBox("Number of times this actor devoured daedra and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumUndeadDevoured"
    Debug.MessageBox("Number of times this actor devoured undead and subdued them using any method.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCVNumImportantDevoured"
    Debug.MessageBox("Number of times this actor devoured VIPs (Very Important Prey) and subdued them using any method.")
    Utility.Wait(0.1)
  Else
    String[] IndexList = StringUtil.Split(asValue, "-")
    String Type = IndexList[0]
    If Type == "SCVShowOVPrey"
      Int JF_PreyList = Struggling.getPreyList(akTarget, "Oral", TargetData)
      Form Prey = JFormMap.getNthKey(JF_PreyList, IndexList[1] as Int)
      If Prey
        Debug.MessageBox("Oral Prey Name = " + nameGet(Prey) + ".\n PreyEnergy = " + getPreyEnergy(Prey as Actor))
        Utility.Wait(0.1)
      EndIf
    ElseIf Type == "SCVShowAVPrey"
      Int JF_PreyList = Struggling.getPreyList(akTarget, "Anal", TargetData)
      Form Prey = JFormMap.getNthKey(JF_PreyList, IndexList[1] as Int)
      If Prey
        Debug.MessageBox("Anal Prey Name = " + nameGet(Prey) + ".\n PreyEnergy = " + getPreyEnergy(Prey as Actor))
        Utility.Wait(0.1)
      EndIf
    ElseIf Type == "SCVShowUVPrey"
      Int JF_PreyList = Struggling.getPreyList(akTarget, "Unbirth", TargetData)
      Form Prey = JFormMap.getNthKey(JF_PreyList, IndexList[1] as Int)
      If Prey
        Debug.MessageBox("Unbirth Prey Name = " + nameGet(Prey) + ".\n PreyEnergy = " + getPreyEnergy(Prey as Actor))
        Utility.Wait(0.1)
      EndIf
    ElseIf Type == "SCVShowCVPrey"
      Int JF_PreyList = Struggling.getPreyList(akTarget, "Cock", TargetData)
      Form Prey = JFormMap.getNthKey(JF_PreyList, IndexList[1] as Int)
      If Prey
        Debug.MessageBox("Cock Prey Name = " + nameGet(Prey) + ".\n PreyEnergy = " + getPreyEnergy(Prey as Actor))
        Utility.Wait(0.1)
      EndIf
    EndIf
  EndIf
  Return False
EndFunction

Int Function getPreyEnergy(Actor akTarget)
  If StruggleSorcery.getPerkLevel(akTarget) as Bool
    Return akTarget.GetActorValue("Stamina") as Int + akTarget.getActorValue("Magicka") as Int
  Else
    Return akTarget.GetActorValue("Stamina") as Int
  EndIf
EndFunction


Function debugMaxPredStats(Actor akTarget)
	{Debug function, meant to check high-level pred interactions}
	;/Note("Maxing Pred Stats")
	Int TargetData = getTargetData(akTarget, True)
	JMap.setInt(TargetData, "SCV_IsOVPred", 1)
	JMap.setInt(TargetData, "SCV_OVLevel", 100)
	JMap.setInt(TargetData, "SCV_OVLevelExtra", 100)
  JMap.setInt(TargetData, "SCV_IsAVPred", 1)
  JMap.setInt(TargetData, "SCV_AVLevel", 100)
  JMap.setInt(TargetData, "SCV_AVLevelExtra", 100)
	JMap.setFlt(TargetData, "STBase", 5000)
  takeUpPerks(akTarget, "SCLRoomForMore", 5)
  takeUpPerks(akTarget, "SCLHeavyBurden", 5)
  takeUpPerks(akTarget, "SCLStoredLimitUp", 5)
  takeUpPerks(akTarget, "SCLAllowOverflow", 1)
  takeUpPerks(akTarget, "SCV_IntenseHunger", 3)
  takeUpPerks(akTarget, "SCV_MetalMuncher", 3)
  takeUpPerks(akTarget, "SCV_FollowerofNamira", 3)
  takeUpPerks(akTarget, "SCV_DragonDevourer", 3)
  takeUpPerks(akTarget, "SCV_SpiritSwallower", 3)
  takeUpPerks(akTarget, "SCV_ExpiredEpicurian", 3)
  takeUpPerks(akTarget, "SCV_DaedraDieter", 3)
  takeUpPerks(akTarget, "SCV_Stalker", 3)
  takeUpPerks(akTarget, "SCV_RemoveLimits", 1)
  takeUpPerks(akTarget, "SCV_Constriction", 3)
  takeUpPerks(akTarget, "SCA_BasementStorage", 1)
  JMap.setInt(TargetData, "WF_BasementStorage", JMap.getInt(TargetData, "WF_BasementStorage") + 30)
  checkPredAbilities(akTarget)
  ;setAggression(akTarget, 5)
/;
EndFunction
;Get Functions *****************************************************************
Float Function getProxy(Actor akTarget, String asAV, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float Proxy =  JMap.getFlt(TargetData, asAV + "Proxy")
  If Proxy < 0
    Proxy = 0
    JMap.setFlt(TargetData, asAV + "Proxy", 0)
  EndIf
  Return Proxy
EndFunction

Float Function getProxyBase(Actor akTarget, String asAV, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float ProxyBase =  JMap.getFlt(TargetData, asAV + "ProxyBase")
  If ProxyBase < 0
    ProxyBase = 0
    JMap.setFlt(TargetData, asAV + "ProxyBase", 0)
  EndIf
  Return ProxyBase
EndFunction

Float Function getProxyPercent(Actor akTarget, String asAV, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float Proxy = getProxy(akTarget, asAV, TargetData)
  Float AVBase = getProxyBase(akTarget, asAV, TargetData)
  If AVBase > 0
    Return Proxy / AVBase
  Else
    Return 0
  EndIf
EndFunction

Function setProxy(Actor akTarget, String asAV, Float aiValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If aiValue < 0
    aiValue = 0
  EndIf
  JMap.setFlt(TargetData, asAV + "Proxy", aiValue)
EndFunction

Function setProxyBase(Actor akTarget, String asAV, Float aiValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If aiValue < 0
    aiValue = 0
  EndIf
  JMap.setFlt(TargetData, asAV + "ProxyBase", aiValue)
EndFunction

Function modProxy(Actor akTarget, String asAV, Float aiValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float Proxy = getProxy(akTarget, asAV, TargetData)
  Proxy += aiValue
  If Proxy < 0
    Proxy = 0
  EndIf
  JMap.setFlt(TargetData, asAV + "Proxy", Proxy)
EndFunction

Function modProxyBase(Actor akTarget, String asAV, Float aiValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float Proxy = getProxyBase(akTarget, asAV, TargetData)
  Proxy += aiValue
  If Proxy < 0
    Proxy = 0
  EndIf
  JMap.setFlt(TargetData, asAV + "ProxyBase", Proxy)
EndFunction

Bool Function isInPred(Actor akPrey, Int aiTargetData = 0)
	{Basically checks to see if there's an actor in the tracking data}
  Int TargetData = getData(akPrey, aiTargetData)
  Return getPred(akPrey, TargetData) as Bool
EndFunction

Actor Function getPred(Actor akPrey, Int aiTargetData = 0)
  Int TargetData = getData(akPrey, aiTargetData)
  Int JM_TrackingData = JMap.getObj(TargetData, "SCLTrackingData")
  Return JMap.getForm(JM_TrackingData, "SCV_Pred") as Actor
EndFunction

Int Function getDamageTier(Actor akTarget)
  Int i = SCVSet.DamageArray.Length - 1
  While i
    If akTarget.HasMagicEffect(SCVSet.DamageArray[i].GetNthEffectMagicEffect(0))
      Return i
    EndIf
    i -= 1
  EndWhile
  Return 0
EndFunction

Int Function getFrenzyLevel(Actor akTarget)
  Return 0
  ;/If akTarget.HasMagicEffect(SCVSet.SCV_FrenzyLevel2)
    Return 2
  ElseIf akTarget.HasMagicEffect(SCVSet.SCV_FrenzyLevel1)
    Return 1
  Else
    Return 0
  EndIf/;
EndFunction

Bool Function isBeingHurt(Actor akTarget)
  Return akTarget.HasMagicEffectWithKeyword(SCVSet.SCV_DamageKeyword)
EndFunction

Int Function getNumStrugglePrey(Actor akPred, Int aiTargetData = 0)
  {Returns number of prey currently struggling. Will not get already finished prey}
  Int TargetData = getData(akPred, aiTargetData)
  Int JF_Contents = getContents(akPred, 8, aiTargetData)
  Int NumStruggle = JFormMap.count(JF_Contents)
  Return NumStruggle
EndFunction

Bool Function hasStrugglePrey(Actor akPred, Int aiTargetData = 0)
  Int TargetData = getData(akPred, aiTargetData)
  Int JF_Contents = getContents(akPred, 8, aiTargetData)
  Return !JValue.empty(JF_Contents)
EndFunction

Bool Function hasOVStrugglePrey(Actor akPred, Int aiTargetData = 0)
  {Returns if the actor has prey taken by oral vore}
  Int TargetData = getData(akPred, aiTargetData)
  Int JF_Contents = getContents(akPred, 8, TargetData)
  Form ItemKey = JFormMap.nextKey(JF_Contents)
  While ItemKey
    Int JM_Entry = JFormMap.getObj(JF_Contents, ItemKey)
    Int ItemType = JMap.getInt(JM_Entry, "StoredItemType")
    If ItemType == 1 || ItemType == 2
      Return True
    EndIf
    ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
  EndWhile
  Return False
EndFunction

Bool Function hasAVStrugglePrey(Actor akPred, Int aiTargetData = 0)
  Int TargetData = getData(akPred, aiTargetData)
  Int JF_Contents = getContents(akPred, 8, TargetData)
  Form ItemKey = JFormMap.nextKey(JF_Contents)
  While ItemKey
    Int JM_Entry = JFormMap.getObj(JF_Contents, ItemKey)
    Int ItemType = JMap.getInt(JM_Entry, "StoredItemType")
    If ItemType == 3 || ItemType == 4
      Return True
    EndIf
    ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
  EndWhile
  Return False
EndFunction

Bool Function hasPrey(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If hasStrugglePrey(akTarget, TargetData) || hasPreyType(akTarget, 1, TargetData) \
    || hasPreyType(akTarget, 2, TargetData) || hasPreyType(akTarget, 3) || hasPreyType(akTarget, 4)
    ;Add More Prey locations here as they are added.
    Return True
  EndIf
  Return False
EndFunction

Int Function getNumPrey(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int NumPrey = getNumStrugglePrey(akTarget, TargetData)
  NumPrey += getNumPreyType(akTarget, 1, TargetData)
  NumPrey += getNumPreyType(akTarget, 2, TargetData)
  NumPrey += getNumPreyType(akTarget, 3, TargetData)
  NumPrey += getNumPreyType(akTarget, 4, TargetData)
  ;NumPrey += getNumPreyType(akTarget, 6, TargetData)
  ;NumPrey += getNumPreyType(akTarget, 7, TargetData)

  ;Add more prey functions here.
  Return NumPrey
EndFunction

Int Function getNumPreyType(Actor akTarget, Int aiItemType, Int aiTargetData = 0)
  {Returns number of actors in specified container}
  Int TargetData = getData(akTarget, aiTargetData)
  Int JF_Contents = getContents(akTarget, aiItemType, TargetData)
  Form FormKey = JFormMap.nextKey(JF_Contents)
  Int NumPrey
  While FormKey
    If FormKey as Actor
      NumPrey += 1
    EndIf
    FormKey = JFormMap.nextKey(JF_Contents, FormKey)
  EndWhile
  Return NumPrey
EndFunction

Bool Function hasPreyType(Actor akTarget, Int aiItemType, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int JF_Contents = getContents(akTarget, aiItemType, TargetData)
  Form FormKey = JFormMap.nextKey(JF_Contents)
  While FormKey
    If FormKey as Actor
      Return True
    EndIf
    FormKey = JFormMap.nextKey(JF_Contents, FormKey)
  EndWhile
  Return False
EndFunction

Bool Function checkPredAbilities(Actor akTarget, Int aiTargetData = 0)
  {Checks to see if the actor is a predator, and adds the spells they need
  Returns if they are a predator}
  Int TargetData = getData(akTarget, aiTargetData)
  Bool isPred = False

  If isOVPred(akTarget, TargetData)
    akTarget.AddSpell(SCVSet.SCV_SwallowLethal, False)
    akTarget.AddSpell(SCVSet.SCV_SwallowNonLethal, False)
    akTarget.AddSpell(SCVSet.SCV_OVPredMarker, True)
    isPred = True
  Else
    akTarget.RemoveSpell(SCVSet.SCV_SwallowLethal)
    akTarget.RemoveSpell(SCVSet.SCV_SwallowNonLethal)
    akTarget.removespell(SCVSet.SCV_OVPredMarker)

  EndIf

  If isAVPred(akTarget, TargetData)
    akTarget.AddSpell(SCVSet.SCV_TakeInLethal, False)
    akTarget.AddSpell(SCVSet.SCV_TakeInNonLethal, False)
    akTarget.AddSpell(SCVSet.SCV_AVPredMarker, True)

    isPred = True
  Else
    akTarget.RemoveSpell(SCVSet.SCV_TakeInLethal)
    akTarget.RemoveSpell(SCVSet.SCV_TakeInNonLethal)
    akTarget.removespell(SCVSet.SCV_AVPredMarker)
  EndIf

  ;/If isPVPred(akTarget, TargetData)
    akTarget.AddSpell(SCVSet.SCV_UnPassLethal, False)
    akTarget.AddSpell(SCVSet.SCV_UnPassNonLethal, False)
    Int Level = calculatePredLevel(akTarget, "PV", TargetData)
    Int CurrentLevel = getCurrentPerkLevel(akTarget, "SCV_PVPredLevel")
    If Level != CurrentLevel
      akTarget.RemoveSpell(getPerkSpell("SCV_PVPredLevel", CurrentLevel))
      akTarget.AddSpell(getPerkSpell("SCV_PVPredLevel", Level), False)
    EndIf
    isPred = True
  EndIf/;
  If isPred
    akTarget.AddSpell(SCVSet.SCV_PredMarker, True)
  Else
    akTarget.RemoveSpell(SCVSet.SCV_PredMarker)
  EndIf
  Return isPred
  ;Add other pred types here
EndFunction

Bool Function isPreyProtected(Actor akTarget, Int aiTargetData = 0)
  Return akTarget.IsInFaction(SCVSet.SCV_FACT_PreyProtected)
  ;/Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_isPreyProtected") != 0/;
EndFunction

Function setPreyProtected(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  If isPreyProtected(akTarget, aiTargetData)
    If !abValue
      akTarget.RemoveFromFaction(SCVSet.SCV_FACT_PreyProtected)
    EndIf
  Else
    If abValue
      akTarget.AddToFaction(SCVSet.SCV_FACT_PreyProtected)
    EndIf
  EndIf
EndFunction

Bool Function isPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If isOVPred(akTarget, TargetData) || isAVPred(akTarget, TargetData)
    Return True
  Else
    Return False
  EndIf
EndFunction

Bool Function isOVPred(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Return JMap.getInt(aiTargetData, "SCV_IsOVPred") != 0
EndFunction

Bool Function isAVPred(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Return JMap.getInt(aiTargetData, "SCV_IsAVPred") != 0
EndFunction

Bool Function isUVPred(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Return JMap.getInt(aiTargetData, "SCV_IsUVPred") != 0
EndFunction

Bool Function isCVPred(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Return JMap.getInt(aiTargetData, "SCV_IsCVPred") != 0
EndFunction

Function togOVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If isOVPred(akTarget, aiTargetData)
    JMap.setInt(TargetData, "SCV_IsOVPred", 0)
  Else
    JMap.setInt(TargetData, "SCV_IsOVPred", 1)
  EndIf
EndFunction

Function togAVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If isAVPred(akTarget, aiTargetData)
    JMap.setInt(TargetData, "SCV_IsAVPred", 0)
  Else
    JMap.setInt(TargetData, "SCV_IsAVPred", 1)
  EndIf
EndFunction

Function togUVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If isUVPred(akTarget, aiTargetData)
    JMap.setInt(TargetData, "SCV_IsUVPred", 0)
  Else
    JMap.setInt(TargetData, "SCV_IsUVPred", 1)
  EndIf
EndFunction

Function togCVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If isCVPred(akTarget, aiTargetData)
    JMap.setInt(TargetData, "SCV_IsCVPred", 0)
  Else
    JMap.setInt(TargetData, "SCV_IsCVPred", 1)
  EndIf
EndFunction

Function setOVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsOVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsOVPred", 0)
  EndIf
EndFunction

Function setAVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsAVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsAVPred", 0)
  EndIf
EndFunction

Function setUVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsUVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsUVPred", 0)
  EndIf
EndFunction

Function setCVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsCVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsCVPred", 0)
  EndIf
EndFunction

Bool Function isOVPredBlocked(Actor akTarget, Int aiTargetData = 0)
  Return akTarget.IsInFaction(SCVSet.SCV_FACT_OVPredBlocked)
  ;/Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_IsOVPredBlocked") != 0/;
EndFunction

Bool Function isAVPredBlocked(Actor akTarget, Int aiTargetData = 0)
  Return akTarget.IsInFaction(SCVSet.SCV_FACT_AVPredBlocked)
  ;/Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_IsAVPredBlocked") != 0/;
EndFunction

Bool Function isPVPredBlocked(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_IsPVPredBlocked") != 0
EndFunction

Function setOVPredBlocked(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  If isOVPredBlocked(akTarget, aiTargetData)
    If !abValue
      akTarget.RemoveFromFaction(SCVSet.SCV_FACT_OVPredBlocked)
    EndIf
  Else
    If abValue
      akTarget.AddToFaction(SCVSet.SCV_FACT_OVPredBlocked)
    EndIf
  EndIf
  ;/Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsOVPredBlocked", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsOVPredBlocked", 0)
  EndIf/;
EndFunction

Function setAVPredBlocked(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  If isAVPredBlocked(akTarget, aiTargetData)
    If !abValue
      akTarget.RemoveFromFaction(SCVSet.SCV_FACT_AVPredBlocked)
    EndIf
  Else
    If abValue
      akTarget.AddToFaction(SCVSet.SCV_FACT_AVPredBlocked)
    EndIf
  EndIf
  ;/Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsAVPredBlocked", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsAVPredBlocked", 0)
  EndIf/;
EndFunction

;/Function setPVPredBlocked(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_IsPVPredBlocked", 1)
  Else
    JMap.setInt(TargetData, "SCV_IsPVPredBlocked", 0)
  EndIf
EndFunction/;

Bool Function isFriendlyOVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_isFriendlyOVPred") != 0
EndFunction

Bool Function isFriendlyAVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_isFriendlyAVPred") != 0
EndFunction

Bool Function isFriendlyPVPred(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_isFriendlyPVPred") != 0
EndFunction

Function setFriendlyOVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_isFriendlyOVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_isFriendlyOVPred", 0)
  EndIf
EndFunction

Function setFriendlyAVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_isFriendlyAVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_isFriendlyAVPred", 0)
  EndIf
EndFunction

Function setFriendlyPVPred(ACtor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_isFriendlyPVPred", 1)
  Else
    JMap.setInt(TargetData, "SCV_isFriendlyPVPred", 0)
  EndIf
EndFunction

Bool Function allowsFriendlyOV(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_allowsFriendlyOV") != 0
EndFunction

Bool Function allowsFriendlyAV(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_allowsFriendlyAV") != 0
EndFunction

Bool Function allowsFriendlyPV(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_allowsFriendlyPV") != 0
EndFunction

Function setAllowsFriendlyOV(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_allowsFriendlyOV", 1)
  Else
    JMap.setInt(TargetData, "SCV_allowsFriendlyOV", 0)
  EndIf
EndFunction

Function setAllowsFriendlyAV(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_allowsFriendlyAV", 1)
  Else
    JMap.setInt(TargetData, "SCV_allowsFriendlyAV", 0)
  EndIf
EndFunction

Function setAllowsFriendlyPV(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_allowsFriendlyPV", 1)
  Else
    JMap.setInt(TargetData, "SCV_allowsFriendlyPV", 0)
  EndIf
EndFunction

Bool Function allowsFriendlyLethalOV(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_allowsFriendlyLethalOV") != 0
EndFunction

Bool Function allowsFriendlyLethalAV(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_allowsFriendlyLethalAV") != 0
EndFunction

Bool Function allowsFriendlyLethalPV(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_allowsFriendlyLethalPV") != 0
EndFunction

Function setAllowsFriendlyLethalOV(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_allowsFriendlyLethalOV", 1)
  Else
    JMap.setInt(TargetData, "SCV_allowsFriendlyLethalOV", 0)
  EndIf
EndFunction

Function setAllowsFriendlyLethalAV(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_allowsFriendlyLethalAV", 1)
  Else
    JMap.setInt(TargetData, "SCV_allowsFriendlyLethalAV", 0)
  EndIf
EndFunction

Function setAllowsFriendlyLethalPV(Actor akTarget, Bool abValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If abValue
    JMap.setInt(TargetData, "SCV_allowsFriendlyLethalPV", 1)
  Else
    JMap.setInt(TargetData, "SCV_allowsFriendlyLethalPV", 0)
  EndIf
EndFunction

Int Function calculatePredLevel(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If isOVPred(akTarget, TargetData) || isAVPred(akTarget, TargetData) || isUVPred(akTarget, TargetData) || isCVPred(akTarget, TargetData)
    Return 1
  Else
    Return 0
  EndIf
EndFunction

;EXP Functions *****************************************************************
Int Function getTotalPredLevel(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int Total = getVoreLevelTotal(akTarget, "Oral", TargetData)
  Total += getVoreLevelTotal(akTarget, "Anal", TargetData)
  Total += getVoreLevelTotal(akTarget, "Unbirth", TargetData)
  Total += getVoreLevelTotal(akTarget, "Cock", TargetData)
  Return Total
EndFunction

;-------------------------------------------------------------------------------
Int Function getVoreLevel(Actor akTarget, String asType, Bool abExtra = False, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  String asKey
  If asType == "Resistance"
    asKey = "SCV_ResLevel"
  ElseIf asType == "Oral"
    asKey = "SCV_OVLevel"
  ElseIf asType == "Anal"
    asKey = "SCV_AVLevel"
  ElseIf asType == "Unbirth"
    asKey = "SCV_UVLevel"
  ElseIf asType == "Cock"
    asKey = "SCV_CVLevel"
  EndIf
  If asKey && abExtra
    asKey += "Extra"
  EndIf
  If asKey
    Return JMap.getInt(TargetData, asKey)
  EndIf
  Return -1
EndFunction

Int Function modVoreLevel(Actor akTarget, String asType, Int aiValue, Bool abExtra = False, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  String asKey
  If asType == "Resistance"
    asKey = "SCV_ResLevel"
  ElseIf asType == "Oral"
    asKey = "SCV_OVLevel"
  ElseIf asType == "Anal"
    asKey = "SCV_AVLevel"
  ElseIf asType == "Unbirth"
    asKey = "SCV_UVLevel"
  ElseIf asType == "Cock"
    asKey = "SCV_CVLevel"
  EndIf
  If asKey && abExtra
    asKey += "Extra"
  EndIf
  If asKey
    JMap.setInt(TargetData, asKey, JMap.getInt(TargetData, asKey) + aiValue)
    Return JMap.getInt(TargetData, asKey)
  EndIf
  Return -1
EndFunction

Function setVoreLevel(Actor akTarget, String asType, Int aiValue, Bool abExtra = False, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  String asKey
  If asType == "Resistance"
    asKey = "SCV_ResLevel"
  ElseIf asType == "Oral"
    asKey = "SCV_OVLevel"
  ElseIf asType == "Anal"
    asKey = "SCV_AVLevel"
  ElseIf asType == "Unbirth"
    asKey = "SCV_UVLevel"
  ElseIf asType == "Cock"
    asKey = "SCV_CVLevel"
  EndIf
  If asKey && abExtra
    asKey += "Extra"
  EndIf
  If asKey
    JMap.setInt(TargetData, asKey, aiValue)
  EndIf
EndFunction

Int Function getVoreLevelTotal(Actor akTarget, String asType, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  String asKey
  If asType == "Resistance"
    asKey = "SCV_ResLevel"
  ElseIf asType == "Oral"
    asKey = "SCV_OVLevel"
  ElseIf asType == "Anal"
    asKey = "SCV_AVLevel"
  ElseIf asType == "Unbirth"
    asKey = "SCV_UVLevel"
  ElseIf asType == "Cock"
    asKey = "SCV_CVLevel"
  EndIf
  If asKey
    Return JMap.getInt(TargetData, asKey) + JMap.getInt(TargetData, asKey + "Extra")
  EndIf
  Return -1
EndFunction

Int Function getVoreEXP(Actor akTarget, String asType, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  String asKey
  If asType == "Resistance"
    asKey = "SCV_ResEXP"
  ElseIf asType == "Oral"
    asKey = "SCV_OVEXP"
  ElseIf asType == "Anal"
    asKey = "SCV_AVEXP"
  ElseIf asType == "Unbirth"
    asKey = "SCV_UVEXP"
  ElseIf asType == "Cock"
    asKey = "SCV_CVEXP"
  EndIf
  If asKey
    Return JMap.getInt(TargetData, asKey)
  EndIf
  Return -1
EndFunction

Function setVoreEXP(Actor akTarget, String asType, Int aiValue, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  String asKey
  If asType == "Resistance"
    asKey = "SCV_ResEXP"
  ElseIf asType == "Oral"
    asKey = "SCV_OVEXP"
  ElseIf asType == "Anal"
    asKey = "SCV_AVEXP"
  ElseIf asType == "Unbirth"
    asKey = "SCV_UVEXP"
  ElseIf asType == "Cock"
    asKey = "SCV_CVEXP"
  EndIf
  If asKey && aiValue >= 0
    JMap.setInt(TargetData, asKey, aiValue)
  EndIf
EndFunction

Bool Function giveVoreExp(Actor akTarget, String asType, Int aiValue, Int aiTargetData = 0)
  {Grants oral vore exp. Returns if the actor leveled up}
  Int TargetData = getData(akTarget, aiTargetData)
  String LevelKey
  String EXPKey
  If asType == "Resistance"
    LevelKey = "SCV_ResLevel"
    EXPKey = "SCV_ResEXP"
  ElseIf asType == "Oral"
    LevelKey = "SCV_OVLevel"
    EXPKey = "SCV_OVEXP"
  ElseIf asType == "Anal"
    LevelKey = "SCV_AVLevel"
    EXPKey = "SCV_AVEXP"
  ElseIf asType == "Unbirth"
    LevelKey = "SCV_UVLevel"
    EXPKey = "SCV_UVEXP"
  ElseIf asType == "Cock"
    LevelKey = "SCV_CVLevel"
    EXPKey = "SCV_CVEXP"
  EndIf
  Int CurrentLevel = JMap.getInt(TargetData, LevelKey)
  JMap.setInt(TargetData, EXPKey, JMap.getInt(TargetData, EXPKey) + aiValue)
  Int NewLevel = updateVoreEXP(akTarget, asType, TargetData)
  Return NewLevel != CurrentLevel
EndFunction

Int Function updateVoreEXP(Actor akTarget, String asType, Int aiTargetData = 0)
	{Returns the current level of the target after leveling up}
  Int TargetData = getData(akTarget, aiTargetData)
  String LevelKey
  String EXPKey
  If asType == "Resistance"
    LevelKey = "SCV_ResLevel"
    EXPKey = "SCV_ResEXP"
  ElseIf asType == "Oral"
    LevelKey = "SCV_OVLevel"
    EXPKey = "SCV_OVEXP"
  ElseIf asType == "Anal"
    LevelKey = "SCV_AVLevel"
    EXPKey = "SCV_AVEXP"
  ElseIf asType == "Unbirth"
    LevelKey = "SCV_UVLevel"
    EXPKey = "SCV_UVEXP"
  ElseIf asType == "Cock"
    LevelKey = "SCV_CVLevel"
    EXPKey = "SCV_CVEXP"
  EndIf
	Int Level = JMap.getInt(TargetData, LevelKey)
	Int EXP = JMap.getInt(TargetData, EXPKey)
	Int Threshold = getVoreEXPThreshold(Level, asType)
	If EXP >= Threshold
		While EXP >= Threshold
			Level += 1
			Exp -= Threshold
      Threshold = getVoreEXPThreshold(Level, asType)
		EndWhile
    JMap.setInt(TargetData, LevelKey, Level)
    JMap.setInt(TargetData, EXPKey, EXP)
  EndIf
  Return Level
EndFunction

Int Function getVoreEXPThreshold(Int aiLevel, String asType)
	Return Math.Ceiling(Math.pow(aiLevel, 2) + 10)
EndFunction

Int Function getAllureLevel(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_Allure")
EndFunction

Function giveAllPreyResExp(Actor akPred, Int aiEXP, Int aiTargetData = 0)
  Int TargetData = getData(akPred, aiTargetData)
  Int JF_Struggle = getContents(akPred, 8, TargetData)
  Actor i = JFormMap.nextKey(JF_Struggle) as Actor
  While i
    giveVoreExp(i, "Resistance", aiEXP)
    i = JFormMap.nextKey(JF_Struggle, i) as Actor
  EndWhile
EndFunction

;Transfer functions

Function transferInventory(Actor akTarget, Actor akSource, String asArchetype)
	{Moves all items from actor's inventory into a contents array}
  SCX_TransferContainer2 Chest = SCXSet.SCX_TransferChest02 as SCX_TransferContainer2
  Chest.TransferArchetype = asArchetype
  Chest.TransferTarget = akTarget
  Chest.akReturn = akTarget
  akSource.RemoveAllItems(Chest, True, True)
EndFunction

Function transferSCLItems(Actor akTarget, Actor akSource, String asArchetype)
  {Moves items stored in actor to target NEED TO WRITE}
  SCX_TransferContainer2 Chest = SCXSet.SCX_TransferChest02 as SCX_TransferContainer2
  Chest.TransferArchetype = asArchetype
  Chest.TransferTarget = akTarget
  Chest.akReturn = akTarget

  Int JM_MainArchList = SCXSet.JM_BaseArchetypes
  String ArchName = JMap.nextKey(JM_MainArchList)
  While ArchName
    SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(JM_MainArchList, ArchName) as SCX_BaseItemArchetypes
    If Arch
      Int JF_ArchContents = Arch.getAllContents(akTarget)
      Form ItemKey = JFormMap.nextKey(JF_ArchContents)
      While ItemKey
        Int JM_ItemEntry = JFormMap.getObj(JF_ArchContents, ItemKey)
        String ItemType = JMap.getInt(JM_ItemEntry, "ItemType")
        String[] TypeInfo = StringUtil.split(ItemType, ".")
        JFormMap.removeKey(getContents(akTarget, TypeInfo[0], TypeInfo[1]), ItemKey)
        If Arch == "Struggling"
          Struggling.addToContents(akTarget, ItemKey as Actor, ItemKey, 8, abMoveNow = False)
        ElseIf ItemKey as SCX_Bundle
          Chest.AddItem((ItemKey as SCX_Bundle).ItemForm, (ItemKey as SCX_Bundle).ItemNum, True)
        Else
          Chest.AddItem(ItemKey, 1, True)
        EndIf
        ItemKey = JFormMap.nextKey(JF_ArchContents, ItemKey)
      EndWhile
    EndIf
    ArchName = JMap.nextKey(JM_MainArchList, ArchName)
  EndWhile
EndFunction

Function updatePredPreyInfo(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
EndFunction

Int Function getCurrentNourish(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCV_AppliedNourishTier")
EndFunction

Actor Function findHighestPred(Actor akTarget)
  {Searches for the pred who ate all other prey, returns akPrey if they are the highest}
	Actor akPrey = akTarget
	Bool Done = False
	While !Done
		Int PreyData = getTargetData(akPrey)
		Actor akPred = JMap.getForm(PreyData, "SCV_Pred") as Actor
		If akPred
			akPrey = akPred
		Else
			Done = True
		EndIf
	EndWhile
	Return akPrey
EndFunction

;/Bool preyHandlingLocked = False
Int Function insertPrey(Actor akPred, Actor akPrey, Int aiItemType, Bool abFriendly, Bool abPlayAnimation = True)
  ;Consider putting these big functions into a mutlithreaded context
  Int PredData = getTargetData(akPred, True)
  Int PreyData = getTargetData(akPrey, True)
  Int JM_PreyEntry
  If preyHandlingLocked
    While preyHandlingLocked
      Utility.WaitMenuMode(0.5)
    EndWhile
  EndIf
  preyHandlingLocked = True
  Notice("Prey insertion commencing. Pred = " + nameGet(akPred) + ", Prey = " + nameGet(akPrey) + ", Item Type = " + aiItemType)
  If SCVSet.SCV_InVoreActionList.HasForm(akPred) || SCVSet.SCV_InVoreActionList.HasForm(akPrey)
    While SCVSet.SCV_InVoreActionList.HasForm(akPred) || SCVSet.SCV_InVoreActionList.HasForm(akPrey)
      Utility.Wait(0.5)
    EndWhile
  EndIf
  (SCVSet.SCV_FollowPred as SCVStayWithMe).DelayUpdate = True
  SCVSet.SCV_InVoreActionList.AddForm(akPred)
  SCVSet.SCV_InVoreActionList.AddForm(akPrey)
  ;Play animation here
  If akPred == PlayerRef
    If (aiItemType == 1 || aiItemType == 2)
      Int Allure = getAllureLevel(akPrey)
      If Allure >= 1
        PlayerThoughtDB(akPred, "SCVPredSwallowPositive")
      ElseIf Allure <= -1
        PlayerThoughtDB(akPred, "SCVPredSwallowNegative")
      Else
        PlayerThoughtDB(akPred, "SCVPredSwallow")
      EndIf
    ElseIf aiItemType == 4 || aiItemType == 6
      PlayerThoughtDB(akPred, "SCVPredTakeIn")
    EndIf
  EndIf

  If aiItemType == 1 || aiItemType == 2
    PlayerThoughtDB(akPrey, "SCVPreySwallowed")
    Debug.Notification(nameGet(akPred) + " is eating " + nameGet(akPrey) + "!")
    akPred.Say(SCVSet.SCV_SwallowSound)
  ElseIf aiItemType == 4 || aiItemType == 6
    PlayerThoughtDB(akPrey, "SCVPreyTakenIn")
    Debug.Notification(nameGet(akPred) + " is taking in " + nameGet(akPrey) + "!")
    akPred.Say(SCVSet.SCV_TakeInSound)
  EndIf

  Int iModType = aiItemType
  If !SCVSet.SCA_Initialized || SCVSet.AVDestinationChoice == 1
    If aiItemType == 4 || aiItemType == 5
      iModType = 1
    ElseIf aiItemType == 6 || aiItemType == 7
      iModType == 2
    EndIf
  EndIf

  If akPrey.isDead() || abFriendly || akPrey.IsUnconscious()
    ;Notice("Prey is willing or incapacitated. Inserting directly into contents.")
    If aiItemType == 1 || aiItemType == 2
      If akPrey == PlayerRef
        JM_PreyEntry = addItem(akPred, akPrey, aiItemType = iModType, abMoveNow = False)
        SCVSet.SCV_FollowPred.ForceRefTo(akPred)
      Else
        JM_PreyEntry = addItem(akPred, akPrey, aiItemType = iModType)
      EndIf
    ElseIf aiItemType == 4 || aiItemType == 6
      If !SCVSet.SCA_Initialized || SCVSet.AVDestinationChoice == 1
        If akPrey == PlayerRef
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = iModType, abMoveNow = False)
          SCVSet.SCV_FollowPred.ForceRefTo(akPred)
        Else
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = iModType)
        EndIf
      Else
        If akPrey == PlayerRef
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = iModType, afDigestValueOverRide = 0, abMoveNow = False)
          SCVSet.SCV_FollowPred.ForceRefTo(akPred)
        Else
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = iModType, afDigestValueOverRide = 0)
        EndIf
        JMap.setFlt(JM_PreyEntry, "StoredDigestValue", genDigestValue(akPrey, True))
      EndIf
    EndIf
  Else
    ;Notice("Prey is struggling. Inserting into struggle contents")
    If aiItemType == 1 || aiItemType == 2
      If akPrey == PlayerRef
        JM_PreyEntry = addItem(akPred, akPrey, aiItemType = 8, abMoveNow = False)
        SCVSet.SCV_FollowPred.ForceRefTo(akPred)
      Else
        JM_PreyEntry = addItem(akPred, akPrey, aiItemType = 8)
      EndIf
      giveOVExp(akPred, getResLevel(akPrey))
    ElseIf aiItemType == 4 || aiItemType == 6
      If !SCVSet.SCA_Initialized || SCVSet.AVDestinationChoice == 1
        If akPrey == PlayerRef
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = 8, abMoveNow = False)
          SCVSet.SCV_FollowPred.ForceRefTo(akPred)
        Else
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = 8)
        EndIf
      Else
        If akPrey == PlayerRef
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = 8, afDigestValueOverRide = 0, abMoveNow = False)
          SCVSet.SCV_FollowPred.ForceRefTo(akPred)
        Else
          JM_PreyEntry = addItem(akPred, akPrey, aiItemType = 8, afDigestValueOverRide = 0)
        EndIf
        JMap.setFlt(JM_PreyEntry, "StoredDigestValue", genDigestValue(akPrey, True))
      EndIf

      giveAVExp(akPred, getResLevel(akPrey))
    ;/ElseIf aiItemType == 5 || aiItemType == 7
      givePVEXP(akPred, getResLevel(akPrey))/;
  ;/  EndIf
  EndIf

  JMap.setInt(PreyData, "SCV_NumTimesEaten", JMap.getInt(PreyData, "SCV_NumTimesEaten") + 1)
  JMap.setForm(JM_PreyEntry, "SCV_Pred", akPred)
  JMap.setForm(JMap.getObj(PreyData, "SCLTrackingData"), "SCV_Pred", akPred)
  JMap.setInt(JM_PreyEntry, "StoredItemType", aiItemType)

  setProxy(akPred, "Stamina", akPred.GetActorValue("Stamina") as Int, PredData)
  setProxy(akPred, "Magicka", akPred.GetActorValue("Magicka") as Int, PredData)
  setProxy(akPred, "Health", akPred.GetActorValue("Health") as Int, PredData)

  setProxy(akPrey, "Stamina", akPrey.GetActorValue("Stamina") as Int, PreyData)
  setProxy(akPrey, "Magicka", akPrey.GetActorValue("Magicka") as Int, PreyData)
  setProxy(akPrey, "Health", akPrey.GetActorValue("Health") as Int, PreyData)


  Int InsertEvent = ModEvent.Create("SCV_InsertEvent")
  ModEvent.PushForm(InsertEvent, akPred)
  ModEvent.PushForm(InsertEvent, akPred)
  ModEvent.PushInt(InsertEvent, aiItemType)
  ModEvent.PushBool(InsertEvent, abFriendly)
  ModEvent.Send(InsertEvent)

  updateFullnessEX(akPred, True, PredData)

  SCVSet.SCV_InVoreActionList.RemoveAddedForm(akPred)
  SCVSet.SCV_InVoreActionList.RemoveAddedForm(akPrey)
  (SCVSet.SCV_FollowPred as SCVStayWithMe).DelayUpdate = False

  quickUpdate(akPred)
  preyHandlingLocked = False
  Return JM_PreyEntry
EndFunction/;

Bool Function isBossActor(Actor akTarget)
  {Compares target to player, determines whether they're consisdered a "boss"}
  Return False
EndFunction

Bool Function isImportant(Actor akTarget)
  Return False
EndFunction

Function removeStruggleSpells(Actor akTarget)
  SCVSet.SCV_StruggleDispel.cast(akTarget)
EndFunction

Bool Function sendStruggleFinishEvent(Actor akPred, Actor akPrey, Int aiItemType)
  Int FinishEvent = ModEvent.Create("SCV_StruggleFinish")
  ModEvent.PushForm(FinishEvent, akPred)
  ModEvent.PushForm(FinishEvent, akPrey)
  ModEvent.pushInt(FinishEvent, aiItemType)
  Return ModEvent.Send(FinishEvent)
EndFunction

Float[] Function genNormalDist()
	{Generates 2 randomly distributed numbers inside a 2x1 array
	See https://en.wikipedia.org/wiki/Marsaglia_polar_method and https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
	for more information
	Will be between -1 and 1
	Needs to be adjusted to be useful}
	Float u
	Float v
	Float s
	While s == 0 || s >= 1
		u = Utility.RandomFloat(-1, 1)
		v = Utility.RandomFloat(-1, 1)
		s = Math.pow(u, 2) + Math.pow(v, 2)
	EndWhile
	Float z = Math.sqrt((-2 * ApproximateNaturalLog(s, 0.1)) / s)
	Float Result1 = u * z
	Float Result2 = v * z
	Float[] Results = new Float[2]
	Results[0] = Result1
	Results[1] = Result2
	Return Results
EndFunction

Float Function ApproximateNaturalLog(Float x, Float precision)
	{Taken from http://www.gamesas.com/logarithm-function-t345141.html}
	 precision *= 2 ; since we double the result at the end
	 Float term = (x - 1) / (x + 1)
	 Float step = term * term
	 Float result = term
	 Float divisor = 1
	 Float delta = precision
	 While delta >= precision
		 term *= step
		 divisor += 2
		 delta = term / divisor
		 result += delta
	 EndWhile
	 Return 2.0 * result
 EndFunction

Int Function getPredDifficulty()
  Return 30
EndFunction

Int Function getPreyDifficulty()
  Return 30
EndFunction

Int Function genSoulSize(Actor akTarget)
  Race TargetRace = akTarget.GetRace()
  If TargetRace.HasKeyword(SCVSet.ActorTypeDwarven)
    Return 0
  EndIf
  Int Level = akTarget.GetLevel()
  If TargetRace.HasKeyword(SCVSet.ActorTypeDragon)
    Return 8
  ElseIf isBossActor(akTarget)
    Return 7
  ElseIf TargetRace.HasKeyword(SCVSet.ActorTypeNPC)
    Return 6
  ElseIf Level >= 38
    Return 5
  ElseIf Level >= 28
    Return 4
  ElseIf Level >= 16
    Return 3
  ElseIf Level >= 4
    Return 2
  ElseIf Level >= 1
    Return 1
  EndIf
EndFunction

Int Function fillGem(Actor akPred, Actor akPrey, Int aiTargetData = 0)
  {Searchs for a gem to fill and does so. Returns what kind of gem was filled.
  Returns -1 if a new gem was created, -2 if no gem was filled.}
  Int TargetData = getData(akPred, aiTargetData)
  Int PerkLevel = getPerkLevel(akPred, "SCV_PitOfSouls") - 1 ;We subtract one because the first level enables the function, the others increase gem size
  If PerkLevel < 0
    Return 0
  EndIf
  Notice("Bonus Level = " + PerkLevel)
  Int SoulSize = genSoulSize(akPrey)
  If SoulSize == 0  ;Has no soul to begin with
    Return -2
  EndIf
  Notice("Soul Size = " + SoulSize)
  Int[] Gems = getGemList(akPred, aiTargetData = TargetData)
  Int i = SoulSize
  i -= PerkLevel
  If i <= -1  ;Inserts SoulGem fragment if they have the lv 2 perk
    Notice("Soul fill size is less than 0! Inserting new gem...")
    ;addItem(akPred, akBaseObject = getGemTypes(0)[Utility.RandomInt(0, 4)], aiItemType = 2)
    Return -1
  EndIf
  Int Num = Gems.length - 1
  Bool Done
  While i < Num && !Done
    If Gems[i] > 0  ;If there is a gem with size equal to or greater than the soul size
      Notice("Found fillable gem! Soul Size = " + SoulSize + ", Gem size = " + i)
      Float GemChance = JMap.getFlt(TargetData, "SCVGemBonusChance")
      Int AddGem = 1
      If GemChance > 0
        Bool Failed
        While !Failed && AddGem < 11  ;Max 10 addition gems
          Float Success = Utility.RandomInt()
          If Success < GemChance
            AddGem += 1
          Else
            Failed = True
          EndIf
        EndWhile
      EndIf
      replaceGem(akPred, i, SoulSize, aiNum = AddGem, aiTargetData = TargetData) ;input the original size and the new size
      Done = True
    Else
      i += 1
    EndIf
  EndWhile
  JMap.setInt(TargetData, "SCV_SoulsCaptured", JMap.getINt(TargetData, "SCV_SoulsCaptured") + 1)
  Return i
EndFunction

Bool Function hasGems(Actor akTarget, Int aiItemType = 2, Int aiTargetData = 0)
  {Returns if actor has valid soul gems located in contents 2, or whatever override
  Excludes dragon gems, as they can't be filled again}
  Int TargetData = getData(akTarget, aiTargetData)
  Int Contents = getContents(akTarget, aiItemType, TargetData)
  If JValue.empty(Contents)
    Return False
  EndIf
  Form i = JFormMap.nextKey(Contents)
  While i
    Form BaseObject
    If i as SCX_Bundle
      BaseObject = (i as SCX_Bundle).ItemForm
    ElseIf i as ObjectReference
      BaseObject = (i as ObjectReference).GetBaseObject()
    EndIf
    If BaseObject
      If BaseObject == SCVSet.SCV_SplendidSoulGem
        Return True
      ElseIf BaseObject == SCVSet.SoulGemBlack || BaseObject == SCVSet.SoulGemBlackFilled
        Return True
      ElseIf BaseObject == SCVSet.SoulGemGrand || BaseObject == SCVSet.SoulGemGrandFilled
        Return True
      ElseIf BaseObject == SCVSet.SoulGemGreater || BaseObject == SCVSet.SoulGemGreaterFilled
        Return True
      ElseIf BaseObject == SCVSet.SoulGemCommon || BaseObject == SCVSet.SoulGemCommonFilled
        Return True
      ElseIf BaseObject == SCVSet.SoulGemLesser || BaseObject == SCVSet.SoulGemLesserFilled
        Return True
      ElseIf BaseObject == SCVSet.SoulGemPetty || BaseObject == SCVSet.SoulGemPettyFilled
        Return True
      ElseIf BaseObject == SCVSet.SoulGemPiece001  || BaseObject == SCVSet.SoulGemPiece002 || BaseObject == SCVSet.SoulGemPiece003 || BaseObject == SCVSet.SoulGemPiece004 || BaseObject == SCVSet.SoulGemPiece005
        Return True
      EndIf
    EndIf
    i = JFormMap.nextKey(Contents, i)
  EndWhile
  Return False
EndFunction


Int[] Function getGemList(Actor akTarget, Int aiItemType = 2, Int aiTargetData = 0)
  {Returns array of soul gems located in contents 2, or whatever override
  Excludes dragon gems, as they can't be filled again}
  Int TargetData = getData(akTarget, aiTargetData)
  Int[] ReturnArray = New Int[8]
  Int Contents = getContents(akTarget, aiItemType, TargetData)
  If JValue.empty(Contents)
    Return ReturnArray
  EndIf
  Form i = JFormMap.nextKey(Contents)
  While i
    Form BaseObject
    If i as SCX_Bundle
      BaseObject = (i as SCX_Bundle).ItemForm
    ElseIf i as ObjectReference
      BaseObject = (i as ObjectReference).GetBaseObject()
    EndIf
    If BaseObject
      If BaseObject == SCVSet.SCV_SplendidSoulGem
        ReturnArray[7] = ReturnArray[7] + 1
      ElseIf BaseObject == SCVSet.SoulGemBlack || BaseObject == SCVSet.SoulGemBlackFilled
        ReturnArray[6] = ReturnArray[6] + 1
      ElseIf BaseObject == SCVSet.SoulGemGrand || BaseObject == SCVSet.SoulGemGrandFilled
        ReturnArray[5] = ReturnArray[5] + 1
      ElseIf BaseObject == SCVSet.SoulGemGreater || BaseObject == SCVSet.SoulGemGreaterFilled
        ReturnArray[4] = ReturnArray[4] + 1
      ElseIf BaseObject == SCVSet.SoulGemCommon || BaseObject == SCVSet.SoulGemCommonFilled
        ReturnArray[3] = ReturnArray[3] + 1
      ElseIf BaseObject == SCVSet.SoulGemLesser || BaseObject == SCVSet.SoulGemLesserFilled
        ReturnArray[2] = ReturnArray[2] + 1
      ElseIf BaseObject == SCVSet.SoulGemPetty || BaseObject == SCVSet.SoulGemPettyFilled
        ReturnArray[1] = ReturnArray[1] + 1
      ElseIf BaseObject == SCVSet.SoulGemPiece001  || BaseObject == SCVSet.SoulGemPiece002 || BaseObject == SCVSet.SoulGemPiece003 || BaseObject == SCVSet.SoulGemPiece004 || BaseObject == SCVSet.SoulGemPiece005
        ReturnArray[0] = ReturnArray[0] + 1
      EndIf
    EndIf
    i = JFormMap.nextKey(Contents, i)
  EndWhile
  Return ReturnArray
EndFunction

Form[] Function getGemTypes(Int aiSize)
  {Filled gems put in first}
  Form[] ReturnArray = new Form[5]
  If aiSize == 0
    ReturnArray[0] = SCVSet.SoulGemPiece001
    ReturnArray[1] = SCVSet.SoulGemPiece002
    ReturnArray[2] = SCVSet.SoulGemPiece003
    ReturnArray[3] = SCVSet.SoulGemPiece004
    ReturnArray[4] = SCVSet.SoulGemPiece005
  ElseIf aiSize == 1
    ReturnArray[0] = SCVSet.SoulGemPettyFilled
    ReturnArray[1] = SCVSet.SoulGemPetty
  ElseIf aiSize == 2
    ReturnArray[0] = SCVSet.SoulGemLesserFilled
    ReturnArray[1] = SCVSet.SoulGemLesser
  ElseIf aiSize == 3
    ReturnArray[0] = SCVSet.SoulGemCommonFilled
    ReturnArray[1] = SCVSet.SoulGemCommon
  ElseIf aiSize == 4
    ReturnArray[0] = SCVSet.SoulGemGreaterFilled
    ReturnArray[1] = SCVSet.SoulGemGreater
  ElseIf aiSize == 5
    ReturnArray[0] = SCVSet.SoulGemGrandFilled
    ReturnArray[1] = SCVSet.SoulGemGrand
  ElseIf aiSize == 6
    ReturnArray[0] = SCVSet.SoulGemBlackFilled
    ReturnArray[1] = SCVSet.SoulGemBlack
  ElseIf aiSize == 7
    ReturnArray[0] = SCVSet.SCV_SplendidSoulGem
  ElseIf aiSize == 8
    ReturnArray[0] = SCVSet.SCV_DragonGem
  EndIf
  Return ReturnArray
EndFunction

Function replaceGem(Actor akTarget, Int aiOriginal, Int aiNew, Int aiItemType = 2, Int aiNum = 1, Int aiTargetData = 0)
  ;/Int TargetData = getData(akTarget, aiTargetData)
  Form[] OriginalArray = getGemTypes(aiOriginal)
  Form[] NewArray = getGemTypes(aiNew)
  If aiOriginal == 0
    Form Fragment = findGemFragment(akTarget, aiItemType, TargetData)
    If Fragment
      RemoveItem(akTarget, akBaseObject = Fragment, aiItemType = aiItemType, abDelete = True, aiTargetData = TargetData)
    Else
      Return
    EndIf
  ElseIf !removeItem(akTarget, akBaseObject = OriginalArray[1], aiItemType = aiItemType, abDelete = True, aiTargetData = TargetData)
    If !removeItem(akTarget, akBaseObject = OriginalArray[0], aiItemType = aiItemType, abDelete = True, aiTargetData = TargetData)
      Return
    EndIf
  EndIf
  Notice("Default soul size for new gem = " + (OriginalArray[0] as SoulGem).GetSoulSize())
  addItem(akTarget, akBaseObject = NewArray[0], aiItemType = aiItemType, aiItemCount = aiNum)  ;Choose filled gem/;
EndFunction

Form Function findGemFragment(Actor akTarget, Int aiItemType, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int Contents = getContents(akTarget, aiItemType, TargetData)
  Form SearchForm = JFormMap.nextKey(Contents)
  While SearchForm
    If SearchForm as ObjectReference
      Form CurrentForm
      If SearchForm as SCX_Bundle
        CurrentForm = (SearchForm as SCX_Bundle).ItemForm
      Else
        CurrentForm = (SearchForm as ObjectReference).GetBaseObject()
      EndIf
      If CurrentForm == SCVSet.SoulGemPiece001
        Return SCVSet.SoulGemPiece001
      ElseIf CurrentForm == SCVSet.SoulGemPiece002
        Return SCVSet.SoulGemPiece002
      ElseIf CurrentForm == SCVSet.SoulGemPiece003
        Return SCVSet.SoulGemPiece003
      ElseIf CurrentForm == SCVSet.SoulGemPiece004
        Return SCVSet.SoulGemPiece004
      ElseIf CurrentForm == SCVSet.SoulGemPiece005
        Return SCVSet.SoulGemPiece005
      EndIf
    EndIf
    SearchForm = JFormMap.nextKey(Contents, SearchForm)
  EndWhile
  Return None
EndFunction

;Perk Functions ****************************************************************
;/Perk List
SCV_IntenseHunger
SCV_MetalMuncher
SCV_ExpiredEpicurian
SCV_FollowerofNamira
SCV_DaedraDieter
SCV_DragonDevourer
SCV_Constriction
SCV_SpiritSwallower
SCV_RemoveLimits
SCV_Nourish
SCV_Acid
SCV_Stalker
SCV_PitOfSouls

SCV_StruggleSorcery
SCV_StrokeOfLuck
SCV_ExpectPushback
SCV_CorneredRat
SCV_FillingMeal
SCV_ThrillingStruggle/;

;/Function showQuickActorStatus(Actor akTarget)
  If akTarget == PlayerRef
    Int PlayerData = getTargetData(akTarget)
    Float Fullness = JMap.getFlt(PlayerData, "STFullness")
    Float Base = getAdjBase(akTarget)
    Float Energy = akTarget.GetActorValue("Stamina")
    If getCurrentPerkLevel(akTarget, "SCV_StruggleSorcery") >= 1
      Energy += akTarget.GetActorValue("Magicka")
    EndIf
    Debug.Notification("My Fullness: " + Fullness + "/" + Base + ", My Energy = " + Energy)
  ElseIf akTarget.IsInFaction(SCLSet.CurrentFollowerFaction) || SCLSet.DebugEnable
    Int TargetData = getTargetData(akTarget)
    Float Fullness = JMap.getFlt(TargetData, "STFullness")
    Float Base = getAdjBase(akTarget)
    String name = nameGet(akTarget)
    Float Energy = akTarget.GetActorValue("Stamina")
    If getCurrentPerkLevel(akTarget, "SCV_StruggleSorcery") >= 1
      Energy += akTarget.GetActorValue("Magicka")
    EndIf
    Debug.Notification(name + "'s Fullness: " + Fullness + "/" + Base + ", "+ name + "'s' Energy = " + Energy)
  EndIf
EndFunction

Function showFullActorStatus(Actor akTarget)
  If akTarget == PlayerRef
    Int PlayerData = getTargetData(akTarget)
    String FinalString

    Float Fullness = JMap.getFlt(PlayerData, "STFullness")
    Float Base = getAdjBase(akTarget)
    Float Energy = akTarget.GetActorValue("Stamina")
    If getCurrentPerkLevel(akTarget, "SCV_StruggleSorcery") >= 1
      Energy += akTarget.GetActorValue("Magicka")
    EndIf
    FinalString += "My Fullness: " + Fullness + "/" + Base + ", My Energy = " + Energy + ". \n"

    Actor Pred = getPred(akTarget, PlayerData)
    If Pred
      String PredName = nameGet(Pred)
      Float PredEnergy = Pred.GetActorValue("Stamina")
      If getCurrentPerkLevel(Pred, "SCV_StruggleSorcery") >= 1
        PredEnergy += Pred.GetActorValue("Magicka")
      EndIf
      String PredEntry = "Predator: " + PredName + ": " + PredEnergy + "\n"
      FinalString += PredEntry
    EndIf

    Int JF_Prey = getContents(akTarget, 8, PlayerData)
    Int i
    String[] PreyArray = New String[10]
    Form CurrentPrey = JFormMap.nextKey(JF_Prey)
    While CurrentPrey && i < 10
      If CurrentPrey as Actor
        Float PreyEnergy = (CurrentPrey as Actor).GetActorValue("Stamina")
        If getCurrentPerkLevel((CurrentPrey as Actor), "SCV_StruggleSorcery") >= 1
          PreyEnergy += (CurrentPrey as Actor).GetActorValue("Magicka")
        EndIf
        String Name = nameGet(CurrentPrey)
        PreyArray[i] = Name + ": " + PreyEnergy
        i += 1
      EndIf
      CurrentPrey = JFormMap.nextKey(JF_Prey, CurrentPrey)
    EndWhile
    i = 0
    Bool Done
    While i < 10  && !Done
      String Entry = PreyArray[i]
      If Entry
        FinalString += PreyArray[i] + "\n"
      Else
        Done = True
      EndIf
      i += 1
    EndWhile
    Debug.MessageBox(FinalString)
  ElseIf akTarget.IsInFaction(SCLSet.CurrentFollowerFaction) || SCLSet.DebugEnable
    Int ActorData = getTargetData(akTarget)
    String FinalString

    Float Fullness = JMap.getFlt(ActorData, "STFullness")
    Float Base = getAdjBase(akTarget)
    Float Energy = akTarget.GetActorValue("Stamina")
    If getCurrentPerkLevel(akTarget, "SCV_StruggleSorcery") >= 1
      Energy += akTarget.GetActorValue("Magicka")
    EndIf
    String name = nameGet(akTarget)
    FinalString += name + "'s Fullness: " + Fullness + "/" + Base + ", My Energy = " + Energy + ". \n"

    Actor Pred = getPred(akTarget, ActorData)
    If Pred
      String PredName = nameGet(Pred)
      Float PredEnergy = Pred.GetActorValue("Stamina")
      If getCurrentPerkLevel(Pred, "SCV_StruggleSorcery") >= 1
        PredEnergy += Pred.GetActorValue("Magicka")
      EndIf
      String PredEntry = "Predator: " + PredName + ": " + PredEnergy + "\n"
      FinalString += PredEntry
    EndIf

    String[] PreyArray = New String[10]
    Int i
    Int JF_Prey = getContents(akTarget, 8, ActorData)
    Form CurrentPrey = JFormMap.nextKey(JF_Prey)
    While CurrentPrey && i < 10
      If CurrentPrey as Actor
        Float PreyEnergy = (CurrentPrey as Actor).GetActorValue("Stamina")
        If getCurrentPerkLevel((CurrentPrey as Actor), "SCV_StruggleSorcery") >= 1
          PreyEnergy += (CurrentPrey as Actor).GetActorValue("Magicka")
        EndIf
        String PreyName = nameGet(CurrentPrey)
        PreyArray[i] = PreyName + ": " + PreyEnergy
        i += 1
      EndIf
      CurrentPrey = JFormMap.nextKey(JF_Prey, CurrentPrey)
    EndWhile
    i = 0
    Bool Done
    While i < 10  && !Done
      String Entry = PreyArray[i]
      If Entry
        FinalString += PreyArray[i] + "\n"
      Else
        Done = True
      EndIf
      i += 1
    EndWhile
    Debug.MessageBox(FinalString)
  EndIf
EndFunction/;

Function checkDebugSpells()
  If SCXSet.DebugEnable
    If !PlayerRef.HasSpell(SCVSet.SCV_MaxPredSpell)
      PlayerRef.AddSpell(SCVSet.SCV_MaxPredSpell, True)
    EndIf

    If !PlayerRef.HasSpell(SCVSet.SCV_ForceOVoreSpell)
      PlayerRef.AddSpell(SCVSet.SCV_ForceOVoreSpell, True)
    EndIf
    If !PlayerRef.HasSpell(SCVSet.SCV_ForceOVoreSpellNonLethal)
      PlayerRef.AddSpell(SCVSet.SCV_ForceOVoreSpellNonLethal, True)
    EndIf

    If !PlayerRef.HasSpell(SCVSet.SCV_ForceRandomOVoreSpell)
      PlayerRef.AddSpell(SCVSet.SCV_ForceRandomOVoreSpell, True)
    EndIf
    If !PlayerRef.HasSpell(SCVSet.SCV_ForceRandomOVoreSpellNonLethal)
      PlayerRef.AddSpell(SCVSet.SCV_ForceRandomOVoreSpellNonLethal, True)
    EndIf

    If !PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificOVoreSpell)
      PlayerRef.AddSpell(SCVSet.SCV_ForceSpecificOVoreSpell, True)
    EndIf
    If !PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificOVoreSpellNonLethal)
      PlayerRef.AddSpell(SCVSet.SCV_ForceSpecificOVoreSpellNonLethal, True)
    EndIf

    If !PlayerRef.HasSpell(SCVSet.SCV_ForceAVoreSpell)
      PlayerRef.AddSpell(SCVSet.SCV_ForceAVoreSpell, True)
    EndIf
    If !PlayerRef.HasSpell(SCVSet.SCV_ForceAVoreSpellNonLethal)
      PlayerRef.AddSpell(SCVSet.SCV_ForceAVoreSpellNonLethal, True)
    EndIf

    If !PlayerRef.HasSpell(SCVSet.SCV_ForceRandomAVoreSpell)
      PlayerRef.AddSpell(SCVSet.SCV_ForceRandomAVoreSpell, True)
    EndIf
    If !PlayerRef.HasSpell(SCVSet.SCV_ForceRandomAVoreSpellNonLethal)
      PlayerRef.AddSpell(SCVSet.SCV_ForceRandomAVoreSpellNonLethal, True)
    EndIf

    If !PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificAVoreSpell)
      PlayerRef.AddSpell(SCVSet.SCV_ForceSpecificAVoreSpell, True)
    EndIf
    If !PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificAVoreSpellNonLethal)
      PlayerRef.AddSpell(SCVSet.SCV_ForceSpecificAVoreSpellNonLethal, True)
    EndIf
  Else
    If PlayerRef.HasSpell(SCVSet.SCV_MaxPredSpell)
      PlayerRef.RemoveSpell(SCVSet.SCV_MaxPredSpell)
    EndIf

    If PlayerRef.HasSpell(SCVSet.SCV_ForceOVoreSpell)
			PlayerRef.RemoveSpell(SCVSet.SCV_ForceOVoreSpell)
		EndIf
    If PlayerRef.HasSpell(SCVSet.SCV_ForceOVoreSpellNonLethal)
      PlayerRef.RemoveSpell(SCVSet.SCV_ForceOVoreSpellNonLethal)
    EndIf

    If PlayerRef.HasSpell(SCVSet.SCV_ForceRandomOVoreSpell)
      PlayerRef.removespell(SCVSet.SCV_ForceRandomOVoreSpell)
    EndIf
    If PlayerRef.HasSpell(SCVSet.SCV_ForceRandomOVoreSpellNonLethal)
      PlayerRef.removespell(SCVSet.SCV_ForceRandomOVoreSpellNonLethal)
    EndIf

    If PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificOVoreSpell)
      PlayerRef.removespell(SCVSet.SCV_ForceSpecificOVoreSpell)
    EndIf
    If PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificOVoreSpellNonLethal)
      PlayerRef.removespell(SCVSet.SCV_ForceSpecificOVoreSpellNonLethal)
    EndIf

    If PlayerRef.HasSpell(SCVSet.SCV_ForceAVoreSpell)
      PlayerRef.RemoveSpell(SCVSet.SCV_ForceAVoreSpell)
    EndIf
    If PlayerRef.HasSpell(SCVSet.SCV_ForceAVoreSpellNonLethal)
      PlayerRef.RemoveSpell(SCVSet.SCV_ForceAVoreSpellNonLethal)
    EndIf

    If PlayerRef.HasSpell(SCVSet.SCV_ForceRandomAVoreSpell)
      PlayerRef.removespell(SCVSet.SCV_ForceRandomAVoreSpell)
    EndIf
    If PlayerRef.HasSpell(SCVSet.SCV_ForceRandomAVoreSpellNonLethal)
      PlayerRef.removespell(SCVSet.SCV_ForceRandomAVoreSpellNonLethal)
    EndIf

    If PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificAVoreSpell)
      PlayerRef.removespell(SCVSet.SCV_ForceSpecificAVoreSpell)
    EndIf
    If PlayerRef.HasSpell(SCVSet.SCV_ForceSpecificAVoreSpellNonLethal)
      PlayerRef.removespell(SCVSet.SCV_ForceSpecificAVoreSpellNonLethal)
    EndIf
  EndIf
EndFunction

Function addToFollow(Actor akPrey)
  akPrey.AddSpell(SCVSet.FollowSpell, True)
EndFunction

Function removeFromFollow(Actor akPrey)
  akPrey.RemoveSpell(SCVSet.FollowSpell)
EndFunction

Function ResumeFollowPred()
  Int Handle = ModEvent.Create("SCV_PauseFollow")
  ModEvent.send(Handle)
EndFunction

;/String Function getPerkDescription(String asPerkID, Int aiPerkLevel = 0)
  If asPerkID == "SCV_IntenseHunger"
    If aiPerkLevel == 0
      Return "No Requirement"
    ElseIf aiPerkLevel == 1
      Return "Increases success chance of swallow spells by 5%." ;Each rank increase it by 5%, so we need to adjust the magnitudes in the CK
    ElseIf aiPerkLevel == 2
      Return "Increases success chance of swallow spells by another 5%."
    ElseIf aiPerkLevel >= 3
      Return "Increases success chance of swallow spells by 10%."
    EndIf
  ElseIf asPerkID == "SCV_MetalMuncher"
    If aiPerkLevel == 0 || aiPerkLevel == 1
      Return "Allows you to eat Dwemer Automatons."
    ElseIf aiPerkLevel == 2
      Return "Increases chances of success in devouring Dwemer Automatons by 5% and gives a chance of acquiring bonus items from them."
    ElseIf aiPerkLevel >= 3
      Return "Increases chances of success in devouring Dwemer Automatons by 10%."
    EndIf
  ElseIf asPerkID == "SCV_FollowerofNamira"
    If aiPerkLevel == 0 || aiPerkLevel == 1
      Return "Allows you to eat humans."
    ElseIf aiPerkLevel == 2
      Return "Increases chances of success in devouring humans by 5% and gives a chance of acquiring bonus items from them."
    ElseIf aiPerkLevel >= 3
      Return "Increases chances of success in devouring humans by 10%."
    EndIf
  ElseIf asPerkID == "SCV_DragonDevourer"
    If aiPerkLevel == 0 || aiPerkLevel == 1
      Return "Allows you to eat dragons."
    ElseIf aiPerkLevel == 2
      Return "Increases chances of success in devouring dragons by 5%."
    ElseIf aiPerkLevel >= 3
      Return "Increases chances of success in devouring dragons by another 5% and gives a chance of acquiring bonus items from them."
    EndIf
  ElseIf asPerkID == "SCV_SpiritSwallower"
    If aiPerkLevel == 0 || aiPerkLevel == 1
      Return "Allows you to eat ghosts."
    ElseIf aiPerkLevel == 2
      Return "Increases chances of success in devouring ghosts by 5% and gives a chance of acquiring bonus items from them."
    ElseIf aiPerkLevel >= 3
      Return "Increases chances of devouring ghosts by 10%."
    EndIf
  ElseIf asPerkID == "SCV_ExpiredEpicurian"
    If aiPerkLevel == 0 || aiPerkLevel == 1
      Return "Allows you to eat the undead."
    ElseIf aiPerkLevel == 2
      Return "Increases chances of success in devouring the undead by 5% and gives a chance of acquiring bonus items from them."
    ElseIf aiPerkLevel >= 3
      Return "Increases chances of devouring the undead by 10%."
    EndIf
  ElseIf asPerkID == "SCV_DaedraDieter"
    If aiPerkLevel == 0 || aiPerkLevel == 1
      Return "Allows you to eat daedra."
    ElseIf aiPerkLevel == 2
      Return "Increases chances of devouring daedra by 5%."
    ElseIf aiPerkLevel >= 3
      Return "Increases chances of success in devouring daedra by another 5% and gives a chance of acquiring bonus items from them."
    EndIf
  ElseIf asPerkID == "SCV_Acid"
    If aiPerkLevel == 0
      Return "Deals health damage to struggling prey."
    ElseIf aiPerkLevel == 1
      Return "Deals slight health damage to struggling prey."
    ElseIf aiPerkLevel == 2
      Return "Deals moderate health damage to struggling prey."
    ElseIf aiPerkLevel >= 3
      Return "Deals heavy health damage to struggling prey."
    EndIf
  ElseIf asPerkID == "SCV_Stalker"
    If aiPerkLevel == 0
      Return "Increases swallow success chance when sneaking and unseen by your prey."
    ElseIf aiPerkLevel == 1
      Return "Increases swallow success chance by 20% when sneaking and unseen by your prey."
    ElseIf aiPerkLevel == 2
      Return "Increases swallow success chance by another 20% when sneaking and unseen by your prey. Increases movement speed slightly while you have struggling prey and are sneaking."
    ElseIf aiPerkLevel >= 3
      Return "Increases swallow success chance by yet another 20% when sneaking and unseen by your prey. Increases movement speed significantly while you have struggling prey and are sneaking."
    EndIf
  ElseIf asPerkID == "SCV_RemoveLimits"
    Return "Allows one to devour even if it would it put one above their max."
  ElseIf asPerkID == "SCV_Constriction"
    If aiPerkLevel == 0
      Return "Increases stamina/magicka damage done to struggling prey."
    ElseIf aiPerkLevel == 1
      Return "Increases stamina/magicka damage done to struggling prey slightly."
    ElseIf aiPerkLevel == 2
      Return "Increases stamina/magicka damage done to struggling prey moderately."
    ElseIf aiPerkLevel >= 3
      Return "Increases stamina/magicka damage done to struggling prey significantly."
    EndIf
  ElseIf asPerkID == "SCV_Nourish"
    If aiPerkLevel == 0
      Return "Gives health regeneration when one has digesting prey."
    ElseIf aiPerkLevel == 1
      Return "Gives slight health regeneration when one has digesting prey."
    ElseIf aiPerkLevel == 2
      Return "Gives slight health and stamina regeneration when one has digesting prey."
    ElseIf aiPerkLevel >= 3
      Return "Gives slight health, stamina, and magicka regeneration when one has digesting prey."
    EndIf
  ElseIf asPerkID == "SCV_PitOfSouls"
    If aiPerkLevel == 0
      Return "Enables one to capture enemy souls."
    ElseIf aiPerkLevel == 1
      Return "Enables one to capture enemy souls by storing soul gems in their stomach."
    ElseIf aiPerkLevel == 2
      Return "Soul gems can now capture souls one size bigger."
    ElseIf aiPerkLevel == 3
      Return "Soul gems can now capture souls two sizes bigger."
    EndIf
  ElseIf asPerkID == "SCV_StrokeOfLuck"
    If aiPerkLevel == 0
      Return "Gives a chance that a pred's devour attempt will fail."
    ElseIf aiPerkLevel == 1
      Return "Gives a 10% chance that a predator's devour attempt will fail."
    ElseIf aiPerkLevel == 2
      Return "Gives a 20% chance that a predator's devour attempt will fail."
    ElseIf aiPerkLevel >= 3
      Return "Gives a 30% chance that a predator's devour attempt will fail."
    EndIf
  ElseIf asPerkID == "SCV_ExpectPushback"
    If aiPerkLevel == 0
      Return "Knock back enemies back after an enemy's failed devour attempt."
    ElseIf aiPerkLevel == 1
      Return "Has a 50% chance of knocking enemies back after an enemy's failed devour attempt."
    ElseIf aiPerkLevel == 2
      Return "Increases range of knock back."
    ElseIf aiPerkLevel >= 3
      Return "Knock back occurs for every failed devour attempt."
    EndIf
  ElseIf asPerkID == "SCV_CorneredRat"
    If aiPerkLevel == 0
      Return "Deals health damage to one's pred."
    ElseIf aiPerkLevel == 1
      Return "Deals slight health damage to one's predator."
    ElseIf aiPerkLevel == 2
      Return "Deals moderate health damage to one's predator."
    ElseIf aiPerkLevel >= 3
      Return "Deals heavy health damage to one's predator."
    EndIf
  ElseIf asPerkID == "SCV_FillingMeal"
    If aiPerkLevel == 0
      Return "Increase's one's size while inside a predator."
    ElseIf aiPerkLevel == 1
      Return "Increase's one's size while inside a predator by 20%."
    ElseIf aiPerkLevel == 2
      Return "Increase's one's size while inside a predator by 40%."
    ElseIf aiPerkLevel >= 3
      Return "Increase's one's size while inside a predator by 60%."
    EndIf
  ElseIf asPerkID == "SCV_ThrillingStruggle"
    If aiPerkLevel == 0
      Return "Increases stamina/magicka damage done to one's predator."
    ElseIf aiPerkLevel == 1
      Return "Increases stamina/magicka damage done to one's predator slightly."
    ElseIf aiPerkLevel == 2
      Return "Increases stamina/magicka damage done to one's predator moderately."
    ElseIf aiPerkLevel == 3
      Return "Increases stamina/magicka damage done to one's predator significantly."
    EndIf
  Else
    Return Parent.getPerkDescription(asPerkID, aiPerkLevel)
  EndIf
EndFunction

String Function getPerkRequirements(String asPerkID, Int aiPerkLevel)
  If asPerkID == "SCV_IntenseHunger"
    Int Req1
    Int Req2
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Req1 = 10
      Req2 = 15
    ElseIf aiPerkLevel == 2
      Req1 = 60
      Req2 = 35
    ElseIf aiPerkLevel == 3
      Req1 = 150
      Req2 = 60
    EndIf
    Return "Have an oral predator skill level of " + Req2 + " and consume " + Req1 + " prey."
  ElseIf asPerkID == "SCV_MetalMuncher"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have a digestion rate of at least 2, be at level 15, and possess the knowledge of the ancient Dwemer."
    ElseIf aiPerkLevel == 2
      Return "Have a digestion rate of at least 5, be at level 25, consume 30 Dwemer Automatons, and discover the secret of the Dwemer Oculory."
    ElseIf aiPerkLevel == 3
      Return "Have a digestion rate of at least 8, be at level 30, consume 60 Dwemer Automatons, and unlock the container with the heart of a god."
    EndIf
  ElseIf asPerkID == "SCV_FollowerofNamira"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have more than 150 health, be at level 5, and experience contact with the Lady of Decay."
    ElseIf aiPerkLevel == 2
      Return "Have more than 250 health, be at level 10, consume 30 humans, and discover your inner beast for the first time."
    ElseIf aiPerkLevel == 3
      Return "Have more than 350 health, be at level 30, consume 60 humans, and devour 10 important people."
    EndIf
  ElseIf asPerkID == "SCV_DragonDevourer"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Slay more than 30 dragons, be at level 30, and learn more about your nemesis."
    ElseIf aiPerkLevel == 2
      Return "Slay more than 70 dragons, consume 20 of them, be at level 50, and defeat the one who will consume the world."
    ElseIf aiPerkLevel == 3
      Return "Slay more than 100 dragons, consume 100 of them, be at level 70, and consume the essence of dragons at least 10 times."
    EndIf
  ElseIf asPerkID == "SCV_SpiritSwallower"
    If aiPerkLevel == 0
      Return "No Requirements"
    ElseIf aiPerkLevel == 1
      Return "Have more than 150 magicka, be at level 5, and discover the source of the mysterious events happening in Ivarstead."
    ElseIf aiPerkLevel == 2
      Return "Have more than 200 magicka, be at level 10, consume 5 spirits, and free the spirits trapped in the maze."
    ElseIf aiPerkLevel == 3
      Return "Have more than 300 magicka, be at level 15, consume 15 spirits, and stop a terrible evil from being reawakened."
    EndIf
  ElseIf asPerkID == "SCV_ExpiredEpicurian"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have more than 150 Stamina, be at level 5, and defeat the conjurer keeping the lovers apart."
    ElseIf aiPerkLevel == 2
      Return "Have more than 200 Stamina, be at level 10, consume 5 undead, and retrieve the amulet that destroyed a family."
    ElseIf aiPerkLevel == 3
      Return "Have more than 300 Stamina, be at level 15, consume 15 undead, and wear the mysterious mask of Konahrik."
    EndIf
  ElseIf asPerkID == "SCV_DaedraDieter"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 25 Conjuration Skill, be at level 10, and perform a task for the Prince of Dawn and Dusk."
    ElseIf aiPerkLevel == 2
      Return "Have at least 40 Conjuration Skill, be at level 20, consume 20 daedric enemies, and investigate the cursed stone home."
    ElseIf aiPerkLevel == 3
      Return "Have at least 60 Conjuration Skill, be at level 30, consume 50 daedric enemies, and reassemble a terrible weapon."
    EndIf
  ElseIf asPerkID == "SCV_Acid"
    Float Req1
    Float Req2
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Req1 = 4
      Req2 = 35
    ElseIf aiPerkLevel == 2
      Req1 = 10
      Req2 = 70
    ElseIf aiPerkLevel == 3
      Req1 = 20
      Req2 = 120
    EndIf
    Return "Have a Digestion Rate of at least " + Req1 + " and digest at least " + Req2 + " units of food."
  ElseIf asPerkID == "SCV_Stalker"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 25 Sneak, be at least level 10, and have the ability to cast spells quietly."
    ElseIf aiPerkLevel == 2
      Return "Have at least 50 Sneak, be at least level 25, and join with the Nightingales."
    ElseIf aiPerkLevel == 3
      Return "Have at least 75 Sneak, be at least level 35 and pull off the greatest assassination in all of Tamriel."
    EndIf
  ElseIf asPerkID == "SCV_RemoveLimits"
    Return "????"
  ElseIf asPerkID == "SCV_Constriction"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 20 Heavy Armor, have at least 200 Stamina, and infiltrate an ancient fort on the behalf of another."
    ElseIf aiPerkLevel == 2
      Return "Have at least 40 Heavy Armor, have at least 300 Stamina, and help a young woman discover the truth about her companion."
    ElseIf aiPerkLevel == 3
      Return "Have at least 60 Heavy Armor, have at least 400 Stamina and help set a man's wife free."
    EndIf
  ElseIf asPerkID == "SCV_Nourish"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 20 Light Armor, have at least 200 Magicka, and discover the cause of a tragic fire."
    ElseIf aiPerkLevel == 2
      Return "Have at least 40 Light Armor, have at least 300 Magicka, and assist the wizard of the Blue Palace."
    ElseIf aiPerkLevel == 3
      Return "Have at least 60 Light Armor, have at least 400 Magicka and put an end to a sealed evil in Falkreath."
    EndIf
  ElseIf asPerkID == "SCV_PitOfSouls"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 30 Enchanting, have at least Spirit Swallower Lv. 1, be at level 15, and have the perk 'Soul Squeezer'."
    ElseIf aiPerkLevel == 2
      Return "Have at least 55 Enchanting, have at least Spirit Swallower Lv. 2, be at level 30, capture at least 30 souls by devouring them, and assist a wizard in his studies into the Dwemer disappearance."
    ElseIf aiPerkLevel == 3
      Return "Have at least 90 Enchanting, be at level 50, capture at least 70 souls by devouring them, and become a master Conjurer."
    EndIf
  ElseIf asPerkID == "SCV_StrokeOfLuck"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 25 Lockpicking, and avoid being eaten 5 times."
    ElseIf aiPerkLevel == 2
      Return "Have at least 55 Lockpicking, have at least 5 lucky moments, and be very fortunate in finding gold."
    ElseIf aiPerkLevel == 3
      Return "Have at least 60 Lockpicking, have at least 20 lucky moments, and perform your deed to the darkness."
    EndIf
  ElseIf asPerkID == "SCV_ExpectPushback"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Possess the word 'Force', be at level 7, and show your prowess of hand-to-hand combat in Riften."
    ElseIf aiPerkLevel == 2
      Return "Possess the word 'Balance', be at level 15, and a retrieve a woman's prized weapon for her."
    ElseIf aiPerkLevel == 3
      Return "Possess the word 'Push', be at level 25, and meet a true master of the Voice."
    EndIf
  ElseIf asPerkID == "SCV_CorneredRat"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Be eaten at least once and survive, and locate a man hiding for his life surrounded by rats."
    ElseIf aiPerkLevel == 2
      Return "Be eaten at least 5 times and survive, and put an end to the man who sealed himself away for a chance at power."
    ElseIf aiPerkLevel == 3
      Return "Be eaten at least 15 times and survive, and help capture a powerful beast."
    EndIf
  ElseIf asPerkID == "SCV_FillingMeal"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Take up at least 300 units in a prey's stomach and be at level 15."
    ElseIf aiPerkLevel == 2
      Return "Take up at least 500 units in a prey's stomach, be at level 25, and have a resistance skill of at least 30."
    ElseIf aiPerkLevel == 3
      Return "Take up at least 800 units in a prey's stomach, be at level 35, and have a resistance skill of at least 50."
    EndIf
  ElseIf asPerkID == "SCV_ThrillingStruggle"
    If aiPerkLevel == 0
      Return "No Requirements."
    ElseIf aiPerkLevel == 1
      Return "Have at least 250 points of energy and a resistance skill of at least 20."
    ElseIf aiPerkLevel == 2
      Return "Have at least 350 points of energy, a resistance skill of at least 40, and escape a wrongful imprisonment."
    ElseIf aiPerkLevel == 3
      Return "Have at least 700 points of energy, a resistance skill of at least 60, and cause an incident at sea."
    EndIf
  Else
    Return Parent.getPerkRequirements(asPerkID, aiPerkLevel)
  EndIf
EndFunction/;
