ScriptName SCM_BodyEditMuscle Extends SCX_BaseBodyEdit

SCM_Library Property SCMLib Auto
SCM_Settings Property SCMSet Auto
Spell Property SCM_BodyEditMuscleSpell Auto

GlobalVariable Property SCX_BodyEditMuscleEnable Auto
Function reloadMaintenence()
  SCX_BodyEditMuscleEnable.SetValueInt(0)
  Utility.Wait(3)
  SCX_BodyEditMuscleEnable.SetValueInt(1)
EndFunction

Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If EnableMorph
    SCX_BodyEditMuscleEnable.SetValueInt(1)
    Note("Edit body part called! Target = " + akTarget.GetLeveledActorBase().GetName())
    If SCXSet.ActorTypeNPC
      Note("Found Actor Keyword")
    Else
      Note("Couldn't find actor Keyword!")
    EndIf
    If !akTarget.HasKeyword(SCXSet.ActorTypeNPC)
      Note("Actor lacks keyword! Checking creature races!")
      Race akRace = akTarget.GetRace()
      If CreatureRaces.find(akRace) == -1
        Note("Actor is not on the list!")
        Return
      EndIf
    EndIf
    Int TargetData = SCXLib.getTargetData(akTarget)
    afValue *= Multiplier
    ;afValue *= (akTarget.GetLeveledActorBase().GetWeight() / 100 * HighScale) + 1
    ;afValue /= akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False)
    ;afValue = curveValue(afValue)
    afValue = PapyrusUtil.ClampFloat(afValue, Minimum, Maximum)

    Note(akTarget.GetLeveledActorBase().GetName() + " Value = " + afValue)
    JMap.setFlt(TargetData, "SCM_BodyEditMuscleTargetValue", afValue)
    If SCM_BodyEditMuscleSpell
      Note("Found Spell!")
    Else
      Note("Couldn't find spell!")
    EndIf
    If !akTarget.HasSpell(SCM_BodyEditMuscleSpell)
      akTarget.AddSpell(SCM_BodyEditMuscleSpell, True)
    EndIf
    Int Handle = ModEvent.Create("SCM_BodyEditMuscleSpellUpdate")
    ModEvent.PushForm(Handle, akTarget)
    ModEvent.PushBool(Handle, False)
    ModEvent.send(Handle)
  Else
    SCX_BodyEditMuscleEnable.SetValueInt(0)
  EndIf
EndFunction

Function rapidEdit(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If !akTarget.HasKeyword(SCXSet.ActorTypeNPC)
    Race akRace = akTarget.GetRace()
    If CreatureRaces.find(akRace) == -1
      Return
    EndIf
  EndIf
  Int TargetData = SCXLib.getTargetData(akTarget)
  afValue *= Multiplier
  ;afValue *= (akTarget.GetLeveledActorBase().GetWeight() / 100 * HighScale) + 1
  ;afValue /= akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False)
  afValue = curveValue(afValue)
  afValue = PapyrusUtil.ClampFloat(afValue, Minimum, Maximum)

  JMap.setFlt(TargetData, "SCM_BodyEditMuscleTargetValue", afValue)
  If !akTarget.HasSpell(SCM_BodyEditMuscleSpell)
    akTarget.AddSpell(SCM_BodyEditMuscleSpell, False)
  EndIf
  Int Handle = ModEvent.Create("SCM_BodyEditMuscleSpellUpdate")
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushBool(Handle, True)
  ModEvent.send(Handle)
EndFunction

Function updateBodyPart(Actor akTarget, Bool abRapid = False)
  Int TargetData = SCXLib.getTargetData(akTarget)
  Float Total = calculateMuscleWeight(akTarget, TargetData)
  Int i = CollectKeys.length
  While i
    i -= 1
    Total += JMap.getFlt(TargetData, CollectKeys[i])
  EndWhile
  If !abRapid
    editBodyPart(akTarget, Total)
  Else
    rapidEdit(akTarget, Total)
  EndIf
EndFunction

