ScriptName SCX_BaseBodyEdit Extends SCX_BaseRefAlias Hidden

String Property UIName Auto
String[] Property CollectKeys Auto ;Array of values whose values will increase size

String Property AppliedSizeKey Auto

Int[] Property EquipmentList Auto ;Array of JIntMaps containing each armor list
String Property EquipmentSetKey Auto ;Where the currently equipped set is.
String Property EquipmentTierKey Auto

String[] Property Methods Auto  ;List of methods available for this type

Form[] Property CreatureRaces Auto

;Profile Settings **************************************************************
Float Property Multiplier
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "Multiplier")
      JMap.setFlt(JM_Settings, "Multiplier", 1)
    EndIf
    Return JMap.getFlt(JM_Settings, "Multiplier")
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      JMap.setFlt(JM_Settings, "Multiplier", a_val)
    EndIf
  EndFunction
EndProperty

Float Property Increment
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "Increment")
      JMap.setFlt(JM_Settings, "Increment", 0.5)
    EndIf
    Return JMap.getFlt(JM_Settings, "Increment")
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      JMap.setFlt(JM_Settings, "Increment", a_val)
    EndIf
  EndFunction
EndProperty

Bool Property EnableIncrement
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableIncrement")
      JMap.setInt(JM_Settings, "EnableIncrement", 1)
    EndIf
    Return JMap.getInt(JM_Settings, "EnableIncrement") as Bool
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableIncrement", 1)
    Else
      JMap.setInt(JM_Settings, "EnableIncrement", 0)
    EndIf
  EndFunction
EndProperty

Float Property IncrementRate
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "IncrementRate")
      JMap.setFlt(JM_Settings, "IncrementRate", 2)
    EndIf
    Return JMap.getFlt(JM_Settings, "IncrementRate")
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      JMap.setFlt(JM_Settings, "IncrementRate", a_val)
    EndIf
  EndFunction
EndProperty

Float Property Minimum
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "Minimum")
      JMap.setFlt(JM_Settings, "Minimum", 1)
    EndIf
    Return JMap.getFlt(JM_Settings, "Minimum")
  EndFunction
  Function Set(Float a_val)
    JMap.setFlt(JM_Settings, "Minimum", a_val)
    If Maximum < a_val
      Maximum = a_val
    EndIf
  EndFunction
EndProperty

Float Property Maximum
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "Maximum")
      JMap.setFlt(JM_Settings, "Maximum", 100)
    EndIf
    Return JMap.getFlt(JM_Settings, "Maximum")
  EndFunction
  Function Set(Float a_val)
    JMap.setFlt(JM_Settings, "Maximum", a_val)
    If Minimum > a_val
      Minimum = a_val
    EndIf
  EndFunction
EndProperty

Float Property Curve
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "Curve")
      JMap.setFlt(JM_Settings, "Curve", 1.75)
    EndIf
    Return JMap.getFlt(JM_Settings, "Curve")
  EndFunction
  Function Set(Float a_val)
    JMap.setFlt(JM_Settings, "Curve", a_val)
  EndFunction
EndProperty

Float Property HighScale
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "HighScale")
      JMap.setFlt(JM_Settings, "HighScale", -0.5)
    EndIf
    Return JMap.getFlt(JM_Settings, "HighScale")
  EndFunction
  Function Set(Float a_val)
    JMap.setFlt(JM_Settings, "HighScale", a_val)
  EndFunction
EndProperty

String Property CurrentMethod  ;Method chosen for new actors. Can set in MCM
  String Function Get()
    If !JMap.hasKey(JM_Settings, "CurrentMethod")
      JMap.setStr(JM_Settings, "CurrentMethod", DefaultMethod)
    EndIf
    Return JMap.getStr(JM_Settings, "CurrentMethod")
  EndFunction
  Function Set(String a_val)
    JMap.setStr(JM_Settings, "CurrentMethod", a_val)
  EndFunction
EndProperty

String Property MethodKey Auto  ;Stores applied method to this key in ActorData
String Property DefaultMethod Auto  ;Default in MCM

Function _reloadMaintenence()
  RegisterForModEvent("SCX_BuildBodyEdits", "OnBodyEditListBuild")
EndFunction

Event OnBodyEditListBuild()
  If SCXSet
    Int JC_Container = _getSCX_JC_List()
    If JC_Container
      If JValue.isMap(JC_Container)
        String ListKey = _getStrKey()
        If ListKey
          JMap.setForm(JC_Container, _getStrKey(), GetOwningQuest())
        Else
          Issue("Quest " + GetName() + "has JC_List but lacks StringKey!", 1)
        EndIf
      ElseIf JValue.isIntegerMap(JC_Container)
        Int ListKey = _getIntKey()
        If ListKey
          JIntMap.setForm(JC_Container, _getIntKey(), GetOwningQuest())
        Else
          Issue("Quest " + GetName() + "has JC_List but lacks IntKey!", 1)
        EndIf
      EndIf
    Else
      ;Notice("JC_List not available for quest " + GetName() + ".")
    EndIf
    JMap.setForm(SCXSet.JM_RefAliasList, _getStrKey(), GetOwningQuest())
  Else
    Issue("SCX_Settings wasn't found! Please check SCX Installation", 2, True)
  EndIf
EndEvent

Int Function _getSCX_JC_List()
  Return SCXSet.JM_BaseBodyEdits
EndFunction

