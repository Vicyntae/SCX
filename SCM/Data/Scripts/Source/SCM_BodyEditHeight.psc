ScriptName SCM_BodyEditHeight Extends SCX_BaseBodyEdit

SCM_Library Property SCMLib Auto
SCM_Settings Property SCMSet Auto
Spell Property SCM_BodyEditHeightSpell Auto

GlobalVariable Property SCX_BodyEditHeightEnable Auto
Function reloadMaintenence()
  SCX_BodyEditHeightEnable.SetValueInt(0)
  Utility.Wait(5)
  SCX_BodyEditHeightEnable.SetValueInt(1)
EndFunction

Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If EnableMorph
    SCX_BodyEditHeightEnable.SetValueInt(1)
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

    JMap.setFlt(TargetData, "SCM_BodyEditHeightTargetValue", afValue)
    If !akTarget.HasSpell(SCM_BodyEditHeightSpell)
      akTarget.AddSpell(SCM_BodyEditHeightSpell, True)
    EndIf
    Int Handle = ModEvent.Create("SCM_BodyEditHeightSpellUpdate")
    ModEvent.PushForm(Handle, akTarget)
    ModEvent.PushBool(Handle, False)
    ModEvent.send(Handle)
  Else
    SCX_BodyEditHeightEnable.SetValueInt(0)
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

  JMap.setFlt(TargetData, "SCM_BodyEditHeightTargetValue", afValue)
  If !akTarget.HasSpell(SCM_BodyEditHeightSpell)
    akTarget.AddSpell(SCM_BodyEditHeightSpell, False)
  EndIf
  Int Handle = ModEvent.Create("SCM_BodyEditHeightSpellUpdate")
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushBool(Handle, True)
  ModEvent.send(Handle)
EndFunction

Function updateBodyPart(Actor akTarget, Bool abRapid = False)
  Int TargetData = SCXLib.getTargetData(akTarget)
  Float Total = calculateHeightRating(akTarget, TargetData)
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
  JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption(Name + "Enable", EnableMorph), "BodyEdit." + asEdit + ".Enable")
  ;JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Methods", CurrentMethod), "BodyEdit." + asEdit + "." + "Methods")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Minimum", Minimum, "{1}"), "BodyEdit." + asEdit + "." + "Minimum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Maximum", Maximum, "{1}"), "BodyEdit." + asEdit + "." + "Maximum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Curve", Curve, "{1}"), "BodyEdit." + asEdit + "." + "Curve")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Multiplier", Multiplier, "{1}"), "BodyEdit." + asEdit + "." + "Multiplier")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Increment", Increment, "{1}"), "BodyEdit." + asEdit + "." + "Increment")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption(Name + " Enable Increment", EnableIncrement), "BodyEdit." + asEdit + "." + "EnableIncrement")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption("Height Weighting", HeightWeighting, "{2}"), "BodyEdit." + asEdit + ".HeightWeighting")

  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption("Health", HealthRating, "{2}"), "BodyEdit." + asEdit + ".Stat-Health")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption("Stamina", StaminaRating, "{2}"), "BodyEdit." + asEdit + ".Stat-Stamina")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption("Magicka", MagickaRating, "{2}"), "BodyEdit." + asEdit + ".Stat-Magicka")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption("Level", LevelRating, "{2}"), "BodyEdit." + asEdit + ".Stat-Level")

  String i = JMap.nextKey(JM_ActorValueRatings)
  While i
    JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(i, JMap.getFlt(JM_ActorValueRatings, i), "{0}"), "BodyEdit." + asEdit + ".Stat-" + i)
    i = JMap.nextKey(JM_ActorValueRatings, i)
  EndWhile
  ;/JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption("Preset", SelectedPreset), "BodyEdit." + asEdit + "." + "PresetSelect")

  String[] PresetList = MiscUtil.FilesInFolder("data/SCX/Presets/")
  If SelectedPreset
    Int Preset = JValue.readFromFile("Data/SCX/Presets/" + SelectedPreset)
    JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption("Edit Preset", EditingPreset), "BodyEdit." + asEdit + ".PresetEnableEdit")
    If EditingPreset
      JIntMap.setStr(JI_OptionIndexes, MCM.AddInputOption("Save Preset", SelectedPreset), "BodyEdit." + asEdit + "." + "PresetSave")
      MCM.AddEmptyOption()
    EndIf
    i = JMap.nextKey(Preset)
    While i
      If EditingPreset
        JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(i, JMap.getFlt(Preset, i), "{2}"), "BodyEdit." + asEdit + ".PresetEdit")
      Else
        JIntMap.setStr(JI_OptionIndexes, MCM.AddTextOption(i, JMap.getFlt(Preset, i)), "BodyEdit." + asEdit + ".PresetView-" + i)
      EndIf
      i = JMap.nextKey(Preset, i)
    EndWhile
  Else
    MCM.AddTextOption("Select Preset to view/edit", "")
  EndIf/;
  ;/If SCXSet.DebugEnable
    JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Collection Keys", ""), "BodyEdit." + asEdit + "." + "ShowCollectionKeys")
    ;JIntMap.setStr(JI_OptionIndexes, AddInputOption(Name + "Add New Collection Key", ""), "BodyEdit." + asEdit + "." + "AddCollectionKey")
    MCM.AddEmptyOption()

    JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Creature Races", ""), "BodyEdit." + asEdit + "." + "ShowCreatureRaces")
    JIntMap.setStr(JI_OptionIndexes, MCM.AddTextOption(Name + " Add Selected Actor's Race", ""), "BodyEdit." + asEdit + "." + "AddCreatureRace")
  EndIf/;
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  String Highlight
  If asValue == "Enable"
    HighLight = "Enables actors to gain or lose height."
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
  ElseIf asValue == "HeightWeighting"
    Highlight = "Sets how much height is affected"
  Else
    String[] ValueKeys = StringUtil.Split(asValue, "-")
    If ValueKeys[0] == "Stat"
      Highlight = "Set how much " + ValueKeys[1] + " affects height"
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
    ValueArray[4] = 1000
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
  ElseIf asValue == "HeightWeighting"
    ValueArray[0] = HeightWeighting
    ValueArray[1] = 1
    ValueArray[2] = 0.1
    ValueArray[3] = -5
    ValueArray[4] = 5
  Else
    String[] ValueKeys = StringUtil.Split(asValue, "-")
    If ValueKeys[0] == "Stat"
      If ValueKeys[1] == "Health"
        ValueArray[0] = HealthRating
        ValueArray[1] = 0
        ValueArray[2] = 0.01
        ValueArray[3] = -5
        ValueArray[4] = 2
      ElseIf ValueKeys[1] == "Stamina"
        ValueArray[0] = StaminaRating
        ValueArray[1] = 0
        ValueArray[2] = 0.01
        ValueArray[3] = -5
        ValueArray[4] = 2
      ElseIf ValueKeys[1] == "Magicka"
        ValueArray[0] = MagickaRating
        ValueArray[1] = 0
        ValueArray[2] = 0.01
        ValueArray[3] = -5
        ValueArray[4] = 2
      Else
        ValueArray[0] = JMap.getFlt(JM_ActorValueRatings, ValueKeys[1])
        ValueArray[1] = 0
        ValueArray[2] = 0.1
        ValueArray[3] = -5
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
  ElseIf asValue == "HeightWeighting"
    HeightWeighting = afValue
  Else
    String[] ValueKeys = StringUtil.Split(asValue, "-")
    If ValueKeys[1] == "Health"
      HealthRating = afValue
    ElseIf ValueKeys[1] == "Stamina"
      StaminaRating = afValue
    ElseIf ValueKeys[1] == "Magicka"
      MagickaRating = afValue
    ElseIf ValueKeys[1] == "Level"
      LevelRating = afValue
    Else
      If JMap.hasKey(JM_ActorValueRatings, ValueKeys[1])
        JMap.setFlt(JM_ActorValueRatings, ValueKeys[1], afValue)
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
Float Property HealthRating Auto
Float Property StaminaRating Auto
Float Property MagickaRating Auto
Float Property LevelRating Auto
Float Property HeightWeighting Auto

