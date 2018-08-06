ScriptName SCX_Library Extends SCX_BaseLibrary

String ScriptID = "SCXLib"
Int Property JCReqAPI = 3 Auto
Int Property JCReqFV = 3 Auto

;Filled Properties *************************************************************
Function Setup()
  RegisterForModEvent("SCX_LibraryActorMainMenuOpen", "OnActorMainMenuOpen")
EndFunction

Bool Function isModInstalled(String Mod) Global
	Return Game.GetModByName(Mod) != 255
EndFunction
;------------------------------------------------------------------------------
;Get Scripts
;-------------------------------------------------------------------------------
Int Function getQuestEntryFromList(String QuestID) Global
  Int JM_QuestList = getJM_QuestList()
  If !JM_QuestList
    Return 0
  EndIf
  Return JMap.getObj(JM_QuestList, QuestID)
EndFunction

SCX_BaseQuest Function getQuestFormFromList(String QuestID) Global
  Int JM_QuestEntry = getQuestEntryFromList(QuestID)
  If !JM_QuestEntry
    Return None
  EndIf
  Return JMap.getForm(JM_QuestEntry, "QuestForm") as SCX_BaseQuest
EndFunction

Int Function getJM_QuestList() Global
  Int QuestList = JDB.solveObj(".SCX_ExtraData.JM_QuestList")
  If !JValue.isExists(QuestList) || !JValue.isMap(QuestList)
    QuestList = JMap.object()
    JDB.solveObjSetter(".SCX_ExtraData.JM_QuestList", QuestList, True)
  EndIf
  Return QuestList
EndFunction

Int Function getActorData(Actor akTarget) Global
  {Global version of getTargetData
  Will not generate profiles
  Data now stored under ActorBase for unique actors
  Function will generate new actor profile if no data found && abGenProfile == True}
  Form Target = akTarget.GetLeveledActorBase()
  Int Data = JFormDB.findEntry("SCX_ActorData", Target)
  Return Data
EndFunction

Function eraseActorData(Actor akTarget) Global
  Form Target = akTarget.GetLeveledActorBase()
  If Target
    Int JF_ActorData = JDB.solveObj(".SCX_ActorData")
    If JF_ActorData
      JFormMap.removeKey(JF_ActorData, Target)
    EndIf
  EndIf
EndFunction

Int JA_LibGenActorProfilePriorityList
Int Function generateActorProfile(Actor akTarget, Bool abBasic)
  String LibraryName = JMap.nextKey(SCXSet.JM_BaseLibraryList)
  Int aiTargetData = JFormDB.makeEntry("SCX_ActorData", akTarget)
  JMap.setFlt(aiTargetData, "LastUpdateTime", Utility.GetCurrentGameTime())

  If !JA_LibGenActorProfilePriorityList
    JA_LibGenActorProfilePriorityList = JValue.retain(JArray.object())
    Int JI_PriorityList = JValue.retain(JIntMap.object())
    While LibraryName
      SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, LibraryName) as SCX_BaseLibrary
      If Lib
        Int Priority = Lib.genActorProfilePriority
        Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, Priority)
        If !JM_PriorityList
          JM_PriorityList = JMap.object()
          JIntMap.setObj(JI_PriorityList, Priority, JM_PriorityList)
        EndIf
        JMap.setForm(JM_PriorityList, LibraryName, Lib)
      EndIf
      LibraryName = JMap.nextKey(SCXSet.JM_BaseLibraryList, LibraryName)
    EndWhile

    Int i = JIntMap.nextKey(JI_PriorityList)  ;Question: does nextKey actually do it in numerical order?
    While i
      Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, i)
      String LibKey = JMap.nextKey(JM_PriorityList)
      While LibKey
        SCX_BaseLibrary Lib = JMap.getForm(JM_PriorityList, LibKey) as SCX_BaseLibrary
        If Lib
          Lib.genActorProfile(akTarget, abBasic, aiTargetData)
          JArray.addForm(JA_LibGenActorProfilePriorityList, Lib)
        EndIf
        LibKey = JMap.nextKey(JM_PriorityList, LibKey)
      EndWhile
      i = JIntMap.nextKey(JI_PriorityList, i)
    EndWhile
    JI_PriorityList = JValue.release(JI_PriorityList)

  Else
    Int i = 0
    Int NumLibs = JArray.count(JA_LibGenActorProfilePriorityList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_LibGenActorProfilePriorityList, i) as SCX_BaseLibrary
      If Lib
        Lib.genActorProfile(akTarget, abBasic, aiTargetData)
      EndIf
      i += 1
    EndWhile
  EndIf
  Return aiTargetData
EndFunction