String _CurrentProfileKey
String Property CurrentProfileKey
  String Function Get()
    If !_CurrentProfileKey
      _CurrentProfileKey = JMap.getNthKey(JM_ProfileList, 0)
      JM_Settings = JMap.getObj(JM_ProfileList, _CurrentProfileKey)
    EndIf
    If !_CurrentProfileKey
      Int DefaultProfile = JMap.object()
      JValue.writeToFile(DefaultProfile, "Data/SCX/" + _getStrKey() + "/Profiles/DefaultProfile.json")
      _CurrentProfileKey = "DefaultProfile.json"
      JM_Settings = JMap.getObj(JM_ProfileList, _CurrentProfileKey)
    EndIf
    Return _CurrentProfileKey
  EndFunction
  Function Set(String a_val)
    saveProfile()
    _CurrentProfileKey = a_val
    JM_Settings = JMap.getObj(JM_ProfileList, _CurrentProfileKey)
  EndFunction
EndProperty

Int Property JM_ProfileList
  Int Function Get()
    Return JValue.readFromDirectory("Data/SCX/" + _getStrKey() + "/Profiles/", ".json")
  EndFunction
EndProperty

Int _JM_Settings
Int Property JM_Settings
  Int Function get()
    Return _JM_Settings
  EndFunction
  Function set(Int a_val)
    _JM_Settings = JValue.releaseAndRetain(_JM_Settings, a_val)
  EndFunction
EndProperty

Function saveProfile()
  JValue.writeToFile(JM_Settings, "Data/SCX/" + _getStrKey() + "/Profiles/" + CurrentProfileKey)
EndFunction

String Function getInputStartText(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "CreateProfile"
    Return ".json"
  EndIf
EndFunction

Armor Function getEquipment(Int aiSet, Int aiTier)
  Int JI_EquipSetList = EquipmentList[aiSet]
  Return JIntMap.getForm(JI_EquipSetList, aiTier) as Armor
EndFunction

Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
EndFunction

Function rapidEdit(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
EndFunction

Function updateBodyPart(Actor akTarget, Bool abRapid = False)
  Int TargetData = SCXLib.getTargetData(akTarget)
  Int i = CollectKeys.length
  Float Total = 1
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
    Float s = (JIntMap.getForm(JI_EquipSetList, m) as SCX_BaseEquipment).Thresholds[0]
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
  ElseIf asValue == "SelectProfile"
    Int[] ValueArray = New Int[2]
    ValueArray[0] = JMap.allKeysPArray(JM_ProfileList).find(CurrentProfileKey)
    ValueArray[1] = 0
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
  ElseIf asValue == "SelectProfile"
    Return JMap.allKeysPArray(JM_ProfileList)
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
  ElseIf asValue == "SelectProfile"
    saveProfile()
    CurrentProfileKey = JMap.getNthKey(JM_ProfileList, aiIndex)
    MCM.ForcePageReset()
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
  saveProfile()
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
  saveProfile()
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
  ElseIf asValue == "CreateProfile"
    saveProfile()
    Int NewProfile = JMap.object()
    JMap.addPairs(NewProfile, JM_Settings, False)
    JValue.writeToFile(NewProfile, "Data/SCX/" + _getStrKey() + "/Profiles/" + asInput)
    CurrentProfileKey = asInput
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
    HighLight = "Sets how the change is implemented."
  ElseIf asValue == "SelectProfile"
    Highlight == "Select profile to use (Profiles are stored in Data/SCX/" + _getStrKey() + "/Profiles)."
  ElseIf asValue == "CreateProfile"
    HighLight == "Create new profile based off the current profile."
  EndIf
  MCM.setInfoText(HighLight)
EndFunction

Function addMCMOptions(SCX_ModConfigMenu MCM, Int JI_OptionIndexes)
  String Name = UIName
  String asEdit = _getStrKey()
  JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption("Profile", CurrentProfileKey), "BodyEdit." + asEdit + "." + "SelectProfile")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddInputOption("Create New Profile", ""), "BodyEdit." + asEdit + "." + "CreateProfile")

  JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Methods", CurrentMethod), "BodyEdit." + asEdit + "." + "Methods")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Minimum", Minimum, "{1}"), "BodyEdit." + asEdit + "." + "Minimum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Maximum", Maximum, "{1}"), "BodyEdit." + asEdit + "." + "Maximum")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Curve", Curve, "{1}"), "BodyEdit." + asEdit + "." + "Curve")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Multiplier", Multiplier, "{1}"), "BodyEdit." + asEdit + "." + "Multiplier")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " High Scale", HighScale, "{1}"), "BodyEdit." + asEdit + "." + "HighScale")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddSliderOption(Name + " Increment", Increment, "{1}"), "BodyEdit." + asEdit + "." + "Increment")
  JIntMap.setStr(JI_OptionIndexes, MCM.AddToggleOption(Name + " Enable Increment", EnableIncrement), "BodyEdit." + asEdit + "." + "EnableIncrement")
  If SCXSet.DebugEnable
    JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Collection Keys", ""), "BodyEdit." + asEdit + "." + "ShowCollectionKeys")
    ;JIntMap.setStr(JI_OptionIndexes, AddInputOption(Name + "Add New Collection Key", ""), "BodyEdit." + asEdit + "." + "AddCollectionKey")
    MCM.AddEmptyOption()

    JIntMap.setStr(JI_OptionIndexes, MCM.AddMenuOption(Name + " Creature Races", ""), "BodyEdit." + asEdit + "." + "ShowCreatureRaces")
    JIntMap.setStr(JI_OptionIndexes, MCM.AddTextOption(Name + " Add Selected Actor's Race", ""), "BodyEdit." + asEdit + "." + "AddCreatureRace")
  EndIf
EndFunction
