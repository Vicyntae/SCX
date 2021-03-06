ScriptName SCX_BaseQuest Extends Quest Hidden

SCX_Settings Property SCXSet Auto
SCX_Library Property SCXLib Auto
Actor Property PlayerRef Auto
String Property ScriptID Auto
String Property DebugName
  String Function Get()
    Return "[" + ScriptID + "] "
  EndFunction
EndProperty
Bool Property EnableDebugMessages Auto

Bool Initialized
Event OnInit()
  If !Initialized
    Utility.Wait(0.5)
    ;Notice("Starting up quest...")
    Initialized = True
    If !SCXSet
      SCXSet = JMap.getForm(SCX_Library.getJM_QuestList(), "SCX_Settings") as SCX_Settings
    EndIf
    If !SCXLib
      SCXLib = JMap.getForm(SCXSet.JM_QuestList, "SCX_Library") as SCX_Library
    EndIf
    If SCXSet
      Int JC_Container = _getSCX_JC_List()
      If JC_Container
        If JValue.isMap(JC_Container)
          String ListKey = _getStrKey()
          If ListKey
            JMap.setForm(JC_Container, _getStrKey(), Self)
          Else
            Issue("Quest " + GetName() + "has JC_List but lacks StringKey!", 1)
          EndIf
        ElseIf JValue.isIntegerMap(JC_Container)
          Int ListKey = _getIntKey()
          If ListKey
            JIntMap.setForm(JC_Container, _getIntKey(), Self)
          Else
            Issue("Quest " + GetName() + "has JC_List but lacks IntKey!", 1)
          EndIf
        EndIf
      Else
        ;Notice("JC_List not available for quest " + GetName() + ".")
      EndIf
      JMap.setForm(SCXSet.JM_QuestList, _getStrKey(), Self)
    Else
      Issue("SCX_Settings wasn't found! Please check SCX Installation", 2, True)
    EndIf
    ;Note("Done initializing quest.")
    _setup()
    Setup()
    _reloadMaintenence()
  EndIf
EndEvent

Int Function _getSCX_JC_List()
  Return 0
EndFunction

String Function _getStrKey()
  Return ScriptID
EndFunction

Int Function _getIntKey()
  Return 0
EndFunction

Function _reloadMaintenence()
  RegisterForModEvent("SCX_BuildQuestList", "OnSCXBuildQuestList")
  Int StoredVersion = JDB.solveInt(".SCX_ExtraData.VersionRecords." + ScriptID)
  Int NewVersion = checkVersion(StoredVersion)
  JDB.solveIntSetter(".SCX_ExtraData.VersionRecords." + ScriptID, NewVersion, True)
  reloadMaintenence()
EndFunction

Int Function checkVersion(Int aiStoredVersion)
  {Return the new version and the script will update the stored version}
  Return 0
EndFunction

Function reloadMaintenence()
EndFunction

Function _setup()
EndFunction

Function Setup()
EndFunction

Event OnSCXBuildQuestList()
  If !SCXSet
    SCXSet = JMap.getForm(SCX_Library.getJM_QuestList(), "SCX_Settings") as SCX_Settings
  EndIf
  If !SCXLib
    SCXLib = JMap.getForm(SCXSet.JM_QuestList, "SCX_Library") as SCX_Library
  EndIf
  If SCXSet
    If ScriptID
      JMap.setForm(SCXSet.JM_QuestList, ScriptID, Self)
    Else
      Debug.Notification("Issue: Script on quest " + GetName() + " does not have ScriptID! A property failed to be filled. Please contact the mod author.")
      Debug.Trace("Issue: Script on quest " + GetName() + " does not have ScriptID! A property failed to be filled. Please contact the mod author.")
    EndIf
  Else
    Debug.Notification("Issue: SCX_Settings wasn't found! Please check SCX installation.")
    Debug.Trace("Issue: Script on quest " + GetName() + " does not have ScriptID! A property failed to be filled. Please contact the mod author.")
  EndIf
EndEvent

String Function nameGet(Form akTarget)
  If akTarget as SCX_Bundle
    Return (akTarget as SCX_Bundle).ItemForm.GetName()
  ElseIf akTarget as Actor
    Return (akTarget as Actor).GetLeveledActorBase().GetName()
  ElseIf akTarget as ObjectReference
    Return (akTarget as ObjectReference).GetBaseObject().GetName()
  Else
    Return akTarget.GetName()
  EndIf
