ScriptName SCX_Settings Extends SCX_BaseQuest

Event OnInit()
  JMap.setForm(SCXSet.JM_QuestList, "SCX_Settings", Self)
EndEvent

SCX_GameLibrary Property GameLibrary Auto
;ID = "SCX_Settings"
;Tracking Settings *************************************************************
GlobalVariable Property SCX_SET_EnableFollowerTracking Auto;Default 0
Bool Property EnableFollowerTracking
  Bool Function Get()
    Return SCX_SET_EnableFollowerTracking.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_val)
    If a_val
      SCX_SET_EnableFollowerTracking.SetValueInt(1)
    Else
      SCX_SET_EnableFollowerTracking.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableUniqueTracking Auto ;Default 0
Bool Property EnableUniqueTracking
  Bool Function Get()
    Return SCX_SET_EnableUniqueTracking.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_val)
    If a_val
      SCX_SET_EnableUniqueTracking.SetValueInt(1)
    Else
      SCX_SET_EnableUniqueTracking.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableNPCTracking Auto ;Default 0
Bool Property EnableNPCTracking
  Bool Function Get()
    Return SCX_SET_EnableNPCTracking.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_val)
    If a_val
      SCX_SET_EnableNPCTracking.SetValueInt(1)
    Else
      SCX_SET_EnableNPCTracking.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_MaxActorTracking Auto ;Default 20
Int Property MaxActorTracking
  Int Function Get()
    Return SCX_SET_MaxActorTracking.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    If a_val > 0
      SCX_SET_MaxActorTracking.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

;Messages Settings *************************************************************
GlobalVariable Property SCX_SET_PlayerMessagePOV Auto ;Default 0
Int Property PlayerMessagePOV
  Int Function Get()
    Return SCX_SET_PlayerMessagePOV.GetValueInt()
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 3
      SCX_SET_PlayerMessagePOV.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

;Action Keys *******************************************************************
GlobalVariable Property SCX_SET_MenuKey Auto ;Default 24
Int _MenuKey = 24
Int Property MenuKey
  Int Function Get()
    Int iKey = SCX_SET_MenuKey.GetValueInt()
    If _MenuKey != iKey  ;In case someone changes the global when we aren't looking
      Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
      ModEvent.Send(KeyModChange)
      _MenuKey = iKey
    EndIf
    Return iKey
  EndFunction
  Function Set(Int a_val)
    SCX_SET_MenuKey.SetValueInt(a_val)
    _MenuKey = a_val
    Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
    ModEvent.Send(KeyModChange)
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_StatusKey Auto ;Default 0
Int _StatusKey = 24
Int Property StatusKey
  Int Function Get()
    Int iKey = SCX_SET_StatusKey.GetValueInt()
    If _StatusKey != iKey  ;In case someone changes the global when we aren't looking
      Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
      ModEvent.Send(KeyModChange)
      _StatusKey = iKey
    EndIf
    Return iKey
  EndFunction
  Function Set(Int a_val)
    SCX_SET_StatusKey.SetValueInt(a_val)
    _StatusKey = a_val
    Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
    ModEvent.Send(KeyModChange)
  EndFunction
EndProperty

;Debug Settings ****************************************************************
GlobalVariable Property SCX_SET_DebugEnable Auto  ;Default 0 (False)
Bool Property DebugEnable
  Bool Function Get()
    Return SCX_SET_DebugEnable.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCX_SET_DebugEnable.SetValueInt(1)
    Else
      SCX_SET_DebugEnable.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

;Update Timing Settings --------------------------------------------------------
GlobalVariable Property SCX_SET_UpdateRate Auto ;Default 10
Float Property UpdateRate
  Float Function Get()
    Return SCX_SET_UpdateRate.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      SCX_SET_UpdateRate.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_UpdateDelay Auto ;Default 0.5
Float Property UpdateDelay
  Float Function Get()
    Return SCX_SET_UpdateDelay.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      SCX_SET_UpdateDelay.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

;Mod Checks --------------------------------------------------------------------
Bool Property UIExtensionsInstalled
  Bool Function Get()
    Return SCX_Library.isModInstalled("UIExtensions.esp")
  EndFunction
EndProperty

Bool Property HideUIEWarning Auto

Bool Property NiOverrideInstalled Auto
Bool Property HideNiOverrideWarning Auto

Bool Property FNISInstalled Auto

Bool Property SLIF_Installed Auto

GlobalVariable Property SCX_SET_Enabled Auto  ;Default 0 (False)
Bool Property SCX_Active
  Bool Function Get()
    Return SCX_SET_Enabled.GetValueInt() as Bool
  EndFunction
  Function Set(Bool a_value)
    If a_value
      SCX_SET_Enabled.SetValueInt(1)
    Else
      SCX_SET_Enabled.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

FormList Property SCX_ItemFormlistSearch Auto
FormList Property SCX_ItemKeywordSearch Auto
Quest Property SCX_MonitorManagerQuest Auto
Quest Property SCX_MonitorFinderQuest Auto
Quest Property SCX_MonitorCycleQuest Auto
Package Property SCX_ActorHoldPackage Auto
SCX_ModConfigMenu Property SCX_ModConfigMenuQuest Auto
Form[] Property TeammatesList
  Form[] Function Get()
    Return (SCX_MonitorFinderQuest as SCX_MonitorFinder).TeammatesList
  EndFunction
EndProperty
Message Property SCX_MES_TakePerk Auto
FormList Property SCX_TrackRaceList Auto
Form[] Property LoadedActors
  Form[] Function Get()
    Return (SCX_MonitorFinderQuest as SCX_MonitorFinder).LoadedActors
  EndFunction
EndProperty

