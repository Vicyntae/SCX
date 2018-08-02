ScriptName SCX_BaseBodyEdit Extends SCX_BaseRefAlias Hidden

String Property UIName Auto
String[] Property CollectKeys Auto ;Array of values whose values will increase size

String Property AppliedSizeKey Auto

Int[] Property EquipmentList Auto ;Array of JIntMaps containing each armor list
String Property EquipmentSetKey Auto ;Where the currently equipped set is.
String Property EquipmentTierKey Auto

String[] Property Methods Auto  ;List of methods available for this type

Form[] Property CreatureRaces Auto

Float Property Multiplier = 1.0 Auto

Float Property Increment = 0.5 Auto
Bool Property EnableIncrement = True Auto
Float Property IncrementRate = 2.0 Auto

Float Property Minimum = 1.0 Auto
Float Property Maximum = 100.0 Auto
Float Property Curve = 1.75 Auto
Float Property HighScale = -0.5 Auto

String Property MethodKey Auto  ;Stores applied method to this key in ActorData
String Property CurrentMethod Auto  ;Method chosen for new actors. Can set in MCM
String Property DefaultMethod Auto  ;Default in MCM

Int Function _getSCX_JC_List()
  Return SCXSet.JM_BaseBodyEdits
EndFunction

Armor Function getEquipment(Int aiSet, Int aiTier)
  Int JI_EquipSetList = EquipmentList[aiSet]
  Return JIntMap.getForm(JI_EquipSetList, aiTier) as Armor
EndFunction

Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
EndFunction

Function updateBodyPart(Actor akTarget)
  Int TargetData = SCXLib.getTargetData(akTarget)
  Int i = CollectKeys.length
  Float Total = 1
  While i
    i -= 1
    Total += JMap.getFlt(TargetData, CollectKeys[i])
  EndWhile
  editBodyPart(akTarget, Total)
EndFunction

Int Function findEquipTier(Int aiSet, Float fValue)
  {Binary Search Algorithm
  See https://en.wikipedia.org/wiki/Binary_search_algorithm}
  Int JI_EquipSetList = EquipmentList[aiSet]
  Int NumArmors = JIntMap.count(JI_EquipSetList)
  If NumArmors == 1
    Return JIntMap.getNthKey(JI_EquipSetList, 0)
  ElseIf NumArmors == 0
    Return 0
  EndIf
  Int L = 0
  Int R = JIntMap.count(JI_EquipSetList) - 1
  While L < R
    Int m = Math.floor((L + R) / 2)
    Float s = (JIntMap.getForm(JI_EquipSetList, m) as SCX_BaseEquipment).Threshold
    If s < fValue
      L = m + 1
    ElseIf s > fValue
      R = m - 1
    ElseIf s == fValue
      Return m
    Endif
  EndWhile
  Return L
EndFunction

Float Function curveValue(Float afValue)
  {Edits value to simulate volume}
  If afValue <= 1
    Return afValue
  EndIf

  If Curve == 2
    Return afValue
  EndIf

  Return (Math.sqrt(Math.pow((afValue - 1), Curve)) * (Curve / 2)) + 1
EndFunction

Int[] Function getMCMMenuOptions01(SCX_ModConfigMenu MCM, String asValue)
  If asValue == "Methods"
    Int[] ValueArray = New Int[2]
    ValueArray[0] == Methods.find(CurrentMethod)
    ValueArray[1] == Methods.find(DefaultMethod)
    Return ValueArray
  ElseIf asValue == "ShowCollectionKeys"
    Int[] ValueArray = New Int[2]
    ValueArray[0] == 0
    ValueArray[1] == 0
    Return ValueArray
  ElseIf asValue == "ShowCreatureRaces"
    Int[] ValueArray = New Int[2]
    ValueArray[0] == 0
    ValueArray[1] == 0
    Return ValueArray
  EndIf
EndFunction

String[] Function getMCMMenuOptions02(SCX_ModConfigMenu MCM, String asValue)
  If asValue == "Methods"
    return Methods
  ElseIf asValue == "ShowCollectionKeys"
    Return CollectKeys
  ElseIf asValue == "ShowCreatureRaces"
    Int NumRaces = CreatureRaces.length
    String[] RaceNames = Utility.CreateStringArray(NumRaces, "")
    Int i = 0
    While i < NumRaces
      RaceNames[i] = CreatureRaces[i].GetName()
      i += 1
    EndWhile
    Return RaceNames
  EndIf
EndFunction

Function setMenuOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Int aiIndex)
  If asValue == "Methods"
    CurrentMethod = Methods[aiIndex]
    MCM.SetMenuOptionValue(aiOption, CurrentMethod)
  ElseIf asValue == "ShowCollectionKeys"
    String DeleteKey = CollectKeys[aiIndex]
    If MCM.ShowMessage("DEBUG: Are you sure you want to delete collection key " + DeleteKey + "? Don't select this if you don't know what you're doing!", true, "Yes, I'm sure.", "No, go back!")
      CollectKeys[aiIndex] = ""
      CollectKeys = PapyrusUtil.ClearEmpty(CollectKeys)
    EndIf
  ElseIf asValue == "ShowCreatureRaces"
    Race DeleteRace = CreatureRaces[aiIndex] as Race
    If MCM.ShowMessage("DEBUG: Are you sure you want to delete race " + DeleteRace.GetName() + "? Don't select this if you don't know what you're doing!", true, "Yes, I'm sure.", "No, go back!")
      PapyrusUtil.RemoveForm(CreatureRaces, DeleteRace)
    EndIf
  EndIf
