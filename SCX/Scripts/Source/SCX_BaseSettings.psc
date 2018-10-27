ScriptName SCX_BaseSettings Extends SCX_BaseQuest

String Property ModFolderName Auto

Function _reloadMaintenence()
  RegisterForModEvent("SCX_BuildSettingsList", "OnSettingsListBuild")
EndFunction

Event OnSettingsListBuild()
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
EndEvent

Int Function _getSCX_JC_List()
  Return SCXSet.JM_SettingsList
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
      JValue.writeToFile(DefaultProfile, "Data/SCX/" + ModFolderName + "/Profiles/DefaultProfile.json")
      _CurrentProfileKey = "DefaultProfile.json"
      JM_Settings = JMap.getObj(JM_ProfileList, _CurrentProfileKey)
    EndIf
    Return _CurrentProfileKey
  EndFunction
  Function Set(String a_val)
    _CurrentProfileKey = a_val
    JM_Settings = JMap.getObj(JM_ProfileList, _CurrentProfileKey)
  EndFunction
EndProperty

Int Property JM_ProfileList
  Int Function Get()
    Return JValue.readFromDirectory("Data/SCX/" + ModFolderName + "/Profiles/", ".json")
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
  JValue.writeToFile(JM_Settings, "Data/SCX/" + ModFolderName + "/Profiles/" + CurrentProfileKey)
EndFunction

Function addMCMOptions(SCX_ModConfigMenu MCM, Int JI_Options)
  JIntMap.setStr(JI_Options, MCM.AddMenuOption(ModFolderName + " Profile", CurrentProfileKey), "Setting." + _getStrKey() + ".SelectProfile")
  JIntMap.setStr(JI_Options, MCM.AddInputOption(ModFolderName + "Create New Profile", ""), "Setting." + _getStrKey() + ".CreateProfile")
EndFunction

Int[] Function getMCMMenuOptions01(SCX_ModConfigMenu MCM, String asValue)
  Int[] ReturnArray = New Int[2]
  If asValue == "SelectProfile"
    ReturnArray[0] = JMap.allKeysPArray(JM_ProfileList).find(CurrentProfileKey)
    ReturnArray[1] = 0
  EndIf
  Return ReturnArray
EndFunction

String[] Function getMCMMenuOptions02(SCX_ModConfigMenu MCM, String asValue)
  String[] ReturnArray
  If asValue == "SelectProfile"
    ReturnArray = JMap.allKeysPArray(JM_ProfileList)
  EndIf
  Return ReturnArray
EndFunction

Function setMenuOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Int aiIndex)
  If asValue == "SelectProfile"
    CurrentProfileKey = JMap.getNthKey(JM_ProfileList, aiIndex)
    MCM.ForcePageReset()
  EndIf
EndFunction

String Function getInputStartText(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  Return ".json"
EndFunction

Function setInputOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, String asInput)
  If asValue == "CreateProfile"
    Int NewProfile = JMap.object()
    JMap.addPairs(NewProfile, JM_Settings, False)
    JValue.writeToFile(NewProfile, "Data/SCX/" + ModFolderName + "/Profiles/" + asInput)
    CurrentProfileKey = asInput
  EndIf
EndFunction

Float[] Function getSliderOptions(SCX_ModConfigMenu MCM, String asValue)
  Return None
EndFunction

Function setSliderOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Float afValue)
EndFunction

Function setMCMSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SelectProfile"
    MCM.setInfoText("$SCXMCMSelectSettingsProfileInfo")
  ElseIf asValue == "CreateProfile"
    MCM.setInfoText("$SCXMCMCreateSettingsProfileInfo")
  EndIf
EndFunction