Container Property SCX_TransferContainerBase Auto
ObjectReference Property _TransferChest01 Auto
ObjectReference Property SCX_TransferChest01
  ObjectReference Function Get()
    If !_TransferChest01
      Return PlayerRef.PlaceAtMe(SCX_TransferContainerBase, 1, False, False)
    Else
      Return _TransferChest01
    EndIf
  EndFunction
EndProperty

Container Property SCX_TransferContainer2Base Auto
ObjectReference Property _TransferChest02 Auto
ObjectReference Property SCX_TransferChest02
  ObjectReference Function Get()
    If !_TransferChest02
      Return PlayerRef.PlaceAtMe(SCX_TransferContainer2Base, 1, False, False)
    Else
      Return _TransferChest02
    EndIf
  EndFunction
EndProperty

Container Property SCX_BundleBase Auto

Faction Property PotentialFollowerFaction
  Faction Function Get()
    If SCX_Library.isModInstalled("Skyrim.esm")
      Return Game.GetFormFromFile(0x0005C84D, "Skyrim.esm") as Faction
    EndIf
  EndFunction
EndProperty

Faction Property CurrentFollowerFaction
  Faction Function Get()
    If SCX_Library.isModInstalled("Skyrim.esm")
      Return Game.GetFormFromFile(0x0005C84E, "Skyrim.esm") as Faction
    EndIf
  EndFunction
EndProperty

Keyword Property ActorTypeNPC
  Keyword Function get()
    If SCX_Library.isModInstalled("Skyrim.esm")
      Return Game.GetFormFromFile(0x00013794, "Skyrim.esm") as Keyword
    EndIf
  EndFunction
EndProperty

Int Property JM_DebugMessageList Auto
Int Property JM_QuestList
  Int Function Get()
    Int QuestList = JDB.solveObj(".SCX_ExtraData.JM_QuestList")
    If !JValue.isExists(QuestList) || !JValue.isMap(QuestList)
      QuestList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_QuestList", QuestList, True)
      Int Handle = ModEvent.Create("SCX_BuildQuestList")
      ModEvent.Send(Handle)
    EndIf
    Return QuestList
  EndFunction
EndProperty

Int Property JM_RefAliasList
  Int Function Get()
    Int RefAliasList = JDB.solveObj(".SCX_ExtraData.JM_RefAliasList")
    If !JValue.isExists(RefAliasList) || !JValue.isMap(RefAliasList)
      RefAliasList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_RefAliasList", RefAliasList, True)
      Int Handle = ModEvent.Create("SCX_BuildRefAliasList")
      ModEvent.Send(Handle)
    EndIf
    Return RefAliasList
  EndFunction
EndProperty

Int Property JM_BaseMonitorList
  Int Function Get()
    Int RefAliasList = JDB.solveObj(".SCX_ExtraData.JM_BaseMonitorList")
    If !JValue.isExists(RefAliasList) || !JValue.isMap(RefAliasList)
      RefAliasList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_BaseMonitorList", RefAliasList, True)
      Int Handle = ModEvent.Create("SCX_BuildMonitorList")
      ModEvent.Send(Handle)
    EndIf
    Return RefAliasList
  EndFunction
EndProperty

Int Property JM_BaseLibraryList
  Int Function Get()
    Int LibList = JDB.solveObj(".SCX_ExtraData.JM_BaseLibraryList")
    If !JValue.isExists(LibList) || !JValue.isMap(LibList)
      LibList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_BaseLibraryList", LibList, True)
      Int Handle = ModEvent.Create("SCX_BuildLibraryList")
      ModEvent.Send(Handle)
    EndIf
    Return LibList
  EndFunction
EndProperty

Int Property JM_PerkIDs
  Int Function Get()
    Int PerkList = JDB.solveObj(".SCX_ExtraData.JM_PerkList")
    If !JValue.isExists(PerkList) || !JValue.isMap(PerkList)
      PerkList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_PerkList", PerkList, True)
      Int Handle = ModEvent.Create("SCX_BuildPerkList")
      ModEvent.Send(Handle)
    EndIf
    Return PerkList
  EndFunction
EndProperty

Int Property JM_BaseArchetypes
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_BaseArchetypes")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_BaseArchetypes", ArchList, True)
      Int Handle = ModEvent.Create("SCX_BuildArchetypeList")
      ModEvent.Send(Handle)
    EndIf
    Return ArchList
  EndFunction
EndProperty

Int Property JM_BaseBodyEdits
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_BaseBodyEdits")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_BaseBodyEdits", ArchList, True)
      Int Handle = ModEvent.Create("SCX_BuildBodyEdits")
      ModEvent.Send(Handle)
    EndIf
    Return ArchList
  EndFunction
EndProperty

Int Property JI_BaseItemTypes
  Int Function Get()
    Int TypeList = JDB.solveObj(".SCX_ExtraData.JI_BaseItemTypes")
    If !JValue.isExists(TypeList) || !JValue.isIntegerMap(TypeList)
      TypeList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JI_BaseItemTypes", TypeList, True)
      Int Handle = ModEvent.Create("SCX_BuildItemTypes")
      ModEvent.Send(Handle)
    EndIf
    Return TypeList
  EndFunction
EndProperty

Int Property JM_MessageList
  Int Function Get()
    Int MessageList = JDB.solveObj(".SCX_ExtraData.JM_MessageList")
    If !JValue.isExists(MessageList) || !JValue.isMap(MessageList)
      MessageList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_MessageList", MessageList, True)
      Int Handle = ModEvent.Create("SCX_BuildMessageLists")
      ModEvent.Send(Handle)
    EndIf
    Return MessageList
  EndFunction
EndProperty

Formlist Property SCX_DebugSpellList Auto