;-------------------------------------------------------------------------------
;Messages
;-------------------------------------------------------------------------------
Function addMessage(String asKey, String asMessageID, String asMessage) Global
  {Adds string to JMap that can be pulled from using getMessage
  use asKey to categorize them, and they'll be pulled from at random}
  Int MessageList = JDB.solveObj(".SCX_ExtraData.JM_MessageList")
  If !JValue.isExists(MessageList) || !JValue.isMap(MessageList)
    MessageList = JMap.object()
    JDB.solveObjSetter(".SCX_ExtraData.JM_MessageList", MessageList, True)
    Int Handle = ModEvent.Create("SCX_BuildMessageLists")
    ModEvent.Send(Handle)
  EndIf
  Int JA_MessageList = JMap.getObj(MessageList, asKey)
  If !JValue.isArray(JA_MessageList)
    JA_MessageList = JArray.object()
    JMap.setObj(MessageList, asKey, JA_MessageList)
  EndIf
  Int i = JArray.findStr(JA_MessageList, asMessage)
  If i == -1
    JArray.addStr(JA_MessageList, asMessage)
  EndIf
EndFunction



;/Actor Function getTeammate(Int aiIndex = -1)
  {Returns random teammate from list. use aiIndex to call a specific index
  Returns None if no teammate or invalid index
  If only one teammate, will always return that}
  Int NumTeammates = SCLSet.TeammatesList.Length
  If NumTeammates > 0
    Int i
    If NumTeammates > 1
      If aiIndex
        i = aiIndex
      Else
        i = Utility.RandomInt(0, NumTeammates - 1)
      EndIf
    Else
      i = 0
    EndIf
    Actor Teammate = SCLSet.TeammatesList[i] as Actor
    If Teammate
      Return Teammate
    EndIf
  EndIf
  Return None
EndFunction/;



;-------------------------------------------------------------------------------
;Perks
;-------------------------------------------------------------------------------
Function addPerkID(String asPerkID, Quest akOwnedQuest) Global
  {Adds information regarding a perk to a JMap}
  Int JM_PerkIDs = JDB.solveObj(".SCX_ExtraData.JM_PerkList")
  If !JM_PerkIDs
    SCX_Settings Settings = getQuestFormFromList("SCX_Settings") as SCX_Settings
    JM_PerkIDs = Settings.JM_PerkIDs
  EndIf
  JMap.setForm(JM_PerkIDs, asPerkID, akOwnedQuest)
EndFunction

Function removePerkID(String asPerkID) Global
  Int JM_PerkIDs = JDB.solveObj(".SCX_ExtraData.JM_PerkList")
  If !JM_PerkIDs
    Return
  EndIf
  If JMap.hasKey(JM_PerkIDs, asPerkID)
    JMap.removeKey(JM_PerkIDs, asPerkID)
  EndIf
EndFunction

;*******************************************************************************
;Helper Functions
;*******************************************************************************
Function showQuickActorStatus(Actor akTarget)
  Int JM_LibList = SCXSet.JM_BaseLibraryList
  String LibraryName = JMap.nextKey(JM_LibList)
  Int JA_Status = JValue.retain(JArray.object())
  While LibraryName
    SCX_BaseLibrary Lib = JMap.getForm(JM_LibList, LibraryName) as SCX_BaseLibrary
    Lib.addQuickStatusMessage(akTarget, JA_Status)
    LibraryName = JMap.nextKey(JM_LibList, LibraryName)
  EndWhile
  Int i
  Int StatusCount = JArray.count(JA_Status)
  While i < StatusCount
    String Status = JArray.getStr(JA_Status, i)
    If Status
      Debug.Notification(Status)
    EndIf
    i += 1
  EndWhile
  JValue.release(JA_Status)
EndFunction

Function showFullActorStatus(Actor akTarget)
  Int JM_LibList = SCXSet.JM_BaseLibraryList
  String LibraryName = JMap.nextKey(JM_LibList)
  Int JA_Status = JValue.retain(JArray.object())
  While LibraryName
    SCX_BaseLibrary Lib = JMap.getForm(JM_LibList, LibraryName) as SCX_BaseLibrary
    Lib.addFullStatusMessage(akTarget, JA_Status)
    LibraryName = JMap.nextKey(JM_LibList, LibraryName)
  EndWhile
  Int i
  Int StatusCount = JArray.count(JA_Status)
  While i < StatusCount
    String Status = JArray.getStr(JA_Status, i)
    If Status
      Debug.MessageBox(Status)
    EndIf
    i += 1
  EndWhile
  JValue.release(JA_Status)
EndFunction

Function addQuickStatusMessage(Actor akTarget, Int JA_Status)
  JArray.addStr(JA_Status, "Testing quick status: Actor == " + akTarget.GetLeveledActorBase().GetName())
EndFunction

Function addFullStatusMessage(Actor akTarget, Int JA_Status)
  JArray.addStr(JA_Status, "Testing full status: Actor == " + akTarget.GetLeveledActorBase().GetName())
EndFunction
;/Function extractActor(Actor akSource, Actor akTarget, Int aiItemType, ObjectReference akPosition)
  Notice("Extracting " + nameGet(akTarget) + " to " + nameGet(akPosition))
  ;akTarget.DisableNoWait(False)
  akTarget.MoveTo(akPosition, 64.0 * Math.Sin(akPosition.GetAngleZ()), 64.0 *Math.Cos(akPosition.GetAngleZ()), (akPosition.GetHeight() + 20), False)
  clearTrackingData(akTarget)
  dispellTrackingSpells(akTarget)
  removeTrackingSpells(akTarget)
  ;akPosition.PushActorAway(akTarget, 0)
  sendActorRemoveEvent(akSource, akTarget, aiItemType)
  ;aktarget.EnableNoWait(False)
  Utility.Wait(1)
EndFunction

Function removeTrackingSpells(Actor akTarget)
  {Will REMOVE spells listed in TrackingSpellList}
  Int i = SCLSet.TrackingSpellList.GetSize()
  While i
    i -= 1
    Spell CurrentSpell = SCLSet.TrackingSpellList.GetAt(i) as Spell
    If CurrentSpell
      akTarget.RemoveSpell(CurrentSpell)
    EndIf
  EndWhile
EndFunction

Function dispellTrackingSpells(Actor akTarget)
  {Will cast DISPEL spells listed in TrackingDispelList}
  Int i = SCLSet.TrackingDispelList.GetSize()
  While i
    i -= 1
    Spell CurrentSpell = SCLSet.TrackingDispelList.GetAt(i) as Spell
    If CurrentSpell
      CurrentSpell.Cast(akTarget)
    EndIf
  EndWhile
EndFunction/;

Int Function getAllContents(Actor akTarget, String asArchFilter = "", Int asJC_ArchFilterList = 0, String[] asArchFilterArray = None, Int aiTargetData = 0)
  {Gathers all contents from an actor
  Accepts archetype filters in the form of JArrays containing all strings, JMaps (will gather keys), and Papyrus string arrays.
  No filter will gather all registered archetype files.}
  Int TargetData
  If JValue.isMap(aiTargetData)
    TargetData = aiTargetData
  Else
    TargetData = getTargetData(akTarget)
  EndIf

  Int JA_ArchList
  Int JM_MainArchList = SCXSet.JM_BaseArchetypes
  If asArchFilter
    JA_ArchList = JValue.retain(JArray.object())
    JArray.addStr(JA_ArchList, asArchFilter)
  ElseIf JValue.isExists(asJC_ArchFilterList)
    If JValue.isArray(asJC_ArchFilterList)
      JA_ArchList = JValue.retain(asJC_ArchFilterList)
    ElseIf JValue.isMap(asJC_ArchFilterList)
      JA_ArchList = JValue.retain(JMap.allKeys(asJC_ArchFilterList))
    EndIf
  ElseIf asArchFilterArray.length > 0
    JA_ArchList = JValue.retain(JArray.objectWithStrings(asArchFilterArray))
  Else
    JA_ArchList = JValue.retain(JMap.allKeys(JM_MainArchList))
  EndIf
  Int i
  Int NumArchs = JArray.count(JA_ArchList)
  Int JF_CompiledContents = JValue.retain(JFormMap.object())
  While i < NumArchs
    String ArchetypeKey = JArray.getStr(JA_ArchList, i)
    If ArchetypeKey
      SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(JM_MainArchList, ArchetypeKey) as SCX_BaseItemArchetypes
      If Arch
        Int JF_ArchContents = Arch.getAllContents(akTarget, TargetData)
        If JValue.isFormMap(JF_ArchContents)
          JFormMap.addPairs(JF_CompiledContents, JF_ArchContents, True)
        EndIf
      EndIf
    Endif
    i += 1
  EndWhile
  JValue.release(JA_ArchList)
  JValue.release(JF_CompiledContents)
  Return JF_CompiledContents
EndFunction

Form[] Function getLoadedActors()
  Int i
  Int j
  Int NumAlias = SCXSet.SCX_MonitorManagerQuest.GetNumAliases()
  Form[] ReturnArray = Utility.CreateFormArray(NumAlias, None)
  While i < NumAlias
    ReferenceAlias LoadedAlias = SCXSet.SCX_MonitorManagerQuest.GetNthAlias(i) as ReferenceAlias
    Form loadActor = LoadedAlias.GetActorReference()
    If loadActor
      ReturnArray[j] = loadActor
      j += 1
    EndIf
    i += 1
  EndWhile
  Return ReturnArray
EndFunction

;/Function addAggregateValue(String asKey, Int JA_AggregateKeys) Global
  {These values will be added together in update functions}
  Int JM_AggregateValues = JDB.solveObj(".SCLExtraData.AggregateValues")
  If !JM_AggregateValues
    SCLDatabase Data = SCLibrary.getSCLDatabase()
    Data.setupAggregateValues()
    JM_AggregateValues = JDB.solveObj(".SCLExtraData.AggregateValues")
  EndIf
  If JMap.hasKey(JM_AggregateValues, asKey)
    Int JA_Existing = JMap.getObj(JM_AggregateValues, asKey)
    JArray.addFromArray(JA_Existing, JA_AggregateKeys)
    JArray.unique(JA_Existing)
  Else
    JMap.setObj(JM_AggregateValues, asKey, JA_AggregateKeys)
  EndIf
EndFunction

Function removeAggregateValue(String asKey) Global
  Int JM_AggregateValues = JDB.solveObj(".SCLExtraData.AggregateValues")
  If !JM_AggregateValues
    Return
  EndIf
  If JMap.hasKey(JM_AggregateValues, asKey)
    JMap.removeKey(JM_AggregateValues, asKey)
  EndIf
EndFunction

Function removeAggregateValueKey(String asKey, String asAggKey)
  Int JM_AggregateValues = JDB.solveObj(".SCLExtraData.AggregateValues")
  If !JM_AggregateValues
    Return
  EndIf
  If JMap.hasKey(JM_AggregateValues, asKey)
    Int JA_AggValues = JMap.getObj(JM_AggregateValues, asKey)
    Int i = JArray.findStr(JA_AggValues, asAggKey)
    If i != -1
      JArray.eraseIndex(JA_AggValues, i)
    EndIf
  EndIf
EndFunction/;
;*******************************************************************************
;UIExtensions
;*******************************************************************************

Function setWMItems(Int aiPosition, String asLabel, String asText, Bool abEnabled = True, Int aiColorOverride = -1)
  {Adds an item to the UI extensions wheel menu. Look at dcc_sgo_QuestController for example}
  UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", aiPosition, asLabel)
  UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", aiPosition, asText)
  UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", aiPosition, abEnabled)

  If aiColorOverride != -1
    UIExtensions.SetMenuPropertyIndexInt("UIWheelMenu", "optionTextColor", aiPosition, aiColorOverride)
  ElseIf !abEnabled
    UIExtensions.SetMenuPropertyIndexInt("UIWheelMenu", "optionTextColor", aiPosition, 0x555555)
  EndIf
EndFunction

Int CurrentActorMenuIndex
Int JA_ActorMainMenuPriorityList
Int Function getActorMenuList()
  Return JA_ActorMainMenuPriorityList
EndFunction

Function openActorMainMenu(Actor akTarget = None, Int aiMode = 0)
  Int Handle = ModEvent.Create("SCX_LibraryActorMainMenuOpen")
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushInt(Handle, aiMode)
  ModEvent.send(Handle)
EndFunction

Function showActorMainMenu(Actor akTarget = None, Int aiMode = 0)
  If akTarget == None
    akTarget = Game.GetCurrentCrosshairRef() as Actor
  EndIf

  If akTarget == None
    akTarget == PlayerRef
  EndIf
  If !JValue.isExists(JA_ActorMainMenuPriorityList) ;Need to generate list
    Debug.Notification("Building actor menu list...")
    JA_ActorMainMenuPriorityList = JValue.retain(JArray.object())
    Int JI_PriorityList = JValue.retain(JIntMap.object())
    String LibraryName = JMap.nextKey(SCXSet.JM_BaseLibraryList)
    While LibraryName
      SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, LibraryName) as SCX_BaseLibrary
      If Lib
        Int Priority = Lib.ActorMainMenuPriority
        If Priority != 0
          Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, Priority)
          If !JM_PriorityList
            JM_PriorityList = JMap.object()
            JIntMap.setObj(JI_PriorityList, Priority, JM_PriorityList)
          EndIf
          JMap.setForm(JM_PriorityList, LibraryName, Lib)
        EndIf
      EndIf
      LibraryName = JMap.nextKey(SCXSet.JM_BaseLibraryList, LibraryName)
    EndWhile

    Int i = JIntMap.nextKey(JI_PriorityList)  ;Question: does nextKey actually do it in numerical order?
    While i
      Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, i)
      String LibKey = JMap.nextKey(JM_PriorityList)
      While LibKey
        SCX_BaseLibrary Lib = JMap.getForm(JM_PriorityList, LibKey) as SCX_BaseLibrary
        If Lib
          JArray.addForm(JA_ActorMainMenuPriorityList, Lib)
        EndIf
        LibKey = JMap.nextKey(JM_PriorityList, LibKey)
      EndWhile
      i = JIntMap.nextKey(JI_PriorityList, i)
    EndWhile
    JI_PriorityList = JValue.release(JI_PriorityList)
  EndIf
  (JArray.getForm(JA_ActorMainMenuPriorityList, CurrentActorMenuIndex) as SCX_BaseLibrary).openActorMainMenu(akTarget, aiMode)
