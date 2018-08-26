ScriptName SCX_ModConfigMenu Extends SKI_ConfigBase

SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
Actor Property PlayerRef Auto
Int Property SelectedData Auto
String Property SelectedActorName Auto
Actor _SelectedActor
Actor Property SelectedActor
  Actor Function Get()
    Return _SelectedActor
  EndFunction
  Function Set(Actor a_Actor)
    _SelectedActor = a_Actor
    If a_Actor
      SelectedData = SCXLib.getTargetData(a_Actor, True)
      SelectedActorName = a_Actor.GetLeveledActorBase().GetName()
    Else
      SelectedData = 0
      SelectedActorName = ""
    EndIf
  EndFunction
EndProperty

Event OnConfigInit()
  Pages = new String[5]
  Pages[0] = "$SCXMCMActorInformationPage"
  Pages[1] = "$SCXMCMActorPerksPage"
  Pages[2] = "$SCXMCMActorRecordsPage"
  Pages[3] = "$SCXMCMInflationSettingsPage"
  Pages[4] = "$SCXMCMOtherSettingsPage"
EndEvent

Int Property JI_OptionIndexes Auto

Event OnPageReset(string a_page)
  JI_OptionIndexes = JValue.releaseAndRetain(JI_OptionIndexes, JIntMap.object())
  If a_page == "$SCXMCMActorInformationPage"
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddMenuOptionST("SelectedActor_M", "$Actor", SelectedActorName)
    AddEmptyOption()
    If SelectedActor
      addStatOptions()
    Else
      AddTextOptionST("ChooseActorMessage_T", "$SCXMCMChooseActorMessage", "")
    EndIf
  ElseIf a_page == "$SCXMCMActorPerksPage"
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddMenuOptionST("SelectedActor_M", "$Actor", SelectedActorName)
    AddEmptyOption()
    If SelectedActor
      addPerkOptions()
    Else
      AddTextOptionST("ChooseActorMessage_T", "$SCXMCMChooseActorMessage", "")
    EndIf
  ElseIf a_page == "$SCXMCMActorRecordsPage"
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddMenuOptionST("SelectedActor_M", "$Actor", SelectedActorName)
    AddEmptyOption()
    If SelectedActor
      addRecordsOptions()
    Else
      AddTextOptionST("ChooseActorMessage_T", "$SCXMCMChooseActorMessage", "")
    EndIf
  ElseIf a_page == "$SCXMCMInflationSettingsPage"
    SetCursorFillMode(LEFT_TO_RIGHT)
    addBodyEditOptions()
  ElseIf a_page == "$SCXMCMOtherSettingsPage"
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddKeyMapOptionST("MenuKeyPick_KM", "$SCXMCMMenuKeyOption_KM", SCXSet.MenuKey)
    AddKeyMapOptionST("StatusKeyPick_KM", "$SCXMCMStatusKeyOption_KM", SCXSet.StatusKey)
    AddToggleOptionST("DebugEnable_TOG", "$SCXMCMDebugEnableOption_TOG", SCXSet.DebugEnable)
  ElseIf a_page
    addOtherOptions(a_page)
  EndIf
EndEvent

State SelectedActor_M
  Event OnMenuOpenST()
    Int NumActors = SCXSet.LoadedActors.length
    Int StartIndex = 0
    String[] ActorNames = Utility.CreateStringArray(NumActors, "")
    Int i = 0
    While i < NumActors
      Actor LoadedActor = SCXSet.LoadedActors[i] as Actor
      If LoadedActor
        If LoadedActor == SelectedActor
          StartIndex = i
        EndIf
        ActorNames[i] = SCXLib.nameGet(LoadedActor)
      EndIf
      i += 1
    EndWhile
    SetMenuDialogOptions(ActorNames)
    SetMenuDialogStartIndex(StartIndex)
    SetMenuDialogDefaultIndex(0)
  EndEvent

  Event OnMenuAcceptST(int a_index)
    SelectedActor = SCXSet.LoadedActors[a_index] as Actor
    ForcePageReset()
  EndEvent

  Event OnDefaultST()
    SelectedActor = PlayerRef
    ForcePageReset()
  EndEvent

  Event OnHighlightST()
    SetInfoText("Which actor?")
  EndEvent