EndFunction

Float[] Function getSliderOptions(SCX_ModConfigMenu MCM, String asValue)
{Set to recommended default values.}
  Float[] ValueArray = New Float[5]
  If asValue == "Minimum"
    ValueArray[0] = Minimum
    ValueArray[1] = 1
    ValueArray[2] = 0.5
    ValueArray[3] = 0
    ValueArray[4] = 10
  ElseIf asValue == "Maximum"
    ValueArray[0] = Maximum
    ValueArray[1] = 100
    ValueArray[2] = 0.5
    ValueArray[3] = 0
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
  ElseIf asValue == "HighScale"
    ValueArray[0] = HighScale
    ValueArray[1] = 0
    ValueArray[2] = 0.1
    ValueArray[3] = -5
    ValueArray[4] = 5
  ElseIf asValue == "Increment"
    ValueArray[0] = Increment
    ValueArray[1] = 0.5
    ValueArray[2] = 0.1
    ValueArray[3] = 0.1
    ValueArray[4] = 2
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
  EndIf
  MCM.SetSliderOptionValue(aiOption, afValue, "{2}")
EndFunction

Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "EnableIncrement"
    EnableIncrement = !EnableIncrement
    MCM.SetToggleOptionValue(aiOption, EnableIncrement)
  ElseIf asValue == "AddCreatureRace"
    Race SelectedRace = MCM.SelectedActor.GetRace()
    If !MCM.SelectedActor.HasKeyword(SCXSet.ActorTypeNPC) && CreatureRaces.find(SelectedRace) == -1
      If MCM.ShowMessage("DEBUG: Are you sure you want to add new creature race " + MCM.SelectedActor.GetRace().GetName() + "? Don't select this if you don't know what you're doing!", true, "Yes, I'm sure.", "No, go back!")
        PapyrusUtil.PushForm(CreatureRaces, MCM.SelectedActor.GetRace())
      EndIf
    Else
      MCM.ShowMessage("Selected actor race is already on list!", False, "Okay", "")
    EndIf
  EndIf
EndFunction

Function setInputOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, String asInput)
  If asValue == "AddCollectionKey"
    If CollectKeys.find(asInput) == -1
      If MCM.ShowMessage("DEBUG: Are you sure you want to add new collection key " + asInput + "? Don't select this if you don't know what you're doing!", true, "Yes, I'm sure.", "No, go back!")
        CollectKeys = PapyrusUtil.PushString(CollectKeys, asInput)
      EndIf
    Else
      MCM.ShowMessage("Inputted collection key is already on list!", False, "Okay", "")
    EndIf
  EndIf
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  String Highlight
  If asValue == "Minimum"
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
  EndIf
  MCM.setInfoText(HighLight)
EndFunction

Function addMCMOptions(SCX_ModConfigMenu MCM, Int JI_OptionIndexes)
  String Name = UIName
  String asEdit = _getStrKey()
  JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Methods", CurrentMethod), "BodyEdit." + asEdit + "." + "Methods")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Minimum", Minimum, "{1}"), "BodyEdit." + asEdit + "." + "Minimum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Maximum", Maximum, "{1}"), "BodyEdit." + asEdit + "." + "Maximum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Curve", Curve, "{1}"), "BodyEdit." + asEdit + "." + "Curve")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Multiplier", Multiplier, "{1}"), "BodyEdit." + asEdit + "." + "Multiplier")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " High Scale", HighScale, "{1}"), "BodyEdit." + asEdit + "." + "HighScale")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Increment", Increment, "{1}"), "BodyEdit." + asEdit + "." + "Increment")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption(Name + " Enable Increment", EnableIncrement), "BodyEdit." + asEdit + "." + "EnableIncrement")
  If SCXSet.DebugEnable
    JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + "Collection Keys", ""), "BodyEdit." + asEdit + "." + "ShowCollectionKeys")
    ;JIntMap.setStr(JI_OptionIndexes, AddInputOption(Name + "Add New Collection Key", ""), "BodyEdit." + asEdit + "." + "AddCollectionKey")
    MCM.AddEmptyOption()

    JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + "Creature Races", ""), "BodyEdit." + asEdit + "." + "ShowCreatureRaces")
    JIntMap.setStr(JI_OptionIndexes, MCM.AddTextOption(Name + "Add Selected Actor's Race", ""), "BodyEdit." + asEdit + "." + "AddCreatureRace")
  EndIf
EndFunction
