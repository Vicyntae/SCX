ScriptName SCX_Settings Extends SCX_BaseSettings

SCX_GameLibrary Property GameLibrary Auto
;ID = "SCX_Settings"

Event OnInit()
EndEvent

;Tracking Settings *************************************************************
GlobalVariable Property SCX_SET_EnableFollowerTracking Auto;Default 0
Bool Property EnableFollowerTracking
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableFollowerTracking")
      JMap.setInt(JM_Settings, "EnableFollowerTracking", 1)
      SCX_SET_EnableFollowerTracking.SetValueInt(1)
    EndIf
    Bool GloVar = SCX_SET_EnableFollowerTracking.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableFollowerTracking")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableFollowerTracking", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableFollowerTracking", 1)
      SCX_SET_EnableFollowerTracking.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableFollowerTracking", 0)
      SCX_SET_EnableFollowerTracking.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableUniqueTracking Auto ;Default 0
Bool Property EnableUniqueTracking
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableUniqueTracking")
      JMap.setInt(JM_Settings, "EnableUniqueTracking", 1)
      SCX_SET_EnableUniqueTracking.SetValueInt(1)
    EndIf
    Bool GloVar = SCX_SET_EnableUniqueTracking.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableUniqueTracking")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableUniqueTracking", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableUniqueTracking", 1)
      SCX_SET_EnableUniqueTracking.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableUniqueTracking", 0)
      SCX_SET_EnableUniqueTracking.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableNPCTracking Auto ;Default 0
Bool Property EnableNPCTracking
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "EnableNPCTracking")
      JMap.setInt(JM_Settings, "EnableNPCTracking", 1)
      SCX_SET_EnableNPCTracking.SetValueInt(1)
    EndIf
    Bool GloVar = SCX_SET_EnableNPCTracking.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "EnableNPCTracking")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "EnableNPCTracking", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "EnableNPCTracking", 1)
      SCX_SET_EnableNPCTracking.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "EnableNPCTracking", 0)
      SCX_SET_EnableNPCTracking.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_MaxActorTracking Auto ;Default 20
Int Property MaxActorTracking
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "MaxActorTracking")
      JMap.setInt(JM_Settings, "MaxActorTracking", 20)
      SCX_SET_MaxActorTracking.SetValueInt(20)
    EndIf
    Int GloVar = SCX_SET_MaxActorTracking.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "MaxActorTracking")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "MaxActorTracking", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0
      JMap.setInt(JM_Settings, "MaxActorTracking", a_val)
      SCX_SET_MaxActorTracking.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

;Messages Settings *************************************************************
GlobalVariable Property SCX_SET_PlayerMessagePOV Auto ;Default 0
Int Property PlayerMessagePOV
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "PlayerMessagePOV")
      JMap.setInt(JM_Settings, "PlayerMessagePOV", 3)
      SCX_SET_PlayerMessagePOV.SetValueInt(3)
    EndIf
    Int GloVar = SCX_SET_PlayerMessagePOV.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "PlayerMessagePOV")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "PlayerMessagePOV", MapVar)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    If a_val >= 0 && a_val <= 3
      JMap.setInt(JM_Settings, "PlayerMessagePOV", a_val)
      SCX_SET_PlayerMessagePOV.SetValueInt(a_val)
    EndIf
  EndFunction
EndProperty

;Action Keys *******************************************************************
GlobalVariable Property SCX_SET_MenuKey Auto ;Default 24
Int Property MenuKey
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "MenuKey")
      JMap.setInt(JM_Settings, "MenuKey", 0)
      SCX_SET_MenuKey.SetValueInt(0)
    EndIf
    Int GloVar = SCX_SET_MenuKey.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "MenuKey")
    If GloVar != MapVar  ;In case someone changes the global when we aren't looking
      MapVar = GloVar
      JMap.setInt(JM_Settings, "MenuKey", MapVar)
      Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
      ModEvent.Send(KeyModChange)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    JMap.setInt(JM_Settings, "MenuKey", a_val)
    SCX_SET_MenuKey.SetValueInt(a_val)
    Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
    ModEvent.Send(KeyModChange)
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_StatusKey Auto ;Default 0
Int Property StatusKey
  Int Function Get()
    If !JMap.hasKey(JM_Settings, "StatusKey")
      JMap.setInt(JM_Settings, "StatusKey", 0)
      SCX_SET_StatusKey.SetValueInt(0)
    EndIf
    Int GloVar = SCX_SET_StatusKey.GetValueInt()
    Int MapVar = JMap.getInt(JM_Settings, "StatusKey")
    If GloVar != MapVar  ;In case someone changes the global when we aren't looking
      MapVar = GloVar
      JMap.setInt(JM_Settings, "StatusKey", MapVar)
      Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
      ModEvent.Send(KeyModChange)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Int a_val)
    JMap.setInt(JM_Settings, "StatusKey", a_val)
    SCX_SET_StatusKey.SetValueInt(a_val)
    Int KeyModChange = ModEvent.Create("SCX_KeyBindChange")
    ModEvent.Send(KeyModChange)
  EndFunction
