ScriptName SCM_BodyEditWeight Extends SCX_BaseBodyEdit

SCM_Library Property SCMLib Auto
SCM_Settings Property SCMSet Auto
Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If EnableMorph
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

    Float OldWeight = akTarget.GetLeveledActorBase().GetWeight()
    If OldWeight != afValue
      If !akTarget.IsOnMount()
        Float NeckDelta = (OldWeight / 100) - (afValue / 100)
        akTarget.GetLeveledActorBase().SetWeight(afValue)
        akTarget.UpdateWeight(NeckDelta)
        akTarget.QueueNiNodeUpdate()
      EndIf
    EndIf
  EndIf
EndFunction

Function rapidEdit(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  editBodyPart(akTarget, afValue, asMethodOverride, aiEquipSetOverride, asShortModKey, asFullModKey)
EndFunction

Function updateBodyPart(Actor akTarget, Bool abRapid = False)
  Int TargetData = SCXLib.getTargetData(akTarget)
  Float Total = calculateWeightWeighting(akTarget, TargetData)
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
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  String Highlight
  If asValue == "Enable"
    HighLight = "Enables actors to gain or lose weight."
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
      Highlight = "Set how much " + ValueKeys[1] + " affects weight"
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
    EndIf
  EndIf
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

Float Function calculateWeightWeighting(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  String i = JMap.nextKey(JM_ActorValueWeights)
  Float WeightRating
  While i
    If i == "Level"
      WeightRating += akTarget.GetLevel() * JMap.getFlt(JM_ActorValueWeights, i)
    Else
      ;WeightRating += akTarget.GetActorValueMax(i) * JMap.getFlt(JM_ActorValueWeights, i)  ;Use this for SSE
      WeightRating += akTarget.GetBaseActorValue(i) * JMap.getFlt(JM_ActorValueWeights, i)
    EndIf
    i = JMap.nextKey(JM_ActorValueWeights, i)
  EndWhile
  Return WeightRating
EndFunction