EndFunction

Function openNextActorMainMenu(Actor akTarget, Int aiMode = 0)
  CurrentActorMenuIndex += 1
  CurrentActorMenuIndex = PapyrusUtil.WrapInt(CurrentActorMenuIndex, JArray.count(JA_ActorMainMenuPriorityList) - 1)
  openActorMainMenu(akTarget, aiMode)
EndFunction

Function openPreviousActorMainMenu(Actor akTarget, Int aiMode = 0)
  CurrentActorMenuIndex -= 1
  CurrentActorMenuIndex = PapyrusUtil.WrapInt(CurrentActorMenuIndex, JArray.count(JA_ActorMainMenuPriorityList) - 1)
  openActorMainMenu(akTarget, aiMode)
EndFunction

String Function getNextActorMainMenuName(Int aiMode = 0)
  Return (JArray.getForm(JA_ActorMainMenuPriorityList, PapyrusUtil.WrapInt(CurrentActorMenuIndex + 1, JArray.count(JA_ActorMainMenuPriorityList) - 1)) as SCX_BaseLibrary).ActorMenuNames[aiMode]
EndFunction

String Function getPreviousActorMainMenuName(Int aiMode = 0)
  Return (JArray.getForm(JA_ActorMainMenuPriorityList, PapyrusUtil.WrapInt(CurrentActorMenuIndex - 1, JArray.count(JA_ActorMainMenuPriorityList) - 1)) as SCX_BaseLibrary).ActorMenuNames[aiMode]