EndState

Int JA_LibraryPriorityList
Function addStatOptions()
  Int JM_MainLibList = SCXSet.JM_BaseLibraryList
  String LibraryName = JMap.nextKey(JM_MainLibList)
  If !JValue.isArray(JA_LibraryPriorityList)
    JA_LibraryPriorityList = JValue.releaseAndRetain(JA_LibraryPriorityList, JArray.object())
    Int JI_PriorityList = JValue.retain(JIntMap.object())
    While LibraryName
      SCX_BaseLibrary Lib = JMap.getForm(JM_MainLibList, LibraryName) as SCX_BaseLibrary
      If Lib
        Int Priority = Lib.addMCMActorInformationPriority
        Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, Priority)
        If !JM_PriorityList
          JM_PriorityList = JMap.object()
          JIntMap.setObj(JI_PriorityList, Priority, JM_PriorityList)
        EndIf
        JMap.setForm(JM_PriorityList, LibraryName, Lib)
      EndIf
      LibraryName = JMap.nextKey(JM_MainLibList, LibraryName)
    EndWhile
    Int i = JIntMap.nextKey(JI_PriorityList)  ;Question: does nextKey actually do it in numerical order?
    While i
      Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, i)
      String LibKey = JMap.nextKey(JM_PriorityList)
      While LibKey
        SCX_BaseLibrary Lib = JMap.getForm(JM_PriorityList, LibKey) as SCX_BaseLibrary
        Lib.addMCMActorInformation(Self, JI_OptionIndexes, SelectedActor, SelectedData)
        JArray.addForm(JA_LibraryPriorityList, Lib)
        LibKey = JMap.nextKey(JM_PriorityList, LibKey)
      EndWhile
      i = JIntMap.nextKey(JI_PriorityList, i)
    EndWhile
    JI_PriorityList = JValue.release(JI_PriorityList)

  Else
    Int i = 0
    Int NumLibs = JArray.count(JA_LibraryPriorityList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_LibraryPriorityList, i) as SCX_BaseLibrary
      If Lib
        Lib.addMCMActorInformation(Self, JI_OptionIndexes, SelectedActor, SelectedData)
      EndIf
      i += 1
    EndWhile
  EndIf
EndFunction

Function addOtherOptions(String asPage)
  Int JM_MainLibList = SCXSet.JM_BaseLibraryList
  String LibraryName = JMap.nextKey(JM_MainLibList)
  While LibraryName
    SCX_BaseLibrary Lib = JMap.getForm(JM_MainLibList, LibraryName) as SCX_BaseLibrary
    If Lib
      Lib.addMCMOtherOptions(Self, JI_OptionIndexes, asPage)
    EndIf
    LibraryName = JMap.nextKey(JM_MainLibList, LibraryName)
  EndWhile
EndFunction

Function addRecordsOptions()
  Int JM_MainLibList = SCXSet.JM_BaseLibraryList
  String LibraryName = JMap.nextKey(JM_MainLibList)
  If !JA_LibraryPriorityList
    JA_LibraryPriorityList = JValue.retain(JArray.object())
    Int JI_PriorityList = JValue.retain(JIntMap.object())
    While LibraryName
      SCX_BaseLibrary Lib = JMap.getForm(JM_MainLibList, LibraryName) as SCX_BaseLibrary
      If Lib
        Int Priority = Lib.addMCMActorInformationPriority
        Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, Priority)
        If !JM_PriorityList
          JM_PriorityList = JMap.object()
          JIntMap.setObj(JI_PriorityList, Priority, JM_PriorityList)
        EndIf
        JMap.setForm(JM_PriorityList, LibraryName, Lib)
      EndIf
      LibraryName = JMap.nextKey(JM_MainLibList, LibraryName)
    EndWhile

    Int i = JIntMap.nextKey(JI_PriorityList)  ;Question: does nextKey actually do it in numerical order?
    While i
      Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, i)
      String LibKey = JMap.nextKey(JM_PriorityList)
      While LibKey
        SCX_BaseLibrary Lib = JMap.getForm(JM_PriorityList, LibKey) as SCX_BaseLibrary
        Lib.addMCMActorRecords(Self, JI_OptionIndexes, SelectedActor, SelectedData)
        JArray.addForm(JA_LibraryPriorityList, Lib)
        LibKey = JMap.nextKey(JM_PriorityList, LibKey)
      EndWhile
      i = JIntMap.nextKey(JI_PriorityList, i)
    EndWhile
    JI_PriorityList = JValue.release(JI_PriorityList)

  Else
    Int i = 0
    Int NumLibs = JArray.count(JA_LibraryPriorityList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_LibraryPriorityList, i) as SCX_BaseLibrary
      If Lib
        Lib.addMCMActorRecords(Self, JI_OptionIndexes, SelectedActor, SelectedData)
      EndIf
      i += 1
    EndWhile
  EndIf