EndFunction

Int Function getTargetData(Actor akTarget, Bool abGenProfile = False)
  {Data now stored under ActorBase for all actors
  Function will generate new actor profile if no data found && abGenProfile == True}
  Form Target = akTarget.GetLeveledActorBase()
  If Target
    Int Data = JFormDB.findEntry("SCX_ActorData", Target)
    If !Data && abGenProfile
      Bool Basic = False
      If akTarget == PlayerRef || akTarget.IsInFaction(SCXSet.PotentialFollowerFaction)
        Basic = True
      EndIf
      ;Note("No data found for " + nameGet(akTarget))
      Data = SCXLib.generateActorProfile(akTarget, Basic)
      JFormDB.setEntry("SCX_ActorData", Target, Data)
    EndIf
    Return Data
  Else
    Return 0
  EndIf
EndFunction

Int Function getData(Actor akTarget, Int aiTargetData = 0)
  {Convenience function, gets ActorData if needed}
  Int TargetData
  If aiTargetData
    TargetData = aiTargetData
  Else
    TargetData = getTargetData(akTarget)
  EndIf
  Return TargetData
EndFunction

ReferenceAlias Function getSCX_BaseAlias(Int JC_BaseList, String asBaseID = "", Int aiBaseID = -1, Form afBaseID = None)
  {General function to retrieve objects using the SCX method
  Returns a reference alias that should be cast to the correct type}
  If !asBaseID && !aiBaseID && !afBaseID
    Return None
  EndIf
  Quest OwnedQuest
  If JValue.isMap(JC_BaseList)
    OwnedQuest = JMap.getForm(JC_BaseList, asBaseID) as Quest
  ElseIf JValue.isIntegerMap(JC_BaseList)
    OwnedQuest = JIntMap.getForm(JC_BaseList, aiBaseID) as Quest
  ElseIf JValue.isFormMap(JC_BaseList)
    OwnedQuest = JFormMap.getForm(JC_BaseList, afBaseID) as Quest
  EndIf
  If OwnedQuest
    Return OwnedQuest.GetAliasByName(asBaseID) as ReferenceAlias
  Else
    Return None
  EndIf
EndFunction

Int Function getContents(Actor akTarget, String asArchetype, String asType, Int aiTargetData = 0)
  {New setup: a JFormMap for each item type}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, asArchetype) as SCX_BaseItemArchetypes
  If Arch
    Int Index = Arch.ItemTypes.Find(asType)
    If Index != -1
      Int JF_Contents = JMap.getObj(aiTargetData, Arch.ItemContentsKeys[Index])
      If !JF_Contents
        JF_Contents = JFormMap.object()
        JMap.setObj(aiTargetData, Arch.ItemContentsKeys[Index], JF_Contents)
      EndIf
      Return JF_Contents
    EndIf
  EndIf
  Return 0
EndFunction

String Function getMessage(String asKey, Int aiIndex = -1, Bool abTagReplace = True, Int JA_Actors = 0, Int aiActorIndex = -1)
  ;Retrieves the specified message type from the database. Will also perform tag replacement.
  Int JA_MessageList = JDB.solveObj(".SCLExtraData.JM_MessageList." + asKey)
  Int i
  If aiIndex != -1
    i = aiIndex
  Else
    i = Utility.RandomInt(0, JArray.count(JA_MessageList) - 1)
  EndIf

  String ReturnMessage = JArray.getStr(JA_MessageList, i)
  If abTagReplace
    ReturnMessage = replaceTags(ReturnMessage, JA_Actors)
  EndIf
  Return ReturnMessage
EndFunction