EndFunction

String Function getActorMainMenuName(Int aiIndex, Int aiMode = 0)
  Return (JArray.getForm(JA_ActorMainMenuPriorityList, aiIndex) as SCX_BaseLibrary).ActorMenuNames[aiMode]
EndFunction

Event OnActorMainMenuOpen(Form akTarget, Int aiMode = 0)
  Notice("Showing Actor Main Menu for " + nameGet(akTarget))
  Actor Target = akTarget as Actor
  If Target
    If !buildActorMainMenu(Target, aiMode)
      Return
    EndIf
    SCXSet.SCX_ModConfigMenuQuest.SelectedActor = Target
    Int Option = UIExtensions.OpenMenu("UIWheelMenu", Target)
    handleActorMainMenu(Target, Option, aiMode)
  EndIf
EndEvent

Bool Function buildActorMainMenu(Actor akTarget, Int aiMode = 0)
  UIWheelMenu WM_ActorMenu = UIExtensions.GetMenu("UIWheelMenu", True) as UIWheelMenu
  String ActorName = nameGet(akTarget)
  ;Int TargetData = getTargetData(akTarget, True)
  Bool AllowCommandFunctions = False
  If akTarget == PlayerRef || akTarget.IsPlayerTeammate() || SCXSet.DebugEnable
    AllowCommandFunctions = True
  EndIf
  setWMItems(0, "Show Stats", "View Stats", True)
  String PreviousMenuName = getPreviousActorMainMenuName()
  If PreviousMenuName
    setWMItems(1, PreviousMenuName, "Display previous menu", True)
  Else
    setWMItems(1, "", "", False)
  EndIf
  setWMItems(3, "Expell Contents", "Force actor to remove all items", AllowCommandFunctions)
  setWMItems(4, "Perks Menu", "Show and take perks", True)
  String NextMenuName = getNextActorMainMenuName()
  If NextMenuName
    setWMItems(5, NextMenuName, "Display Next Menu", True)
  Else
    setWMItems(5, "", "", False)
  EndIf
  If AllowCommandFunctions
    setWMItems(6, "Contents", "View contents and expell specific items", True)
  Else
    setWMItems(6, "Contents", "Show all items in " + ActorName, True)
  EndIf
  setWMItems(7, "Add Items", "Transfer items to contents", AllowCommandFunctions)
  Return True
EndFunction

Function handleActorMainMenu(Actor akTarget, Int aiOption, Int aiMode = 0)
  If aiOption == 0
    showActorStatsMenu(akTarget)
  ElseIf aiOption == 1
    openPreviousActorMainMenu(akTarget, aiMode)
  ElseIf aiOption == 2
    ;showActorEffectsMenu(akTarget) ;Is this necessary with all effects being added through creation kit?
  ElseIf aiOption == 3
    String Arch = showArchetypesListMenu(akTarget)
    If Arch && Arch != "Cancel"
      SCX_BaseItemArchetypes ArchForm = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, Arch) as SCX_BaseItemArchetypes
      If ArchForm
        ArchForm.removeAllActorItems(akTarget, False)
      EndIf
    EndIf
  ElseIf aiOption == 4
    showPerksList(akTarget)
  ElseIf aiOption == 5
    openNextActorMainMenu(akTarget, 0)
  ElseIf aiOption == 6
    String Arch = showArchetypesListMenu(akTarget, True)
    If Arch != "Cancel"
      If akTarget == PlayerRef || akTarget.IsPlayerTeammate() || SCXSet.DebugEnable
        showActorContentsMenu(akTarget, 1, Arch)
      Else
        showActorContentsMenu(akTarget, asArchetypeOverride = Arch)
      EndIf
    EndIf
  ElseIf aiOption == 7
    showTransferMenu(akTarget)
  EndIf
EndFunction