EndFunction

Int Property JM_SelectedPerkLevel Auto
Function addPerkOptions()
  If !JValue.isMap(JM_SelectedPerkLevel)
    JM_SelectedPerkLevel = JValue.retain(JMap.object())
  EndIf
  Int JM_Perks = SCXSet.JM_PerkIDs
  String asPerkID = JMap.nextKey(JM_Perks)
  While asPerkID
    Quest OwnedQuest = JMap.getForm(JM_Perks, asPerkID) as Quest
    If OwnedQuest
      SCX_BasePerk PerkBase = OwnedQuest.GetAliasByName(asPerkID) as SCX_BasePerk
      If PerkBase
        PerkBase.addMCMOptions(Self, JI_OptionIndexes, JM_SelectedPerkLevel)
      EndIf
    EndIF
    asPerkID = JMap.nextKey(JM_Perks, asPerkID)
  EndWhile
EndFunction

Function addBodyEditOptions()
  Int JM_BodyEditList = SCXSet.JM_BaseBodyEdits
  String asEdit = JMap.nextKey(JM_BodyEditList)
  While asEdit
    Quest OwnedQuest = JMap.getForm(JM_BodyEditList, asEdit) as Quest
    If OwnedQuest
      SCX_BaseBodyEdit EditBase = OwnedQuest.GetAliasByName(asEdit) as SCX_BaseBodyEdit
      If EditBase
        EditBase.addMCMOptions(Self, JI_OptionIndexes)
      EndIf
    EndIf
    asEdit = JMap.nextKey(JM_BodyEditList, asEdit)
  EndWhile
EndFunction

Event OnOptionSliderOpen(int a_option)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  Float[] Values
  String Type = KeyCodes[0]
  If Type == "Stats" || Type == "Records" || Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Values = Lib.getSliderOptions(Self, KeyCodes[2])
  ElseIf Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    Values = BodyEdit.getSliderOptions(Self, KeyCodes[2])
  EndIf
  SetSliderDialogStartValue(Values[0])
  SetSliderDialogDefaultValue(Values[1])
  SetSliderDialogInterval(Values[2])
  SetSliderDialogRange(Values[3], Values[4])
EndEvent

Event OnOptionSliderAccept(int a_option, float a_value)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "Stats" || Type == "Records" || Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Lib.setSliderOptions(Self, KeyCodes[2], a_option, a_value)
  ElseIf Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    BodyEdit.setSliderOptions(Self, KeyCodes[2], a_option, a_value)
  ;ElseIf Type == "Whatever"
  EndIf
EndEvent