Bool Property EditingPreset Auto
Function addMCMOptions(SCX_ModConfigMenu MCM, Int JI_OptionIndexes)
  ;Add option to edit global and individual sliders with the option to 0-out everything and to reset to defaults.
  String Name = UIName
  String asEdit = _getStrKey()
  JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption("Profile", CurrentProfileKey), "BodyEdit." + asEdit + "." + "SelectProfile")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddInputOption("Create New Profile", ""), "BodyEdit." + asEdit + "." + "CreateProfile")

  JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption(Name + "Enable", EnableMorph), "BodyEdit." + asEdit + ".Enable")
  ;JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Methods", CurrentMethod), "BodyEdit." + asEdit + "." + "Methods")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Minimum", Minimum, "{1}"), "BodyEdit." + asEdit + "." + "Minimum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Maximum", Maximum, "{1}"), "BodyEdit." + asEdit + "." + "Maximum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Curve", Curve, "{1}"), "BodyEdit." + asEdit + "." + "Curve")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Multiplier", Multiplier, "{1}"), "BodyEdit." + asEdit + "." + "Multiplier")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Increment", Increment, "{1}"), "BodyEdit." + asEdit + "." + "Increment")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption(Name + " Enable Increment", EnableIncrement), "BodyEdit." + asEdit + "." + "EnableIncrement")

  String i = JMap.nextKey(JM_ActorValueWeights)
  While i
    JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(i, JMap.getFlt(JM_ActorValueWeights, i), "{2}"), "BodyEdit." + asEdit + ".StatWeight-" + i)
    i = JMap.nextKey(JM_ActorValueWeights, i)
  EndWhile

  i = JMap.nextKey(JM_MorphEffectRating)
  While i
    JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(i, JMap.getFlt(JM_MorphEffectRating, i), "{2}"), "BodyEdit." + asEdit + ".MorphEffect-" + i)
    i = JMap.nextKey(JM_MorphEffectRating, i)
  EndWhile

EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  String Highlight
  If asValue == "Enable"
    HighLight = "Enables actors to gain or lose muscle."
  ElseIf asValue == "Minimum"
    HighLight = "Smallest value this change can have"
  ElseIf asValue == "Maximum"
    HighLight = "Largest value this change can have"
  ElseIf asValue == "Curve"
    HighLight = "Decreases size at larger values to simulate volume. Smaller values = more extreme curving. Set to 2 to disable."
  ElseIf asValue == "Multiplier"
    HighLight = "Muliplies size value."
  ElseIf asValue == "Increment"
    HighLight = "Sets the increment for gradual growth. Smaller values will be heavier on the system."
  ElseIf asValue == "EnableIncrement"
    HighLight = "Enables or disables gradual growth."
  ElseIf asValue == "Methods"
    HighLight = "Sets how the change is implement."
  Else
    String[] ValueKeys = StringUtil.Split(asValue, "-")
    If ValueKeys[0] == "StatWeight"
      Highlight = "Set how much " + ValueKeys[1] + " affects muscle."
    ElseIf ValueKeys[1] == "MorphEffect"
      Highlight = "Sets the change in morph " + ValueKeys[1] + " per unit."
    EndIf
  EndIf
  MCM.setInfoText(HighLight)
EndFunction