;Transfer Menu *****************************************************************
String Function showArchetypesListMenu(Actor akTarget, Bool abForceChoice = False)
  UIListMenu LM_ST_Transfer = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
  Int JA_ArchetypeList = JValue.retain(JArray.object())
  LM_ST_Transfer.AddEntryItem("<<< Return")
  JArray.addStr(JA_ArchetypeList, "Cancel")
  If !abForceChoice
    LM_ST_Transfer.AddEntryItem("All")
    JArray.addStr(JA_ArchetypeList, "")
  EndIf
  Int ArchList = SCXSet.JM_BaseArchetypes
  String Archetype = JMap.nextKey(ArchList)
  While Archetype
    LM_ST_Transfer.AddEntryItem(Archetype)
    JArray.addStr(JA_ArchetypeList, Archetype)
    Archetype = JMap.nextKey(ArchList, Archetype)
  EndWhile
  LM_ST_Transfer.OpenMenu()
  Int Option = LM_ST_Transfer.GetResultInt()
  If Option >= 0 && Option < JArray.count(JA_ArchetypeList)
    String ReturnValue = JArray.getStr(JA_ArchetypeList, Option)
    JValue.release(JA_ArchetypeList)
    Return ReturnValue
  Else
    JValue.release(JA_ArchetypeList)
    Return "Cancel"
  EndIf
EndFunction

Function showTransferMenu(Actor akTarget = None, String asArchetypeOverride = "")
  {Requires an archetype to be selected, systems can't input multiple archetypes at once.}
  If !akTarget
    akTarget = Game.GetCurrentCrosshairRef() as Actor
  EndIf

  If !akTarget
    akTarget == PlayerRef
  EndIf

  If !asArchetypeOverride
    asArchetypeOverride = showArchetypesListMenu(akTarget, True)
    If asArchetypeOverride == "Cancel" || !asArchetypeOverride
      Return
    EndIf
  EndIf

  Notice("Opening transfer menu for " + nameGet(akTarget))
  ;SCLTransferObject ST_TransferRef = PlayerRef.PlaceAtMe(SCLSet.SCL_TransferBase) as SCLTransferObject
  SCX_TransferContainer TransferRef = SCXSet.SCX_TransferChest01 as SCX_TransferContainer
  TransferRef.TransferArchetype = asArchetypeOverride  ;Sets properties on the transfer object script before its opened
  TransferRef.TransferTarget = akTarget
  TransferRef.Activate(PlayerRef)
EndFunction

;Stats Menu ********************************************************************
Int JA_UIE_ActorStatsList
Function showActorStatsMenu(Actor akTarget = None, Int aiMode = 0, String asLibraryOverride = "")
  If !akTarget
    akTarget = Game.GetCurrentCrosshairRef() as Actor
  EndIf

  If !akTarget
    akTarget == PlayerRef
  EndIf

  UIListMenu LM_ST_Stats = buildActorStatsMenu(akTarget, aiMode, asLibraryOverride)
  Int Option = LM_ST_Stats.OpenMenu()
  While Option > 0 && Option < JArray.count(JA_UIE_ActorStatsList)
    String KeyList = JArray.getStr(JA_UIE_ActorStatsList, Option)
    String[] KeyCodes = StringUtil.Split(KeyList, ".")
    Int JM_MainLibList = SCXSet.JM_BaseLibraryList
    SCX_BaseLibrary Lib = JMap.getForm(JM_MainLibList, KeyCodes[0]) as SCX_BaseLibrary

    Bool RebuildMenu = Lib.handleUIEStatFromList(akTarget, KeyCodes[1])

    If RebuildMenu
      LM_ST_Stats = buildActorStatsMenu(akTarget, aiMode, asLibraryOverride)
    EndIf
    Option = LM_ST_Stats.OpenMenu()
  EndWhile
  showActorMainMenu(akTarget)
EndFunction

Int JA__UIE_LibBuildActorStatsMenuPriorityList
Int JA_UIE_ActorStatOptionList
UIListMenu Function buildActorStatsMenu(Actor akTarget, Int aiMode = 0, String asLibraryOverride = "")
  UIListMenu UIList = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
  JA_UIE_ActorStatOptionList = JValue.releaseAndRetain(JA_UIE_ActorStatOptionList, JArray.object())
  UIList.AddEntryItem("<<< Return")
  JArray.addStr(JA_UIE_ActorStatOptionList, "")

  If asLibraryOverride
    SCX_BaseLibrary Lib = JMap.getForm(SCXSet.JM_BaseLibraryList, asLibraryOverride) as SCX_BaseLibrary
    Lib.addUIEActorStats(akTarget, UIList, JA_UIE_ActorStatOptionList, aiMode)
  Else
    If !JValue.isExists(JA__UIE_LibBuildActorStatsMenuPriorityList) || !JValue.isArray(JA__UIE_LibBuildActorStatsMenuPriorityList)
      JA__UIE_LibBuildActorStatsMenuPriorityList = JValue.releaseAndRetain(JA__UIE_LibBuildActorStatsMenuPriorityList, JArray.object())
      Int JI_PriorityList = JValue.retain(JIntMap.object())
      Int JM_MainLibList = SCXSet.JM_BaseLibraryList
      String LibraryName = JMap.nextKey(JM_MainLibList)
      While LibraryName
        SCX_BaseLibrary Lib = JMap.getForm(JM_MainLibList, LibraryName) as SCX_BaseLibrary
        If Lib
          Int Priority = Lib.addUIEActorStatsPriority
          If Priority
            Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, Priority)
            If !JM_PriorityList
              JM_PriorityList = JMap.object()
              JIntMap.setObj(JI_PriorityList, Priority, JM_PriorityList)
            EndIf
            JMap.setForm(JM_PriorityList, LibraryName, Lib)
          Else
          EndIf
        EndIf
        LibraryName = JMap.nextKey(JM_MainLibList, LibraryName)
      EndWhile

      Int i = JIntMap.nextKey(JI_PriorityList)  ;Question: does nextKey actually do it in numerical order?
      While i
        Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, i)
        String LibKey = JMap.nextKey(JM_PriorityList)
        While LibKey
          SCX_BaseLibrary Lib = JMap.getForm(JM_PriorityList, LibKey) as SCX_BaseLibrary
          If Lib
            Lib.addUIEActorStats(akTarget, UIList, JA_UIE_ActorStatOptionList, aiMode)
            JArray.addForm(JA__UIE_LibBuildActorStatsMenuPriorityList, Lib)
          EndIf
          LibKey = JMap.nextKey(JM_PriorityList, LibKey)
        EndWhile
        i = JIntMap.nextKey(JI_PriorityList, i)
      EndWhile
      JI_PriorityList = JValue.release(JI_PriorityList)
    Else
      Int i = 0
      Int NumLibs = JArray.count(JA__UIE_LibBuildActorStatsMenuPriorityList)
      While i < NumLibs
        SCX_BaseLibrary Lib = JArray.getForm(JA__UIE_LibBuildActorStatsMenuPriorityList, i) as SCX_BaseLibrary
        If Lib
          Lib.addUIEActorStats(akTarget, UIList, JA_UIE_ActorStatOptionList, aiMode)
        EndIf
        i += 1
      EndWhile
    EndIf
  EndIf
  Return UIList
