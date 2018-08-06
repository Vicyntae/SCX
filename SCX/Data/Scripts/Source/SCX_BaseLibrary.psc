ScriptName SCX_BaseLibrary Extends SCX_BaseQuest Hidden

;*******************************************************************************
;Setup Functions
;*******************************************************************************

Event OnSCXBuildLibraryList()
  If !SCXSet
    SCXSet = JMap.getForm(SCX_Library.getJM_QuestList(), "SCX_Settings") as SCX_Settings
  EndIf
  If !SCXLib
    SCXLib = JMap.getForm(SCXSet.JM_QuestList, "SCX_Library") as SCX_Library
  EndIf
  If SCXSet
    If ScriptID
      If Self as SCX_BaseLibrary
        Int JC_Container = _getSCX_JC_List()
        If JValue.isMap(JC_Container)
          JMap.setForm(JC_Container, _getStrKey(), Self)
        ElseIf JValue.isIntegerMap(JC_Container)
          JIntMap.setForm(JC_Container, _getIntKey(), Self)
        EndIF
      EndIf
    Else
      Debug.Notification("Issue: Script on quest " + GetName() + " does not have ScriptID! A property failed to be filled. Please contact the mod author.")
      Debug.Trace("Issue: Script on quest " + GetName() + " does not have ScriptID! A property failed to be filled. Please contact the mod author.")
    EndIf
  Else
    Debug.Notification("Issue: SCX_Settings wasn't found! Please check SCX installation.")
    Debug.Trace("Issue: Script on quest " + GetName() + " does not have ScriptID! A property failed to be filled. Please contact the mod author.")
  EndIf
EndEvent

Function _setup()
  RegisterForModEvent("SCX_BuildLibraryList", "OnSCXBuildLibraryList")
EndFunction

Function _reloadMaintenence()
  Parent._reloadMaintenence()
  RegisterForModEvent("SCX_BuildLibraryList", "OnSCXBuildLibraryList")
EndFunction

Int Function _getSCX_JC_List()
  Return SCXSet.JM_BaseLibraryList
EndFunction

;*******************************************************************************
;ActorData Functions
;*******************************************************************************
Int Property genActorProfilePriority Auto
Function genActorProfile(Actor akTarget, Bool abBasic, Int aiTargetData)
EndFunction

;*******************************************************************************
;MCM Functions
;*******************************************************************************
Int Property addMCMActorInformationPriority Auto
Function addMCMActorInformation(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
EndFunction

Function addMCMActorRecords(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
EndFunction

Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
EndFunction

Float[] Function getSliderOptions(SCX_ModConfigMenu MCM, String asValue)
  Float[] SliderValues = New Float[5]
  SliderValues[0] = 0
  SliderValues[1] = 0
  SliderValues[2] = 1
  SliderValues[3] = 0
  SliderValues[4] = 1
  Return SliderValues
EndFunction

Function setSliderOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Float afValue)
EndFunction

Int[] Function getMCMMenuOptions01(SCX_ModConfigMenu MCM, String asValue)
  Int[] SliderValues = New Int[2]
  SliderValues[0] = 0
  SliderValues[1] = 0
  Return SliderValues
EndFunction

String[] Function getMCMMenuOptions02(SCX_ModConfigMenu MCM, String asValue)
EndFunction

Function setMenuOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Int aiIndex)
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
EndFunction

;*******************************************************************************
;Status Functions
;*******************************************************************************
Function addQuickStatusMessage(Actor akTarget, Int JA_Status)
EndFunction

Function addFullStatusMessage(Actor akTarget, Int JA_Status)
EndFunction

;*******************************************************************************
;UIE Functions
;*******************************************************************************
String[] Property ActorMenuNames Auto
Int Property ActorMainMenuPriority = 0 Auto
Function openActorMainMenu(Actor akTarget = None, Int aiMode = 0)
EndFunction

Int Property addUIEActorStatsPriority Auto
Function addUIEActorStats(Actor akTarget, UIListMenu UIList, Int JA_OptionList, Int aiMode = 0)
EndFunction

Bool Function handleUIEStatFromList(Actor akTarget, String asValue)
EndFunction

Function handleActorExtraction(Actor akSource, Actor akTarget, String asArch, String asType, ObjectReference akPosition)
EndFunction

;*******************************************************************************
;Monitor Functions
;*******************************************************************************
Function monitorSetup(SCX_Monitor akMonitor, Actor akTarget)
EndFunction

Function monitorCleanup(SCX_Monitor akMonitor, Actor akTarget)
EndFunction

Int Property monitorUpdatePriority Auto
Function monitorUpdate(SCX_Monitor akMonitor, Actor akTarget, Int aiTargetData, Float afTimePassed, Float afCurrentUpdateTime, Bool abDailyUpdate)
EndFunction

Function monitorDeath(SCX_Monitor akMonitor, Actor akTarget, Actor akKiller)
EndFunction

Function monitorReloadMaintenence(SCX_Monitor Mon, Actor akTarget)
EndFunction