Float[] Function getSliderOptions(SCX_ModConfigMenu MCM, String asValue)
{Set to recommended default values.}
  Float[] ValueArray = New Float[5]
  If asValue == "Minimum"
    ValueArray[0] = Minimum ;Start
    ValueArray[1] = 1       ;Default
    ValueArray[2] = 1     ;Increment
    ValueArray[3] = -1      ;Min
    ValueArray[4] = 100     ;Max
  ElseIf asValue == "Maximum"
    ValueArray[0] = Maximum
    ValueArray[1] = 100
    ValueArray[2] = 1
    ValueArray[3] = -1
    ValueArray[4] = 200
  ElseIf asValue == "Curve"
    ValueArray[0] = Curve
    ValueArray[1] = 1.75
    ValueArray[2] = 0.1
    ValueArray[3] = 0
    ValueArray[4] = 2
  ElseIf asValue == "Multiplier"
    ValueArray[0] = Multiplier
    ValueArray[1] = 1
    ValueArray[2] = 0.1
    ValueArray[3] = 0
    ValueArray[4] = 10
  ;/ElseIf asValue == "HighScale"
    ValueArray[0] = HighScale
    ValueArray[1] = 0
    ValueArray[2] = 0.1
    ValueArray[3] = -5
    ValueArray[4] = 5/;
  ElseIf asValue == "Increment"
    ValueArray[0] = Increment
    ValueArray[1] = 0.5
    ValueArray[2] = 0.1
    ValueArray[3] = 0.1
    ValueArray[4] = 2
  Else
    String[] ValueKeys = StringUtil.Split(asValue, "-")
    If ValueKeys[0] == "StatWeight"
      String StatStr = ValueKeys[1]
      If StatStr == "Health" || StatStr == "Stamina" || StatStr == "Health"
        ValueArray[0] = JMap.getFlt(JM_ActorValueWeights, StatStr)
        ValueArray[1] = 0
        ValueArray[2] = 0.01
        ValueArray[3] = 0
        ValueArray[4] = 2
      Else
        ValueArray[0] = JMap.getFlt(JM_ActorValueWeights, StatStr)
        ValueArray[1] = 0
        ValueArray[2] = 0.1
        ValueArray[3] = 0
        ValueArray[4] = 5
      EndIf
    ElseIf ValueKeys[0] == "MorphEffect"
      String MorphString = ValueKeys[1]
      ValueArray[0] = JMap.getFlt(JM_MorphEffectRating, MorphString)
      ValueArray[1] = 0
      ValueArray[2] = 0.1
      ValueArray[3] = 0
      ValueArray[4] = 5
    EndIf
  EndIf
  Return ValueArray
EndFunction

Function setSliderOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Float afValue)
  If asValue == "Minimum"
    Minimum = afValue
  ElseIf asValue == "Maximum"
    Maximum == afValue
  ElseIf asValue == "Curve"
    Curve == afValue
  ElseIf asValue == "Multiplier"
    Multiplier == afValue
  ElseIf asValue == "HighScale"
    HighScale == afValue
  ElseIf asValue == "Increment"
    Increment == afValue
  Else
    String[] ValueKeys = StringUtil.Split(asValue, "-")
    If ValueKeys[0] == "StatWeight"
      If JMap.hasKey(JM_ActorValueWeights, ValueKeys[1])
        JMap.setFlt(JM_ActorValueWeights, ValueKeys[1], afValue)
      EndIf
    ElseIf ValueKeys[1] == "MorphEffect"
      If JMap.hasKey(JM_MorphEffectRating, ValueKeys[1])
        JMap.setFlt(JM_MorphEffectRating, ValueKeys[1], afValue)
      EndIf
    EndIf
  EndIf
  saveProfile()
  MCM.SetSliderOptionValue(aiOption, afValue, "{2}")
EndFunction

Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "EnableIncrement"
    EnableIncrement = !EnableIncrement
    MCM.SetToggleOptionValue(aiOption, EnableIncrement)
  ElseIf asValue == "Enable"
    EnableMorph = !EnableMorph
    MCM.ForcePageReset()
  EndIf
  saveProfile()
EndFunction

Bool Property EnableMorph Auto
Int Property JM_ActorValueWeights
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "JM_ActorValueWeights")
      Int JM_AV = JMap.object()
      JMap.setObj(JM_Settings, "JM_ActorValueWeights", JM_AV)
      JMap.setFlt(JM_AV, "OneHanded", 0)
      JMap.setFlt(JM_AV, "TwoHanded", 0)
      JMap.setFlt(JM_AV, "Marksman", 0)
      JMap.setFlt(JM_AV, "Block", 0)
      JMap.setFlt(JM_AV, "Smithing", 0)
      JMap.setFlt(JM_AV, "HeavyArmor", 0)
      JMap.setFlt(JM_AV, "LightArmor", 0)
      JMap.setFlt(JM_AV, "Pickpocket", 0)
      JMap.setFlt(JM_AV, "Lockpicking", 0)
      JMap.setFlt(JM_AV, "Sneak", 0)
      JMap.setFlt(JM_AV, "Alchemy", 0)
      JMap.setFlt(JM_AV, "Speechcraft", 0)
      JMap.setFlt(JM_AV, "Alteration", 0)
      JMap.setFlt(JM_AV, "Conjuration", 0)
      JMap.setFlt(JM_AV, "Destruction", 0)
      JMap.setFlt(JM_AV, "Illusion", 0)
      JMap.setFlt(JM_AV, "Restoration", 0)
      JMap.setFlt(JM_AV, "Enchanting", 0)
      JMap.setFlt(JM_AV, "Health", 0)
      JMap.setFlt(JM_AV, "Stamina", 0)
      JMap.setFlt(JM_AV, "Magicka", 0)
      JMap.setFlt(JM_AV, "Level", 0)
    EndIf
    Return JMap.getObj(JM_Settings, "JM_ActorValueWeights")
  EndFunction