EndFunction

;Contents Menu ********************************************************************
Function showActorContentsMenu(Actor akTarget = None, Int aiMode = 0, String asArchetypeOverride = "")
  If !akTarget
    akTarget = Game.GetCurrentCrosshairRef() as Actor
  EndIf

  If !akTarget
    akTarget == PlayerRef
  EndIf

  UIListMenu LM_ST_Contents = buildActorContents(akTarget, aiMode, asArchetypeOverride)
  Int Option = LM_ST_Contents.OpenMenu()
  Int JM_MainArchList = SCXSet.JM_BaseArchetypes
  While Option > 0 && Option < JArray.count(JI_UIE_ContentsOptionList)
    Int ParentIndex = LM_ST_Contents.GetResultFloat() as Int
    Form ItemForm = JIntMap.getForm(JI_UIE_ContentsItemList, ParentIndex)
    String KeyList = JIntMap.getStr(JI_UIE_ContentsOptionList, Option)
    String[] KeyCodes = StringUtil.Split(KeyList, ".")
    SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(JM_MainArchList, KeyCodes[0]) as SCX_BaseItemArchetypes
    Bool RebuildMenu = False
    If Arch
      RebuildMenu = Arch.HandleUIEActorContents(akTarget, ItemForm, KeyCodes[1] as Int, KeyCodes[2], aiMode)
    Else
      Issue("Archetype not found! Returning...")
      Return
    EndIf

    If RebuildMenu
      LM_ST_Contents = buildActorContents(akTarget, aiMode, asArchetypeOverride)
    EndIf
    Option = LM_ST_Contents.OpenMenu()
  EndWhile
  openActorMainMenu(akTarget)
EndFunction

Int JI_UIE_ContentsOptionList
Int JI_UIE_ContentsItemList
UIListMenu Function buildActorContents(Actor akTarget, Int aiMode = 0, String asArchetypeOverride = "")
  UIListMenu UIList = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
  Int TargetData = getTargetData(akTarget)
  Int JM_MainArchList = SCXSet.JM_BaseArchetypes
  JI_UIE_ContentsOptionList = JValue.releaseAndRetain(JI_UIE_ContentsOptionList, JIntMap.object())
  JI_UIE_ContentsItemList = JValue.releaseAndRetain(JI_UIE_ContentsItemList, JIntMap.object())

  Int ReturnIndex = UIList.AddEntryItem("<<< Return")
  JIntMap.setStr(JI_UIE_ContentsOptionList, ReturnIndex, "")
  JIntMap.setForm(JI_UIE_ContentsItemList, ReturnIndex, None)

  If asArchetypeOverride
    SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(JM_MainArchList, asArchetypeOverride) as SCX_BaseItemArchetypes
    If Arch
      Arch.addUIEActorContents(akTarget, UIList, JI_UIE_ContentsItemList, JI_UIE_ContentsOptionList, aiMode)
    EndIf
  Else
    String ArchetypeKey = JMap.nextKey(JM_MainArchList)
    While ArchetypeKey
      SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(JM_MainArchList, ArchetypeKey) as SCX_BaseItemArchetypes
      If Arch
        Arch.addUIEActorContents(akTarget, UIList, JI_UIE_ContentsItemList, JI_UIE_ContentsOptionList, aiMode)
      EndIf
      ArchetypeKey = JMap.nextKey(JM_MainArchList, ArchetypeKey)
    EndWhile
  EndIf
  Return UIList
EndFunction

;Perks Menu ********************************************************************
Function showPerksList(Actor akTarget = None, Int aiMode = 0, String asPerkGroup = "")
  If akTarget == None
    akTarget == Game.GetCurrentCrosshairRef() as Actor
  EndIf

  If akTarget == None
    akTarget == PlayerRef
  EndIf

  If !buildPerksMenu(akTarget, aiMode, asPerkGroup)
    Debug.Notification("No perks available for " + nameGet(akTarget))
    openActorMainMenu(akTarget, 0)
    Return
  EndIf

  UIExtensions.OpenMenu("UIListMenu", akTarget)
  Int Option = UIExtensions.GetMenuResultInt("UIListMenu")
  While Option > 0 && Option < JArray.count(JA_UIE_PerkLevelList)
    Int PerkLevel = JArray.getInt(JA_UIE_PerkLevelList, Option, -1)
    String PerkID = JArray.getStr(JA_UIE_PerkIDList, Option, "")
    SCX_BasePerk PerkForm = getSCX_BaseAlias(SCXSet.JM_PerkIDs, PerkID) as SCX_BasePerk
    Bool RebuildMenu = False
    Int CurrentPerkValue = PerkForm.getPerkLevel(akTarget)
    If PerkLevel <= CurrentPerkValue
      Debug.MessageBox(PerkForm.getPerkName(PerkLevel) + ": " + PerkForm.getDescription(PerkLevel) + "\n Requirements: " + PerkForm.getRequirements(PerkLevel))
      Utility.Wait(0.2)
    ElseIf PerkForm.canTake(akTarget, CurrentPerkValue + 1, SCXSet.DebugEnable)
      Debug.MessageBox(PerkForm.getPerkName(CurrentPerkValue + 1) + ": " + PerkForm.getDescription(CurrentPerkValue + 1) + "\n Requirements: " + PerkForm.getRequirements(CurrentPerkValue + 1))
      Utility.Wait(0.1)
      If SCXSet.SCX_MES_TakePerk.Show()
        PerkForm.takePerk(akTarget, True)
        Debug.MessageBox("Perk " + PerkForm.getPerkName(CurrentPerkValue + 1) + " taken!")
        Utility.Wait(0.2)
      EndIf
      ;Debug.Notification("Perk " + getPerkName(PerkID, PerkLevel) + " taken!")
      RebuildMenu = True
    Else
      Debug.MessageBox(PerkForm.getPerkName(CurrentPerkValue + 1) + ": " + PerkForm.getDescription(CurrentPerkValue + 1) + "\n Requirements: " + PerkForm.getRequirements(CurrentPerkValue + 1))
      Utility.Wait(0.2)
      ;Debug.Notification(getPerkDescription(PerkID, PerkLevel))
      ;Debug.Notification(getPerkRequirements(PerkID, PerkLevel))
    EndIf
    If RebuildMenu
      If buildPerksMenu(akTarget)
        UIExtensions.OpenMenu("UIListMenu", akTarget)
        Option = UIExtensions.GetMenuResultInt("UIListMenu")
      Else
        Option = 0
      EndIf
    Else
      UIExtensions.OpenMenu("UIListMenu", akTarget)
      Option = UIExtensions.GetMenuResultInt("UIListMenu")
    EndIf
  EndWhile
  openActorMainMenu(akTarget, 0)