String Function replaceTags(String asMessage, Int JA_Actors = 0, Int aiActorIndex = -1) ;Consider making a global?
  {Replaces tokens in strings and replaces them
  Adapted from post by jbezorg
  https://www.creationkit.com/index.php?title=Talk:StringUtil_Script}
  Int iStart = 0
  Int iEnd = 0
  String sReturn = ""
  String sOperator = ""
  iEnd = StringUtil.Find(asMessage, "%", iStart)
  If iEnd == -1
    Return asMessage
  Else
    While (iEnd != -1)
      sOperator = StringUtil.getNthChar(asMessage, iEnd + 1)
      If sOperator == "%"
        sReturn += StringUtil.Substring(asMessage, iStart, iEnd) + "%"
      ElseIf sOperator == "p"
        sReturn += StringUtil.Substring(asMessage, iStart, iEnd) + nameGet(PlayerRef)
      ElseIf sOperator == "t"
        String TagReplace
        Int NumTeammates = SCXSet.TeammatesList.Length
        If NumTeammates == 0
          TagReplace = "they"
        ElseIf NumTeammates > 1
          Int t = Utility.RandomInt(0, NumTeammates - 1)
          Actor Teammate = SCXSet.TeammatesList[t] as Actor
          If Teammate
            TagReplace = nameGet(Teammate)
          Else
            TagReplace = "they"
          EndIf
        Else
          Actor Teammate = SCXSet.TeammatesList[0] as Actor
          If Teammate
            TagReplace = nameGet(Teammate)
          Else
            TagReplace = "they"
          EndIf
        EndIf
        sReturn += StringUtil.Substring(asMessage, iStart, iEnd) + TagReplace
      ElseIf sOperator == "a"
        If JA_Actors
          Int i
          If aiActorIndex >= 0
            i = aiActorIndex
          Else
            i = Utility.RandomInt(0, JArray.count(JA_Actors) - 1)
          EndIf
          sReturn += StringUtil.Substring(asMessage, iStart, iEnd) + nameGet(JArray.getForm(JA_Actors, i))
        EndIf
      ;ElseIf sOperator == "whatever"
      Else
        Issue("Improper format submitted to replaceTags: " + asMessage)
        Return asMessage
      EndIf
      iStart = iEnd + 2
      iEnd = StringUtil.find(asMessage, "%", iStart)
    EndWhile

    sReturn += StringUtil.Substring(asMessage, iStart)
  EndIf
  Return sReturn
EndFunction

String Function addOrdinal(Int aiVal) Global
  {Adds suffix to the end of the number (i.e. 1st, 23rd, etc.)}
  Int NumberLength = StringUtil.GetLength(aiVal as String)
  Int NextLast = StringUtil.GetNthChar(aiVal as String, NumberLength - 2) as Int
  If NextLast == 1
    Return aiVal + "th"
  Else
    Int Last = StringUtil.GetNthChar(aiVal as String, NumberLength - 1) as Int
    If Last == 1
      Return aiVal + "st"
    ElseIf Last == 2
      Return aiVal + "nd"
    ElseIf Last == 3
      Return aiVal + "rd"
    EndIf
  EndIf
EndFunction

String Function roundFlt(Float afVal, Int aiSigFig)
  {Cuts off decimal places for presentation}
  String sVal = afVal as Float
  Return Stringutil.Substring(sVal, 0, Stringutil.Find(sVal, ".") + aiSigFig + 1)
EndFunction

Function JA_eraseIndices(Int JA_Source, Int JA_Remove)
  {Erases values from the source array. JA_Remove is list of indices to remove
  Can't remove values in normal loops, tends to mess up ordering
  If it's a large array, recommended that JA_Remove is retained before running this,
  and released after}
  Int i = JArray.count(JA_Remove)
  While i
    i -= 1
    JArray.eraseIndex(JA_Source, JArray.getInt(JA_Remove, i))
  EndWhile
EndFunction

Function JF_eraseKeys(Int JF_Source, Int JA_Remove)
  Int i = JArray.count(JA_Remove)
  While i
    i -= 1
    JFormMap.removeKey(JF_Source, JArray.getForm(JA_Remove, i))
  EndWhile
EndFunction

Function getTeammates()
  Actor[] teamMates = new Actor[16]
  int numFound = 0
  Cell c = playerRef.getparentCell()
  int num = (c.GetNumRefs(62)) as Int
  while num && numFound<16
    num -= 1
    Actor a = c.GetNthRef(num, 62) as Actor
    if a && a.IsInFaction(SCXSet.CurrentFollowerFaction)
      teamMates[numFound] = a
      numFound += 1
    endIf
  endWhile
EndFunction

Int Function getItemDatabaseEntry(Form akItem)
  {TODO: Look overthis again}
  If akItem as SCX_Bundle  ;Are we using bundles?
    akItem = (akItem as SCX_Bundle).ItemForm
  EndIf

  ;Search formlists for the item
  Int f = SCXSet.SCX_ItemFormlistSearch.GetSize()
  While f
    f -= 1
    FormList flSearch = SCXSet.SCX_ItemFormlistSearch.GetAt(f) as Formlist
    If flSearch.HasForm(akItem)
      Return JFormDB.findEntry("SCX_ItemDatabase", flSearch)
    Endif
  EndWhile

  ;Search for the item directly
  Int JM_DB_ItemEntry = JFormDB.findEntry("SCX_ItemDatabase", akItem)
  If JM_DB_ItemEntry != 0
    Return JM_DB_ItemEntry
  EndIf

  If akItem as Actor
    ;Search for actorbase entry
    ActorBase SearchBase = (akItem as Actor).GetLeveledActorBase()
    JM_DB_ItemEntry = JFormDB.findEntry("SCX_ItemDatabase", SearchBase)
    If JM_DB_ItemEntry != 0
      Return JM_DB_ItemEntry
    EndIf

    ;Search for race entry
    Race SearchRace = SearchBase.GetRace()
    JM_DB_ItemEntry = JFormDB.findEntry("SCX_ItemDatabase", SearchRace)
    If JM_DB_ItemEntry != 0
      Return JM_DB_ItemEntry
    EndIf
  EndIf

  ;Search for the base item directly
  If akItem as ObjectReference
    JM_DB_ItemEntry = JFormDB.findEntry("SCX_ItemDatabase", (akItem as ObjectReference).GetBaseObject())
    If JM_DB_ItemEntry != 0
      Return JM_DB_ItemEntry
    EndIf
  EndIf

  ;Search Keywords
  Int j = SCXSet.SCX_ItemKeywordSearch.GetSize()
  While j
    j -= 1
    Keyword kwSearch = SCXSet.SCX_ItemKeywordSearch.GetAt(j) as Keyword
    If akItem.HasKeyword(kwSearch)
      Return JFormDB.findEntry("SCX_ItemDatabase", kwSearch)
    EndIf
  EndWhile
  Return 0
EndFunction

SCX_BasePerk Function getPerkBase(String asPerkID)
  Return getSCX_BaseAlias(SCXSet.JM_PerkIDs, asPerkID) as SCX_BasePerk
EndFunction

String Function getPerkName(String asPerkID, Int aiPerkLevel = 1)
  Return getPerkBase(asPerkID).getPerkName(aiPerkLevel)
EndFunction

String Function getPerkDescription(String asPerkID, Int aiPerkLevel = 0)
  Return getPerkBase(asPerkID).getDescription(aiPerkLevel)
EndFunction

String Function getPerkRequirements(String asPerkID, Int aiPerkLevel = 0)
  Return getPerkBase(asPerkID).getRequirements(aiPerkLevel)
EndFunction

Spell[] Function getPerkAbilityArray(String asPerkID)
  Return getPerkBase(asPerkID).AbilityArray
EndFunction

Int Function getPerkLevel(Actor akTarget, String asPerkID)
  Return getPerkBase(asPerkID).getPerkLevel(akTarget)
EndFunction

Bool Function canTakePerk(Actor akTarget, String asPerkID, Bool abOverride = False, Int aiTargetData = 0)
  SCX_BasePerk PerkBase = getPerkBase(asPerkID)
  Int CurrentPerkValue = PerkBase.getPerkLevel(akTarget)
  Return PerkBase.canTake(akTarget, CurrentPerkValue + 1, abOverride, aiTargetData)
EndFunction

Function takePerk(Actor akTarget, String asPerkID, Bool abOverride = False)
  getPerkBase(asPerkID).takePerk(akTarget, abOverride)
EndFunction

Function takeUpPerks(Actor akTarget, String asPerkID, Int aiPerkLevel)
  {Takes perk level listed as well as all perk levels below it}
  Spell[] a = getPerkAbilityArray(asPerkID)
  Int i
  If aiPerkLevel > a.Length - 1
    aiPerkLevel = a.Length - 1
  EndIf
  While i < aiPerkLevel
    i += 1
    If !akTarget.HasSpell(a[i])
      akTarget.AddSpell(a[i], True)
    EndIf
  EndWhile
EndFunction

Bool Function canTakeAnyPerk(Actor akTarget)
  {Checks if actor can take any perk}
  Int JM_MainPerkList = SCXSet.JM_PerkIDs
  String asPerkID = JMap.nextKey(JM_MainPerkList)
  While asPerkID
    If canTakePerk(akTarget, asPerkID)
      Return True
    EndIf
    asPerkID = JMap.nextKey(JM_MainPerkList, asPerkID)
  EndWhile
  Return False
EndFunction

Float Function sumWeightValues(Int JF_ContentsMap)
  {Sums up the weight of a single contents map}
  If !JValue.empty(JF_ContentsMap)
    Return JValue.evalLuaFlt(JF_ContentsMap, "return jc.accumulateValues(jobject, function(a,b) return a + b end, '.WeightValue')", -1)
  Else
    Return 0
  EndIf
EndFunction

Float Function sumStoredWeightValues(Int JF_ContentsMap, String[] aiItemTypes)
  {Checks if StoredItemType is on the aiItemTypes list, then adds its weight value.}
  Float Total
  Form ItemKey = JFormMap.nextKey(JF_ContentsMap)
  While ItemKey
    Int JM_ItemEntry = JFormMap.getObj(JF_ContentsMap, ItemKey)
    String StoredType = JMap.getStr(JM_ItemEntry, "StoredItemType")
    If aiItemTypes.find(StoredType) != -1
      Total += JMap.getFlt(JM_ItemEntry, "WeightValue")
    EndIf
    ItemKey = JFormMap.nextKey(JF_ContentsMap, ItemKey)
  EndWhile
  Return Total
EndFunction

Int Function countItemType(Actor akTarget, String asArch, String asType, Bool abCountForms = False, Int aiTargetData = 0)
  {Will normally just count same forms as 1, use abCountForms to count forms in bundles}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int JF_ST_Contents = getContents(akTarget, asArch, asType, aiTargetData)
  If !abCountForms
    Return JValue.count(JF_ST_Contents)
  Else
    Form ItemKey = JFormMap.nextKey(JF_ST_Contents)
    Int Num
    While ItemKey
      If ItemKey as ObjectReference
        If ItemKey as SCX_Bundle
          Num += (ItemKey as SCX_Bundle).ItemNum
        Else
          Num += 1
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_ST_Contents, ItemKey)
    EndWhile
    Return Num
  EndIf