Event OnOptionMenuOpen(int a_option)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "Stats" || Type == "Records" || Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Int[] Values = Lib.getMCMMenuOptions01(Self, KeyCodes[2])
    SetMenuDialogStartIndex(Values[0])
    SetMenuDialogDefaultIndex(Values[1])
    SetMenuDialogOptions(Lib.getMCMMenuOptions02(Self, KeyCodes[2]))
  ElseIf Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    Int[] Values = BodyEdit.getMCMMenuOptions01(Self, KeyCodes[2])
    SetMenuDialogStartIndex(Values[0])
    SetMenuDialogDefaultIndex(Values[1])
    SetMenuDialogOptions(BodyEdit.getMCMMenuOptions02(Self, KeyCodes[2]))
  ElseIf Type == "Perk"
    SCX_BasePerk PerkBase = SCXLib.getSCX_BaseAlias(SCXSet.JM_PerkIDs, KeyCodes[1]) as SCX_BasePerk
    If KeyCodes[2] == "Taken"
      Int CurrentPerkValue = PerkBase.getPerkLevel(SelectedActor)
      String[] EntryArray = Utility.CreateStringArray(CurrentPerkValue + 1, "")
      Int i = 0
      While i <= CurrentPerkValue
        EntryArray[i] = PerkBase.getPerkName(i)
        i += 1
      EndWhile
      SetMenuDialogStartIndex(JMap.getInt(JM_SelectedPerkLevel, KeyCodes[1], 1))
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(EntryArray)
    EndIf
  EndIf
EndEvent

Event OnOptionMenuAccept(int a_option, int a_index)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "Stats" || Type == "Records" || Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Lib.setMenuOptions(Self, KeyCodes[2], a_option, a_index)
  ElseIf Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    BodyEdit.setMenuOptions(Self, KeyCodes[2], a_option, a_index)
  ElseIf Type == "Perk"
    JMap.setInt(JM_SelectedPerkLevel, KeyCodes[1], a_index)
  EndIf
EndEvent

Event OnOptionInputOpen(int a_option)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "BodyEdit"
    ;Pass
  EndIf
EndEvent

Event OnOptionInputAccept(int a_option, string a_input)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    BodyEdit.setInputOptions(Self, KeyCodes[2], a_option, a_input)
  ElseIf Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Lib.setInputOptions(Self, KeyCodes[2], a_option, a_input)
  EndIf
EndEvent

Event OnOptionSelect(int a_option)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "Stats" || Type == "Records" || Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Lib.setSelectOptions(Self, KeyCodes[2], a_option)
  ElseIf Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    BodyEdit.setSelectOptions(Self, KeyCodes[2], a_option)
  ElseIf Type == "Perk"
    SCX_BasePerk PerkBase = SCXLib.getSCX_BaseAlias(SCXSet.JM_PerkIDs, KeyCodes[1]) as SCX_BasePerk
    PerkBase.setMCMSelectOptions(Self, KeyCodes[2], a_option)
  EndIf
EndEvent

Event OnOptionHighlight(int a_option)
  String KeyList = JIntMap.getStr(JI_OptionIndexes, a_option)
  String[] KeyCodes = StringUtil.Split(KeyList, ".")
  String Type = KeyCodes[0]
  If Type == "Stats" || Type == "Records" || Type == "LibOther"
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, KeyCodes[1]) as SCX_BaseLibrary
    Lib.setHighlight(Self, KeyCodes[2], a_option)
  ElseIf Type == "BodyEdit"
    SCX_BaseBodyEdit BodyEdit = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseBodyEdits, KeyCodes[1]) as SCX_BaseBodyEdit
    BodyEdit.setHighlight(Self, KeyCodes[2], a_option)
  ElseIf Type == "Perk"
    SCX_BasePerk PerkBase = SCXLib.getSCX_BaseAlias(SCXSet.JM_PerkIDs, KeyCodes[1]) as SCX_BasePerk
    PerkBase.setHighlight(Self, KeyCodes[2], KeyCodes[3] as Int, a_option)
  EndIf
EndEvent

State MenuKeyPick_KM
	Event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		Bool Continue = True
		If a_conflictControl != ""
			String msg
			If a_conflictName != ""
				msg = a_conflictControl + ": This key is already registered to " + a_conflictName + ". Are sure you want to continue?"
			Else
				msg = a_conflictControl + ": This key is already registered. Are you sure you want to continue?"
			EndIf
			Continue = ShowMessage(msg, true, "Yes", "No")
		EndIf
		If Continue
			SCXSet.MenuKey = a_keyCode
			SetKeyMapOptionValueST(a_keyCode)
		EndIf
	EndEvent

  Event OnDefaultST()
    SCXSet.MenuKey = -1
    SetKeyMapOptionValueST(-1)
  EndEvent

  Event OnHighlightST()
    SetInfoText("$SCXMCMMenuKeyInfo")
  EndEvent