EndFunction

Int JA_UIE_PerkLevelList
Int JA_UIE_PerkIDList

Bool Function buildPerksMenu(Actor akTarget, Int aiMode = 0, String asPerkGroup = "")
  UIListMenu LM_ST_Perks = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
  Int TargetData = getTargetData(akTarget)
  If !TargetData
    Notice(nameGet(akTarget) + " has no data! Can't build perks menu!")
    Return False
  EndIf
  JA_UIE_PerkLevelList = JValue.releaseAndRetain(JA_UIE_PerkLevelList, JArray.object())
  JA_UIE_PerkIDList = JValue.releaseAndRetain(JA_UIE_PerkIDList, JArray.object())
  LM_ST_Perks.AddEntryItem("<< Return")
  ;JArray.addStr(JA_Description, "")
  JArray.addInt(JA_UIE_PerkLevelList, -1)
  JArray.addStr(JA_UIE_PerkIDList, "")

  Int i
  Int JM_MainPerkList = SCXSet.JM_PerkIDs
  Int NumPerks = JMap.count(JM_MainPerkList)
  Int currentEntry = -1
  While i < NumPerks
    String sPerkID = JMap.getNthKey(JM_MainPerkList, i)
    SCX_BasePerk PerkBase = getSCX_BaseAlias(JM_MainPerkList, sPerkId) as SCX_BasePerk
    If !asPerkGroup || PerkBase.PerkGroup == asPerkGroup
      If PerkBase.showPerk(akTarget)
        currentEntry = LM_ST_Perks.AddEntryItem(PerkBase.Name)
        JArray.addInt(JA_UIE_PerkLevelList, 0); Index - Level
        JArray.addStr(JA_UIE_PerkIDList, sPerkID) ;Index - PerkID

        LM_ST_Perks.SetPropertyIndexBool("hasChildren", currentEntry, True)
        Int CurrentPerkValue = PerkBase.getPerkLevel(akTarget)
        Int j = 0
        While j < CurrentPerkValue
          j += 1
          Int Entry = LM_ST_Perks.addEntryItem(PerkBase.getPerkName(j), currentEntry, i)
          JArray.addInt(JA_UIE_PerkLevelList, j)
          JArray.addStr(JA_UIE_PerkIDList, sPerkID)
        EndWhile
        Int MaxValue = PerkBase.AbilityArray.Length - 1
        If CurrentPerkValue < MaxValue
          Int NextEntry = LM_ST_Perks.addEntryItem("*" + PerkBase.getPerkName(j + 1), currentEntry, i)
          JArray.addInt(JA_UIE_PerkLevelList, j + 1)
          JArray.addStr(JA_UIE_PerkIDList, sPerkID)
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Return True
EndFunction

Function extractActor(Actor akSource, Actor akTarget, String asArch, String asType, ObjectReference akPosition)
  Notice("Extracting " + nameGet(akTarget) + " to " + nameGet(akPosition))
  Int JM_LibList = SCXSet.JM_BaseLibraryList
  String LibraryName = JMap.nextKey(JM_LibList)
  While LibraryName
    SCX_BaseLibrary Lib = JMap.getForm(JM_LibList, LibraryName) as SCX_BaseLibrary
    Lib.handleActorExtraction(akSource, akTarget, asArch, asType, akPosition)
    LibraryName = JMap.nextKey(JM_LibList, LibraryName)
  EndWhile
  ;akTarget.DisableNoWait(False)
  akTarget.MoveTo(akPosition, 64.0 * Math.Sin(akPosition.GetAngleZ()), 64.0 *Math.Cos(akPosition.GetAngleZ()), (akPosition.GetHeight() + 20), False)
  ;akPosition.PushActorAway(akTarget, 0)
  Int E = ModEvent.Create("SCX_ActorExtract")
  ModEvent.PushForm(E, akSource)
  ModEvent.PushForm(E, akTarget)
  ModEvent.PushString(E, asArch)
  ModEvent.PushString(E, asType)
  ModEvent.Send(E)  ;aktarget.EnableNoWait(False)
  Utility.Wait(0.5)
EndFunction

;Color Functions ***************************************************************
Int Function genRedSpectrum(Float afPercent) Global
  {Returns hex code that transitions from white to red as it approaches 1 (then goes towards black)}
  Int Hex = Math.Ceiling(0xFF * afPercent)
  Int Remainder = 0
  If Hex > 0xFF
    Remainder = Hex - 0xFF
    Hex = 0xFF
  EndIf
  Return 0xFFFFFF - (0xFF * Hex) - Hex - (Remainder * 0xFF00)
EndFunction

Int Function genGreenSpectrum(Float afPercent) Global
  {Returns hex code that transitions from white to blue as it approaches 1 (then goes towards black)}
  Int Hex = Math.Ceiling(0xFF * afPercent)
  Int Remainder = 0
  If Hex > 0xFF
    Remainder = Hex - 0xFF
    Hex = 0xFF
  EndIf
  Return 0xFFFFFF - (0xFF00 * Hex) - Hex - (Remainder * 0xFF)