EndFunction

SCX_Bundle Function findBundle(Int JF_ContentsMap, Form akBaseObject)
  {Searches through all items in an actor's content array, returns bundle}
  Form SearchRef = JFormMap.nextKey(JF_ContentsMap)
  While SearchRef
    If SearchRef as ObjectReference
      If SearchRef as SCX_Bundle
        Form SearchForm = (SearchRef as SCX_Bundle).ItemForm
        If SearchForm == akBaseObject
          Return SearchRef as SCX_Bundle
        EndIf
      EndIf
    EndIf
    SearchRef = JFormMap.nextKey(JF_ContentsMap, SearchRef)
  EndWhile
  Return None
EndFunction

Int Function findBundleEntry(Int JF_ContentsMap, Form akBaseObject)
  {Searches through all items in an actor's content array, returns the ItemEntry ID}
  Form SearchRef = JFormMap.nextKey(JF_ContentsMap)
  While SearchRef
    If SearchRef as ObjectReference
      If SearchRef as SCX_Bundle
        Form SearchForm = (SearchRef as SCX_Bundle).ItemForm
        If SearchForm == akBaseObject
          Return JFormMap.getObj(JF_ContentsMap, SearchRef)
        EndIf
      EndIf
    EndIf
    SearchRef = JFormMap.nextKey(JF_ContentsMap, SearchRef)
  EndWhile
  Return 0
EndFunction

ObjectReference Function findRefFromBase(Int JF_Contents, Form akBaseObject)
  Form i = JFormMap.nextKey(JF_Contents)
  While i
    If i as ObjectReference
      If (i as ObjectReference).GetBaseObject() == akBaseObject
        Return i as ObjectReference
      EndIf
    EndIf
    i = JFormMap.nextKey(JF_Contents, i)
  EndWhile
  Return None
EndFunction

String Function getRaceString(Actor akTarget)
  Return SCXSet.GameLibrary.getRaceString(akTarget)
EndFunction
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Debug Functions
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bool Function PlayerThought(Actor akTarget, String sMessage1 = "", String sMessage2 = "", String sMessage3 = "", Int iOverride = 0)
  {Use this to display player information. Returns whether the passed actor is
  the player.
  Make sure sMessage1 is 1st person, sMessage2 is 2nd person, sMessage3 is 3rd person
  Make sure at least one is filled: it will default to it regardless of setting
  Use iOverride to force a particular message}

  If akTarget == PlayerRef
    Int Setting = SCXSet.PlayerMessagePOV
    If Setting == -1
      Return True
    EndIf
    If (sMessage1 && Setting == 1) || iOverride == 1
      Debug.Notification(sMessage1)
    ElseIf (sMessage2 && Setting == 2) || iOverride == 2
      Debug.Notification(sMessage3)
    ElseIf (sMessage3 && Setting == 3) || iOverride == 3
      Debug.Notification(sMessage3)
    ElseIf sMessage3
      Debug.Notification(sMessage3)
    ElseIf sMessage1
      Debug.Notification(sMessage1)
    ElseIf sMessage2
      Debug.Notification(sMessage2)
    Else
      Issue("Empty player thought. Skipping...", 1)
    EndIf
    Return True
  Else
    Return False
  EndIf
EndFunction

Bool Function PlayerThoughtDB(Actor akTarget, String sKey, Int iOverride = 0, Int JA_Actors = 0, Int aiActorIndex = -1)
  {Use this to display player information. Returns whether the passed actor is
  the player.
  Pulls message from database; make sure sKey is valid.
  Will add POV int to end of key, so omit it in the parameter}
  If akTarget == PlayerRef
    Int Setting
    If iOverride != 0
      Setting = iOverride
    Else
      Setting = SCXSet.PlayerMessagePOV
    EndIf
    If Setting == -1
      Return True
    EndIf
    String sMessage = SCXLib.getMessage(sKey + Setting, -1, True, JA_Actors, aiActorIndex)
    If sMessage
      Debug.Notification(sMessage)
    Else
      PlayerThought(akTarget, SCXLib.getMessage(sKey + 1, -1, True, JA_Actors, aiActorIndex), SCXLib.getMessage(sKey + 2, -1, True, JA_Actors, aiActorIndex), SCXLib.getMessage(sKey + 3, -1, True, JA_Actors, aiActorIndex))
    EndIf
    Return True
  Else
    Return False
  EndIf
EndFunction

Function Popup(String sMessage)
  {Shows MessageBox, then waits for menu to be closed before continuing}
  Debug.MessageBox(DebugName + sMessage)
  Halt()
EndFunction

Function Halt()
  {Wait for menu to be closed before continuing}
  While Utility.IsInMenuMode()
    Utility.Wait(0.5)
  EndWhile
EndFunction

Function Note(String sMessage)
  Debug.Notification(DebugName + sMessage)
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Notice(String sMessage)
  {Displays message in notifications and logs if globals are active}
  If EnableDebugMessages
    Debug.Notification(DebugName + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Issue(String sMessage, Int iSeverity = 0, Bool bOverride = False)
  {Displays a serious message in notifications and logs if globals are active
  Use bOverride to ignore globals}
  If bOverride || EnableDebugMessages
    String Level
    If iSeverity == 0
      Level = "Info"
    ElseIf iSeverity == 1
      Level = "Warning"
    ElseIf iSeverity == 2
      Level = "Error"
    EndIf
    Debug.Notification(DebugName + Level + " " + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage, iSeverity)
EndFunction

Float StartTime
Function StartScriptTimer()
  StartTime = Utility.GetCurrentRealTime()
EndFunction

Function StopScriptTimer()
  Note("Time elapsed = " + (Utility.GetCurrentRealTime() - StartTime))
  StartTime = 0
EndFunction