Int _JM_ActorValueRating
Int Property JM_ActorValueRatings
  Int Function Get()
    If !JValue.isExists(_JM_ActorValueRating) || !JValue.isMap(_JM_ActorValueRating)
      _JM_ActorValueRating = JValue.retain(JMap.object())
      JMap.setFlt(_JM_ActorValueRating, "OneHanded", 0)
      JMap.setFlt(_JM_ActorValueRating, "TwoHanded", 0)
      JMap.setFlt(_JM_ActorValueRating, "Marksman", 0)
      JMap.setFlt(_JM_ActorValueRating, "Block", 0)
      JMap.setFlt(_JM_ActorValueRating, "Smithing", 0)
      JMap.setFlt(_JM_ActorValueRating, "HeavyArmor", 0)
      JMap.setFlt(_JM_ActorValueRating, "LightArmor", 0)
      JMap.setFlt(_JM_ActorValueRating, "Pickpocket", 0)
      JMap.setFlt(_JM_ActorValueRating, "Lockpicking", 0)
      JMap.setFlt(_JM_ActorValueRating, "Sneak", 0)
      JMap.setFlt(_JM_ActorValueRating, "Alchemy", 0)
      JMap.setFlt(_JM_ActorValueRating, "Speechcraft", 0)
      JMap.setFlt(_JM_ActorValueRating, "Alteration", 0)
      JMap.setFlt(_JM_ActorValueRating, "Conjuration", 0)
      JMap.setFlt(_JM_ActorValueRating, "Destruction", 0)
      JMap.setFlt(_JM_ActorValueRating, "Illusion", 0)
      JMap.setFlt(_JM_ActorValueRating, "Restoration", 0)
      JMap.setFlt(_JM_ActorValueRating, "Enchanting", 0)
    EndIf
    Return _JM_ActorValueRating
  EndFunction
EndProperty

Float Function calculateHeightRating(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  String i = JMap.nextKey(JM_ActorValueRatings)
  Float HeightRating
  While i
    HeightRating += akTarget.GetBaseActorValue(i) * JMap.getFlt(JM_ActorValueRatings, i)
    i = JMap.nextKey(JM_ActorValueRatings, i)
  EndWhile
  If HealthRating != 0
    HeightRating += akTarget.GetBaseActorValue("Health") * HealthRating  ;Use this for LE
    ;HeightRating += akTarget.GetActorValueMax("Health") * HealthRating  ;Use this for SSE
  EndIf

  If StaminaRating != 0
    HeightRating += akTarget.GetBaseActorValue("Health") * StaminaRating  ;Use this for LE
    ;HeightRating += akTarget.GetActorValueMax("Health") * StaminaRating  ;Use this for SSE
  EndIf

  If MagickaRating != 0
    HeightRating += akTarget.GetBaseActorValue("Health") * MagickaRating  ;Use this for LE
    ;HeightRating += akTarget.GetActorValueMax("Health") * MagickaRating  ;Use this for SSE
  EndIf
  If LevelRating != 0
    HeightRating += akTarget.GetLevel() * LevelRating
  EndIf
  Return HeightRating
EndFunction