EndProperty

;Debug Settings ****************************************************************
GlobalVariable Property SCX_SET_DebugEnable Auto  ;Default 0 (False)
Bool Property DebugEnable
  Bool Function Get()
    If !JMap.hasKey(JM_Settings, "DebugEnable")
      JMap.setInt(JM_Settings, "DebugEnable", 0)
      SCX_SET_DebugEnable.SetValueInt(0)
    EndIf
    Bool GloVar = SCX_SET_DebugEnable.GetValueInt() as Bool
    Bool MapVar = JMap.getInt(JM_Settings, "DebugEnable")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setInt(JM_Settings, "DebugEnable", MapVar as Int)
    EndIf
    Return MapVar
  EndFunction
  Function Set(Bool a_val)
    If a_val
      JMap.setInt(JM_Settings, "DebugEnable", 1)
      SCX_SET_DebugEnable.SetValueInt(1)
    Else
      JMap.setInt(JM_Settings, "DebugEnable", 0)
      SCX_SET_DebugEnable.SetValueInt(0)
    EndIf
  EndFunction
EndProperty

;Update Timing Settings --------------------------------------------------------
GlobalVariable Property SCX_SET_UpdateRate Auto ;Default 10
Float Property UpdateRate
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "UpdateRate")
      JMap.setFlt(JM_Settings, "UpdateRate", 15)
      SCX_SET_UpdateRate.SetValue(15)
    EndIf
    Float GloVar = SCX_SET_UpdateRate.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "UpdateRate")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "UpdateRate", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val > 0
      JMap.setFlt(JM_Settings, "UpdateRate", a_val)
      SCX_SET_UpdateRate.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_UpdateDelay Auto ;Default 0.5
Float Property UpdateDelay
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "UpdateDelay")
      JMap.setFlt(JM_Settings, "UpdateDelay", 1)
      SCX_SET_UpdateDelay.SetValue(1)
    EndIf
    Float GloVar = SCX_SET_UpdateDelay.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "UpdateDelay")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "UpdateDelay", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val > 0
      JMap.setFlt(JM_Settings, "UpdateDelay", a_val)
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
Formlist Property SCX_RejectList Auto
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
    If GameLibrary
      Return GameLibrary.PotentialFollowerFaction
    EndIf
  EndFunction
EndProperty

Faction Property CurrentFollowerFaction
  Faction Function Get()
    If GameLibrary
      Return GameLibrary.CurrentFollowerFaction
    EndIf
  EndFunction
EndProperty

Keyword Property ActorTypeNPC
  Keyword Function get()
    If GameLibrary
      Return GameLibrary.ActorTypeNPC
    Else
      Return None
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
      JMap.setForm(QuestList, "SCX_Settings", Self)
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

Int Property JM_SettingsList
  Int Function Get()
    Int SettingsList = JDB.solveObj(".SCX_ExtraData.JM_SettingsList")
    If !JValue.isExists(SettingsList) || !JValue.isMap(SettingsList)
      SettingsList = JMap.object()
      JMap.setForm(SettingsList, "SCX_Settings", Self)
      JDB.solveObjSetter(".SCX_ExtraData.JM_SettingsList", SettingsList, True)
      Int Handle = ModEvent.Create("SCX_BuildSettingsList")
      ModEvent.Send(Handle)
    EndIf
    Return SettingsList
  EndFunction
EndProperty

Formlist Property SCX_DebugSpellList Auto