EndProperty

Int Property JM_MorphEffectRating
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "JM_MorphEffectRating")
      Int JM_MER = JMap.object()
      JMap.setObj(JM_Settings, "JM_MorphEffectRating", JM_MER)
      JMap.setFlt(JM_MER, "Samson", 0)
      JMap.setFlt(JM_MER, "Samuel", 0)
      JMap.setFlt(JM_MER, "AnkleSize", 0)
      JMap.setFlt(JM_MER, "AppleCheeks", 0)
      JMap.setFlt(JM_MER, "AreolaSize", 0)
      JMap.setFlt(JM_MER, "Arms", 0)
      JMap.setFlt(JM_MER, "Back", 0)
      JMap.setFlt(JM_MER, "BackArch", 0)
      JMap.setFlt(JM_MER, "Belly", 0)
      JMap.setFlt(JM_MER, "BigBelly", 0)
      JMap.setFlt(JM_MER, "BigButt", 0)
      JMap.setFlt(JM_MER, "BigTorso", 0)
      JMap.setFlt(JM_MER, "BreastCenter", 0)
      JMap.setFlt(JM_MER, "BreastCenterBig", 0)
      JMap.setFlt(JM_MER, "BreastCleavage", 0)
      JMap.setFlt(JM_MER, "BreastFlatness2", 0)
      JMap.setFlt(JM_MER, "BreastFlatness", 0)
      JMap.setFlt(JM_MER, "BreastGravity", 0)
      JMap.setFlt(JM_MER, "BreastHeight", 0)
      JMap.setFlt(JM_MER, "BreastPerkiness", 0)
      JMap.setFlt(JM_MER, "Breasts", 0)
      JMap.setFlt(JM_MER, "BreastsFantasy", 0)
      JMap.setFlt(JM_MER, "BreastsGone", 0)
      JMap.setFlt(JM_MER, "BreastsNewSH", 0)
      JMap.setFlt(JM_MER, "BreastsSmall", 0)
      JMap.setFlt(JM_MER, "BreastsSmall2", 0)
      JMap.setFlt(JM_MER, "BreastsTogether", 0)
      JMap.setFlt(JM_MER, "BreastsTopSlope", 0)
      JMap.setFlt(JM_MER, "BreastsWidth", 0)
      JMap.setFlt(JM_MER, "Butt", 0)
      JMap.setFlt(JM_MER, "ButtClassic", 0)
      JMap.setFlt(JM_MER, "ButtCrack", 0)
      JMap.setFlt(JM_MER, "ButtShape2", 0)
      JMap.setFlt(JM_MER, "ButtSmall", 0)
      JMap.setFlt(JM_MER, "CalfSize", 0)
      JMap.setFlt(JM_MER, "CalfSmooth", 0)
      JMap.setFlt(JM_MER, "ChestDepth", 0)
      JMap.setFlt(JM_MER, "ChestWidth", 0)
      JMap.setFlt(JM_MER, "ChubbyArms", 0)
      JMap.setFlt(JM_MER, "ChubbyButt", 0)
      JMap.setFlt(JM_MER, "ChubbyLegs", 0)
      JMap.setFlt(JM_MER, "ChubbyWaist", 0)
      JMap.setFlt(JM_MER, "CrotchBack", 0)
      JMap.setFlt(JM_MER, "DoubleMelon", 0)
      JMap.setFlt(JM_MER, "ForearmSize", 0)
      JMap.setFlt(JM_MER, "Groin", 0)
      JMap.setFlt(JM_MER, "Hipbone", 0)
      JMap.setFlt(JM_MER, "HipForward", 0)
      JMap.setFlt(JM_MER, "Hips", 0)
      JMap.setFlt(JM_MER, "HipUpperWidth", 0)
      JMap.setFlt(JM_MER, "KneeHeight", 0)
      JMap.setFlt(JM_MER, "KneeShape", 0)
      JMap.setFlt(JM_MER, "LegShapeClassic", 0)
      JMap.setFlt(JM_MER, "LegsThin", 0)
      JMap.setFlt(JM_MER, "MuscleAbs", 2)
      JMap.setFlt(JM_MER, "MuscleArms", 2)
      JMap.setFlt(JM_MER, "MuscleButt", 2)
      JMap.setFlt(JM_MER, "MuscleLegs", 2)
      JMap.setFlt(JM_MER, "MusclePecs", 2)
      JMap.setFlt(JM_MER, "NeckSeam", 0)
      JMap.setFlt(JM_MER, "NipBGone", 0)
      JMap.setFlt(JM_MER, "NippleDistance", 0)
      JMap.setFlt(JM_MER, "NippleLength", 0)
      JMap.setFlt(JM_MER, "NippleManga", 0)
      JMap.setFlt(JM_MER, "NipplePerkiness", 0)
      JMap.setFlt(JM_MER, "NipplePerkManga", 0)
      JMap.setFlt(JM_MER, "NippleSize", 0)
      JMap.setFlt(JM_MER, "NippleTip", 0)
      JMap.setFlt(JM_MER, "NippleTipManga", 0)
      JMap.setFlt(JM_MER, "NippleUp", 0)
      JMap.setFlt(JM_MER, "PregancyBelly", 0)
      JMap.setFlt(JM_MER, "PushUp", 0)
      JMap.setFlt(JM_MER, "RibsProminance", 0)
      JMap.setFlt(JM_MER, "RoundAss", 0)
      JMap.setFlt(JM_MER, "ShoulderSmooth", 0)
      JMap.setFlt(JM_MER, "ShoulderTweak", 0)
      JMap.setFlt(JM_MER, "ShoulderWidth", 0)
      JMap.setFlt(JM_MER, "SlimThighs", 0)
      JMap.setFlt(JM_MER, "SternumDepth", 0)
      JMap.setFlt(JM_MER, "SternumHeight", 0)
      JMap.setFlt(JM_MER, "Thighs", 0)
      JMap.setFlt(JM_MER, "TummyTuck", 0)
      JMap.setFlt(JM_MER, "Waist", 0)
      JMap.setFlt(JM_MER, "WaistHeight", 0)
      JMap.setFlt(JM_MER, "WideWaistLine", 0)
      JMap.setFlt(JM_MER, "WristSize", 0)
      JMap.setFlt(JM_MER, "7B Lower", 0)
      JMap.setFlt(JM_MER, "7B Upper", 0)
      JMap.setFlt(JM_MER, "VanilaSSEHi", 0)
      JMap.setFlt(JM_MER, "VanilaSSELo", 0)
      JMap.setFlt(JM_MER, "OldBaseShape", 0)
    EndIf
    Return JMap.getObj(JM_Settings, "JM_MorphEffectRating")
  EndFunction
EndProperty

Float Function calculateMuscleWeight(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  String i = JMap.nextKey(JM_ActorValueWeights)
  Float MuscleRating
  While i
    If i == "Level"
      MuscleRating += akTarget.GetLevel() * JMap.getFlt(JM_ActorValueWeights, i)
    Else
      ;MuscleRating += akTarget.GetActorValueMax(i) * JMap.getFlt(JM_ActorValueWeights, i)  ;Use this for SSE
      MuscleRating += akTarget.GetBaseActorValue(i) * JMap.getFlt(JM_ActorValueWeights, i)
    EndIf
    i = JMap.nextKey(JM_ActorValueWeights, i)
  EndWhile
  Return MuscleRating
EndFunction