EndState

State StatusKeyPick_KM
	Event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		Bool Continue = True
		If a_conflictControl != ""
			String msg
			If a_conflictName != ""
				msg = a_conflictControl + ": This key is already registered to " + a_conflictName + ". Are sure you want to continue?"
			Else
				msg = a_conflictControl + ": This key is already registered. Are you sure you want to continue?"
			EndIf
			Continue = ShowMessage(msg, true, "Yes", "No")
		EndIf
		If Continue
			SCXSet.StatusKey = a_keyCode
			SetKeyMapOptionValueST(a_keyCode)
		EndIf
	EndEvent

  Event OnDefaultST()
    SCXSet.StatusKey = -1
    SetKeyMapOptionValueST(-1)
  EndEvent

  Event OnHighlightST()
    SetInfoText("$SCXMCMStatusKeyInfo")
  EndEvent
EndState

State DebugEnable_TOG
	Event OnSelectST()
		SCXSet.DebugEnable = !SCXSet.DebugEnable
    checkDebugSpells()
    ForcePageReset()
	EndEvent

	Event OnDefaultST()
    SCXSet.DebugEnable = False
    checkDebugSpells()
    ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SCXMCMDebugEnableInfo")
	EndEvent
EndState

Bool Property SCXResetted Auto
Event OnGameReload()
  Parent.OnGameReload()
  If SCXResetted
    JDB.solveObjSetter(".SCLExtraData.ReloadList", JValue.readFromFile(JContainers.userDirectory() + "SCLReloadList.json"), True)
    SCXResetted = False
  EndIf
  If SCXSet.SCX_Active
    ;Notice("SCL Reloaded!")
    ;CheckSCLVersion()
    ;checkBaseDependencies()
    ;SCLData.setupInstalledMods()
    reloadMaintenence()
  EndIf
  JA_LibraryPriorityList = JValue.release(JA_LibraryPriorityList)
EndEvent

Function reloadMaintenence()
  Int QuestList = JDB.solveObj(".SCX_ExtraData.JM_QuestList")
  If JValue.isExists(QuestList)
    String QuestKey = JMap.nextKey(QuestList)
    While QuestKey
      SCX_BaseQuest Reload = JMap.getForm(QuestList, QuestKey) as SCX_BaseQuest
      If Reload
        Reload._reloadMaintenence()
      EndIf
      QuestKey = JMap.nextKey(QuestList, QuestKey)
    EndWhile
  EndIf
  Int RefAliasList = JDB.solveObj(".SCX_ExtraData.JM_RefAliasList")
  If JValue.isExists(RefAliasList)
    String RefAliasKey = JMap.nextKey(RefAliasList)
    While RefAliasKey
      Quest OwnedQuest = JMap.getForm(RefAliasList, RefAliasKey) as Quest
      If OwnedQuest
        SCX_BaseRefAlias ReloadRef = OwnedQuest.GetAliasByName(RefAliasKey) as SCX_BaseRefAlias
        If ReloadRef
          ReloadRef._reloadMaintenence()
        EndIf
      EndIf
      RefAliasKey = JMap.nextKey(RefAliasList, RefAliasKey)
    EndWhile
  EndIf
EndFunction

Function checkDebugSpells()
  Formlist DSpells = SCXSet.SCX_DebugSpellList
  Int Index = DSpells.GetSize()
  If SCXSet.DebugEnable
    While Index
      Index -= 1
      If !PlayerRef.HasSpell(DSpells.GetAt(Index) as Spell)
        PlayerRef.AddSpell(DSpells.GetAt(Index) as Spell)
      EndIf
    EndWhile
  Else
    While Index
      Index -= 1
      If PlayerRef.HasSpell(DSpells.GetAt(Index) as Spell)
        PlayerRef.removeSpell(DSpells.GetAt(Index) as Spell)
      EndIf
    EndWhile
  EndIf
EndFunction