EndFunction

Int Function genBlueSpectrum(Float afPercent) Global
  {Returns hex code that transitions from white to green as it approaches 1 (then goes towards black)}
  Int Hex = Math.Ceiling(0xFF * afPercent)
  Int Remainder = 0
  If Hex > 0xFF
    Remainder = Hex - 0xFF
    Hex = 0xFF
  EndIf
  Return 0xFFFFFF - (0xFF00 * Hex) - (0xFF * Hex) - Remainder
EndFunction

;/Function displayPerkTree(Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = getTargetData(akTarget)
  EndIf
  ;Get Position in front of player

  ;Place anchor in bottom left corner
  ;OPTIONAL: Place image plane aligned with anchor
  ;Place stars in position based on PerkCoords
  ;Name stars using SetDisplayName()
  ;Connect stars with lines using PerkConnections
EndFunction/;

;Library Functions *************************************************************
Function addMCMActorInformation(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  MCM.AddHeaderOption("Overall Stats")
  MCM.AddEmptyOption()
  Bool DEnable = SCXSet.DebugEnable
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Weight Contained", getActorTotalWeightContained(akTarget, aiTargetData)), "Stats.SCX_Library.SCXShowTotalContained")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Weight Overall", genWeightValue(akTarget)), "Stats.SCX_Library.SCXShowTotalOverrall")
EndFunction

Float Function getActorTotalWeightContained(Actor akTarget, Int aiTargetData = 0)
  Return -1
EndFunction

Float Function genWeightValue(Form akItem, Bool abActorAddEquipmentWeight = False)
  Actor akTarget = akItem as Actor
  Int JM_DB_ItemEntry = getItemDatabaseEntry(akTarget)
  If !akTarget
    Float WeightValue
    If akItem as ObjectReference
      akItem = (akItem as ObjectReference).GetBaseObject()
    EndIf
    If JM_DB_ItemEntry && JMap.hasKey(JM_DB_ItemEntry, "WeightOverride")
      WeightValue = JMap.getFlt(JM_DB_ItemEntry, "WeightOverride")
    Else
      WeightValue = akItem.GetWeight()
    EndIf
    If JM_DB_ItemEntry && JMap.hasKey(JM_DB_ItemEntry, "WeightModifier")
      WeightValue *= JMap.getFlt(JM_DB_ItemEntry, "WeightModifier", 1)
    EndIf
    If WeightValue > 0
      Return WeightValue
    Else
      Return 0.1
    EndIf
  Else
    Float WeightValue
  	If akTarget.GetRace().HasKeyword(SCXSet.ActorTypeNPC)
  		If JMap.hasKey(JM_DB_ItemEntry, "WeightOverride")
  			WeightValue = JMap.getFlt(JM_DB_ItemEntry, "WeightOverride")
  		ElseIf akTarget.GetLeveledActorBase().GetSex() == 0
  			WeightValue = akTarget.GetLeveledActorBase().GetWeight() + 80
  		ElseIf akTarget.GetLeveledActorBase().GetSex() == 1
  			WeightValue = akTarget.GetLeveledActorBase().GetWeight() + 70
  		EndIf
  		;Add check for bodymods here (SAM, Bodymorph, etc.)
  		;WeightMorphs, SAMPLE, anything else?
  		;WeightValue +=
  		WeightValue *= akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False)
  		If JM_DB_ItemEntry && JMap.hasKey(JM_DB_ItemEntry, "WeightModifier")
  			WeightValue *= JMap.getFlt(JM_DB_ItemEntry, "WeightModifier", 1)
  		EndIf

      If abActorAddEquipmentWeight
        WeightValue += akTarget.GetTotalItemWeight()	;All of the Actor's inventory
      EndIf
  		WeightValue += getActorTotalWeightContained(akTarget)
  		Return WeightValue
  	Else
  		If JMap.hasKey(JM_DB_ItemEntry, "WeightOverride")
  			WeightValue = JMap.getFlt(JM_DB_ItemEntry, "WeightOverride")
  			WeightValue *= akTarget.GetScale()
  		Else
        WeightValue = akTarget.GetBaseActorValue("Health")
  		EndIf
  		If JM_DB_ItemEntry && JMap.hasKey(JM_DB_ItemEntry, "WeightModifier")
  			WeightValue *= JMap.getFlt(JM_DB_ItemEntry, "WeightModifier", 1)
  		EndIf

      If abActorAddEquipmentWeight
        WeightValue += akTarget.GetTotalItemWeight()	;All of the Actor's inventory
      EndIf
  		WeightValue += getActorTotalWeightContained(akTarget)
  		Return WeightValue
  	EndIf
  EndIf
EndFunction
;/Function addMCMActorRecords(SKI_ConfigBase MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Digested Food", JMap.getFlt(aiTargetData, "SCLTotalDigestedFood")), "Records_SCLibrary_SCLTotalDigestedFood")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Times Vomited", JMap.getFlt(aiTargetData, "SCLTotalTimesVomited")), "Records_SCLibrary_SCLTotalTimesVomited")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Highest Stomach Fullness", JMap.getFlt(aiTargetData, "SCLHighestStomachFullness")), "Records_SCLibrary_SCLHighestStomachFullness")
  AddEmptyOption()
EndFunction/;

Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SCXShowTotalContained"
    MCM.ShowMessage("How much weight the actor is carrying around.", False, "OK", "")
  ElseIf asValue == "SCXShowTotalOverrall"
    MCM.ShowMessage("Total weight of the actor.", False, "OK", "")
  EndIf
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SCXShowTotalContained"
    MCM.setInfoText("How much weight the actor is carrying around.")
  ElseIf asValue == "SCXShowTotalOverrall"
    MCM.setInfoText("Total weight of the actor.")
  EndIf
EndFunction

Function processConsoleInput(ObjectReference akTarget, String[] cmd)
  If cmd[0] == "SCX"
    Note("Console Input recieved: cmd list = ")
    Note(cmd)
  EndIf
EndFunction
