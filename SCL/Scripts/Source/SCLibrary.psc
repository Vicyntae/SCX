ScriptName SCLibrary Extends SCX_BaseLibrary
;*******************************************************************************
;Variables and Properties
;*******************************************************************************
SCLSettings Property SCLSet Auto
Int Property JCReqAPI = 3 Auto
Int Property JCReqFV = 3 Auto

SCX_BaseItemArchetypes Property Stomach Auto
SCX_BaseBodyEdit Property Belly Auto

;Others ************************************************************************
Int ScriptVersion = 1
Int Function checkVersion(Int aiStoredVersion)
  {Return the new version and the script will update the stored version}
  If Belly.CollectKeys.Length == 0
    Belly.CollectKeys = New String[1]
    Belly.CollectKeys[0] = "SCLStomachFullness"
  Else
    If Belly.CollectKeys.find("SCLStomachFullness") == -1
      Belly.CollectKeys = Utility.ResizeStringArray(Belly.CollectKeys, Belly.CollectKeys.Length + 1, "")
      Belly.CollectKeys[Belly.CollectKeys.length - 1] = "SCLStomachFullness"
      ;Belly.CollectKeys = PapyrusUtil.PushString(Belly.CollectKeys, "SCLStomachFullness")
    EndIf
  EndIf
  If ScriptVersion >= 1 && aiStoredVersion < 1
    JFormDB.solveIntSetter(SCLSet.SCL_DummyNotFoodLarge, ".SCX_ItemDatabase.STIsNotFood", 1, True)
    JFormDB.solveIntSetter(SCLSet.SCL_DummyNotFoodMedium, ".SCX_ItemDatabase.STIsNotFood", 1, True)
    JFormDB.solveIntSetter(SCLSet.SCL_DummyNotFoodSmall, ".SCX_ItemDatabase.STIsNotFood", 1, True)
  EndIf
  Return ScriptVersion
EndFunction
;Library Functions *************************************************************
String Function getStomachStatus(Actor akTarget, Int aiTargetData = 0)
EndFunction

;*******************************************************************************
;MCM Functions
;*******************************************************************************
Function addMCMActorInformation(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  MCM.AddHeaderOption("Stomach Stats")
  MCM.AddEmptyOption()
  Bool DEnable = SCXSet.DebugEnable
  String SKey = _getStrKey()
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Status", getStomachStatus(akTarget, aiTargetData)), "Stats." + SKey + ".SCLShowStomachStatus")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Fullness", JMap.getFlt(aiTargetData, "SCLStomachFullness")), "Stats." + SKey + ".SCLShowStomachFullness")
  If DEnable
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Base Capacity", JMap.getFlt(aiTargetData, "SCLStomachCapacity"), "{2}"), "Stats." + SKey + ".SCLEditStomachBase")
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Stretchiness", JMap.getFlt(aiTargetData, "SCLStomachStretch", 1), "x{2}"), "Stats." + SKey + ".SCLEditStomachStretch")
  Else
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Base Capacity", JMap.getFlt(aiTargetData, "SCLStomachCapacity")), "Stats." + SKey + ".SCLShowStomachBase")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Stretchiness", JMap.getFlt(aiTargetData, "SCLStomachStretch")), "Stats." + SKey + ".SCLShowStomachStretch")
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Adjusted Capacity", getAdjCap(akTarget, aiTargetData)), "Stats." + SKey + ".SCLShowStomachAdjBase")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Max Capacity", getMaxCap(akTarget, aiTargetData)), "Stats." + SKey + ".SCLShowStomachMaxBase")

  If DEnable
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Digestion Rate", JMap.getFlt(aiTargetData, "SCLDigestRate")), "Stats." + SKey + ".SCLEditDigestRate")
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Gluttony", JMap.getInt(aiTargetData, "SCLGluttony")), "Stats." + SKey + ".SCLEditGluttony")
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Item Storage Capacity", JMap.getInt(aiTargetData, "SCLStomachStorage")), "Stats." + SKey + ".SCLEditStomachStorage")
  Else
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Digestion Rate", JMap.getFlt(aiTargetData, "SCLDigestRate")), "Stats." + SKey + ".SCLShowDigestRate")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Gluttony", JMap.getInt(aiTargetData, "SCLGluttony")), "Stats." + SKey + ".SCLShowGluttony")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Item Storage Capacity", JMap.getInt(aiTargetData, "SCLStomachStorage")), "Stats." + SKey + ".SCLShowStomachStorage")
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Items Stored", SCXLib.countItemType(akTarget, 2, aiTargetData)), "Stats." + SKey + ".SCLShowNumItemsStored")
  JIntMap.setStr(JI_Options, MCM.AddMenuOption("Show Stomach Contents", ""), "Stats." + SKey + ".SCLShowStomachContents")

  MCM.AddEmptyOption()
EndFunction

Function addMCMActorRecords(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = getTargetData(akTarget)
  EndIf
  String SKey = _getStrKey()

  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Digested Food", JMap.getFlt(aiTargetData, "SCLTotalDigestedFood")), "Records." + SKey + ".SCLTotalDigestedFood")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Times Vomited", JMap.getFlt(aiTargetData, "SCLTotalTimesVomited")), "Records." + SKey + ".SCLTotalTimesVomited")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Highest Stomach Fullness", JMap.getFlt(aiTargetData, "SCLHighestStomachFullness")), "Records." + SKey + ".SCLHighestStomachFullness")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Number of Digested Items", JMap.getFlt(aiTargetData, "SCLNumItemsDigested")), "Records." + SKey + ".SCLNumDigestedItems")

  ;MCM.AddEmptyOption()
EndFunction

Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SCLShowStomachStatus"
    MCM.ShowMessage(getStomachStatus(MCM.SelectedActor, MCM.SelectedData), False, "OK")
  ElseIf asValue == "SCLShowStomachFullness"
    MCM.ShowMessage("How full this actor's stomach is in units.", False, "OK")
  ElseIf asValue == "SCLShowStomachBase"
    MCM.ShowMessage("How much this actor is able to hold in their stomach, before adjustments, in units.", False, "OK")
  ElseIf asValue == "SCLShowStomachStretch"
    MCM.ShowMessage("How much this actor is able to stretch their stomach. Multiplies the adjusted base capacity to give the max capacity. The actor experiences discomfort beyond the adjusted base.", False, "OK")
  ElseIf asValue == "SCLShowStomachAdjBase"
    MCM.ShowMessage("How much this actor is able to hold in their stomach in units. Base capacity multiplied by the actor's size.", False, "OK")
  ElseIf asValue == "SCLShowStomachMaxBase"
    MCM.ShowMessage("How much this actor is able to hold in their stomach before vomiting.", False, "OK")
  ElseIf asValue == "SCLShowDigestRate"
    MCM.ShowMessage("How fast this actor can break down items (in units/hour).", False, "OK")
  ElseIf asValue == "SCLShowGluttony"
    MCM.ShowMessage("How much this actor likes to eat. Currently unused.", False, "OK")
  ElseIf asValue == "SCLShowStomachStorage"
    MCM.ShowMessage("How many items this actor can hold in their stomach without digesting them before they feel uncomfortable.", False, "OK")
  ElseIf asValue == "SCLShowNumItemsStored"
    MCM.ShowMessage("Current number of items being held without digesting in the actor's stomach.", False, "OK")
  ElseIf asValue == "SCLTotalDigestedFood"
    MCM.ShowMessage("Total amount of food digested by this actor in units.", False, "OK")
  ElseIf asValue == "SCLTotalTimesVomited"
    MCM.ShowMessage("Number of times this actor has vomited from overeating.", False, "OK")
  ElseIf asValue == "SCLHighestStomachFullness"
    MCM.ShowMessage("Largest amount of food held in this actor's stomach at once (in units).", False, "OK")
  ElseIf asValue == "SCLNumDigestedItems"
    MCM.ShowMessage("Total number of items digested in this actor's stomach.", False, "OK")
  EndIf
EndFunction

Float[] Function getSliderOptions(SCX_ModConfigMenu MCM, String asValue)
  Float[] SliderValues = New Float[5]
  Int ActorData = MCM.SelectedData
  If asValue == "SCLEditStomachBase"
    SliderValues[0] = JMap.getFlt(ActorData, "SCLStomachCapacity")
    SliderValues[1] = JMap.getFlt(ActorData, "SCLStomachCapacity")
    SliderValues[2] = 1
    SliderValues[3] = 1
    SliderValues[4] = 2000
  ElseIf asValue == "SCLEditStomachStretch"
    SliderValues[0] = JMap.getFlt(ActorData, "SCLStomachStretch")
    SliderValues[1] = JMap.getFlt(ActorData, "SCLStomachStretch")
    SliderValues[2] = 0.1
    SliderValues[3] = 1
    SliderValues[4] = 10
  ElseIf asValue == "SCLEditDigestRate"
    SliderValues[0] = JMap.getFlt(ActorData, "SCLDigestRate")
    SliderValues[1] = JMap.getFlt(ActorData, "SCLDigestRate")
    SliderValues[2] = 0.1
    SliderValues[3] = 0.1
    SliderValues[4] = 500
  ElseIf asValue == "SCLEditGluttony"
    SliderValues[0] = JMap.getFlt(ActorData, "SCLGluttony")
    SliderValues[1] = JMap.getFlt(ActorData, "SCLGluttony")
    SliderValues[2] = 1
    SliderValues[3] = 1
    SliderValues[4] = 100
  ElseIf asValue == "SCLEditStomachStorage"
    SliderValues[0] = JMap.getFlt(ActorData, "SCLStomachStorage")
    SliderValues[1] = JMap.getFlt(ActorData, "SCLStomachStorage")
    SliderValues[2] = 1
    SliderValues[3] = 0
    SliderValues[4] = 100
  EndIf
  Return SliderValues
EndFunction

Function setSliderOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Float afValue)
  Int ActorData = MCM.SelectedData
  If asValue == "SCLEditStomachBase"
    JMap.setFlt(ActorData, "SCLStomachCapacity", afValue)
    MCM.SetSliderOptionValue(aiOption, afValue, "{2}")
  ElseIf asValue == "SCLEditStomachStretch"
    JMap.setFlt(ActorData, "SCLStomachStretch", afValue)
    MCM.SetSliderOptionValue(aiOption, afValue, "x{2}")
  ElseIf asValue == "SCLEditDigestRate"
    JMap.setFlt(ActorData, "SCLDigestRate", afValue)
    MCM.SetSliderOptionValue(aiOption, afValue, "{2}")
  ElseIf asValue == "SCLEditGluttony"
    JMap.setInt(ActorData, "SCLGluttony", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  ElseIf asValue == "SCLEditStomachStorage"
    JMap.setInt(ActorData, "SCLStomachStorage", afValue as Int)
    MCM.SetSliderOptionValue(aiOption, afValue, "{0}")
  EndIf
EndFunction

Int[] Function getMCMMenuOptions01(SCX_ModConfigMenu MCM, String asValue)
  Int[] ReturnValues = New Int[2]
  If asValue == "SCLShowStomachContents"
    ReturnValues[0] = 0
    ReturnValues[1] = 0
  EndIf
  Return ReturnValues
EndFunction

Int JF_MCMMenuOptionsStomachContents
String[] Function getMCMMenuOptions02(SCX_ModConfigMenu MCM, String asValue)
  If asValue == "SCLShowStomachContents"
    Actor akTarget = MCM.SelectedActor
    Int TargetData = MCM.SelectedData
    JF_MCMMenuOptionsStomachContents = JValue.releaseAndRetain(JF_MCMMenuOptionsStomachContents, getAllStomachContents(akTarget, TargetData))
    Int NumEntries = JFormMap.count(JF_MCMMenuOptionsStomachContents)
    String[] FoodEntries = Utility.CreateStringArray(NumEntries, "")
    Int i = 0
    While i < NumEntries
      Form ItemKey = JFormMap.getNthKey(JF_MCMMenuOptionsStomachContents, i)
      Int JM_ItemEntry = JFormMap.getObj(JF_MCMMenuOptionsStomachContents, ItemKey)
      Int ItemType = JMap.getInt(JM_ItemEntry, "ItemType")
      String ItemEntry = Stomach.getItemListDesc(ItemKey, JM_ItemEntry)
      FoodEntries[i] = ItemEntry
      i += 1
    EndWhile
    Return FoodEntries
  EndIf
EndFunction

;/Function setMenuOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Int aiIndex)
EndFunction/;

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  If asValue == "SCLShowStomachStatus"
    MCM.SetInfoText("Display how this actor's stomach is feeling.")
  ElseIf asValue == "SCLShowStomachFullness"
    MCM.SetInfoText("How full this actor's stomach is in units.")
  ElseIf asValue == "SCLEditStomachBase"
    MCM.SetInfoText("Edit this actor's base capacity.")
  ElseIf asValue == "SCLEditStomachStretch"
    MCM.SetInfoText("Edit this actor's ability to stretch their stomach.")
  ElseIf asValue == "SCLShowStomachBase"
    MCM.SetInfoText("How much this actor is able to hold in their stomach, before adjustments, in units.")
  ElseIf asValue == "SCLShowStomachStretch"
    MCM.SetInfoText("How much this actor is able to stretch their stomach. Multiplies the adjusted base capacity to give the max capacity. The actor experiences discomfort beyond the adjusted base.")
  ElseIf asValue == "SCLShowStomachAdjBase"
    MCM.SetInfoText("How much this actor is able to hold in their stomach in units. Base capacity multiplied by the actor's size.")
  ElseIf asValue == "SCLShowStomachMaxBase"
    MCM.SetInfoText("How much this actor is able to hold in their stomach before vomiting.")
  ElseIf asValue == "SCLEditDigestRate"
    MCM.SetInfoText("Edit this actor's digestion rate.")
  ElseIf asValue == "SCLEditGluttony"
    MCM.SetInfoText("Edit this actor's gluttony value.")
  ElseIf asValue == "SCLEditStomachStorage"
    MCM.SetInfoText("Edit this actor's item storage capacity.")
  ElseIf asValue == "SCLShowDigestRate"
    MCM.SetInfoText("How fast this actor can break down items (in units/hour).")
  ElseIf asValue == "SCLShowGluttony"
    MCM.SetInfoText("How much this actor likes to eat. Currently unused.")
  ElseIf asValue == "SCLShowStomachStorage"
    MCM.SetInfoText("How many items this actor can hold in their stomach without digesting them before they feel uncomfortable.")
  ElseIf asValue == "SCLShowNumItemsStored"
    MCM.SetInfoText("Current number of items being held without digesting in the actor's stomach.")
  ElseIf asValue == "SCLShowStomachContents"
    MCM.SetInfoText("Display the current contents of this actor's stomach.")
  ElseIf asValue == "SCLTotalDigestedFood"
    MCM.SetInfoText("Total amount of food digested by this actor in units.")
  ElseIf asValue == "SCLTotalTimesVomited"
    MCM.SetInfoText("Number of times this actor has vomited from overeating.")
  ElseIf asValue == "SCLHighestStomachFullness"
    MCM.SetInfoText("Largest amount of food held in this actor's stomach at once (in units).")
  ElseIf asValue == "SCLNumDigestedItems"
    MCM.SetInfoText("Total number of items digested in this actor's stomach.")
  EndIf
EndFunction

;*******************************************************************************
;Monitor Functions
;*******************************************************************************
Spell Property SCL_MonitorSpell Auto
Function monitorSetup(SCX_Monitor akMonitor, Actor akTarget)
  If !akTarget.HasSpell(SCL_MonitorSpell)
    akTarget.AddSpell(SCL_MonitorSpell, False)
  EndIf
EndFunction

Function monitorCleanup(SCX_Monitor akMonitor, Actor akTarget)
  If akTarget.HasSpell(SCL_MonitorSpell)
    akTarget.Removespell(SCL_MonitorSpell)
  EndIf
EndFunction

Function sendProcessEvent(Actor akTarget, Float afTimePassed)
  Int ProcessEvent = ModEvent.Create("SCLProcessEvent")
  If ProcessEvent
    ModEvent.pushForm(ProcessEvent, akTarget)
    ModEvent.PushFloat(ProcessEvent, afTimePassed)
    ModEvent.send(ProcessEvent)
  EndIf
EndFunction

Function monitorUpdate(SCX_Monitor akMonitor, Actor akTarget, Int aiTargetData, Float afTimePassed, Float afCurrentUpdateTime, Bool abDailyUpdate)
  sendProcessEvent(akTarget, afTimePassed)
  Bool Digesting = JMap.getInt(aiTargetData, "SCLNowDigesting") as Bool
  Utility.Wait(0.1)
  If Digesting
    Int i
    While Digesting && i < 50
      Utility.Wait(0.1)
      Digesting = JMap.getInt(aiTargetData, "SCLNowDigesting") as Bool
      i += 1
    EndWhile
  EndIf

  updateDamage(akTarget, aiTargetData)
  Belly.updateBodyPart(akTarget)
  ;/If abDailyUpdate
    Notice("Performing daily update")
    ;performDailyUpdate(akTarget)
  EndIf/;
EndFunction

Function monitorDeath(SCX_Monitor akMonitor, Actor akTarget, Actor akKiller)
  If akTarget.HasSpell(SCL_MonitorSpell)
    akTarget.Removespell(SCL_MonitorSpell)
  EndIf
EndFunction

Function monitorReloadMaintenence(SCX_Monitor Mon, Actor akTarget)
  If akTarget.HasSpell(SCL_MonitorSpell)
    akTarget.RemoveSpell(SCL_MonitorSpell)
    Utility.Wait(0.2)
  EndIf
  If !akTarget.HasSpell(SCL_MonitorSpell)
    akTarget.AddSpell(SCL_MonitorSpell, False)
  EndIf
EndFunction

Function addUIEActorStats(Actor akTarget, UIListMenu UIList, Int JA_OptionList, Int aiMode = 0)
  Int TargetData = getTargetData(akTarget)
  String SKey = _getStrKey()
  Bool DEnable = SCXSet.DebugEnable
  UIList.AddEntryItem("Status: " + getStomachStatus(akTarget, TargetData))
  JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachStatus")

  UIList.AddEntryItem("Fullness: " + JMap.getFlt(TargetData, "SCLStomachFullness"))
  JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachFullness")

  If DEnable
    UIList.AddEntryItem("Edit Base Capacity: " + JMap.getFlt(TargetData, "SCLStomachCapacity"))
    JArray.addStr(JA_OptionList, SKey + ".SCLEditStomachBase")

    UIList.AddEntryItem("Edit Stretchiness: " + JMap.getFlt(TargetData, "SCLStomachStretch"))
    JArray.addStr(JA_OptionList, SKey + ".SCLEditStomachStretch")
  Else
    UIList.AddEntryItem("Base Capacity: " + JMap.getFlt(TargetData, "SCLStomachCapacity"))
    JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachBase")

    UIList.AddEntryItem("Stretchiness: " + JMap.getFlt(TargetData, "SCLStomachStretch"))
    JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachStretch")
  EndIf

  UIList.AddEntryItem("Adjusted Capacity: " + getAdjCap(akTarget, TargetData))
  JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachAdjBase")

  UIList.AddEntryItem("Max Capacity: " + getMaxCap(akTarget, TargetData))
  JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachMaxBase")

  If DEnable
    UIList.AddEntryItem("Edit Digestion Rate: " + JMap.getFlt(TargetData, "SCLDigestRate"))
    JArray.addStr(JA_OptionList, SKey + ".SCLEditDigestRate")

    UIList.AddEntryItem("Edit Gluttony: " + JMap.getFlt(TargetData, "SCLGluttony"))
    JArray.addStr(JA_OptionList, SKey + ".SCLEditGluttony")

    UIList.AddEntryItem("Edit Item Storage Capacity: " + JMap.getFlt(TargetData, "SCLStomachStorage"))
    JArray.addStr(JA_OptionList, SKey + ".SCLEditStomachStorage")
  Else
    UIList.AddEntryItem("Digestion Rate: " + JMap.getFlt(TargetData, "SCLDigestRate"))
    JArray.addStr(JA_OptionList, SKey + ".SCLShowDigestRate")

    UIList.AddEntryItem("Gluttony: " + JMap.getFlt(TargetData, "SCLGluttony"))
    JArray.addStr(JA_OptionList, SKey + ".SCLShowGluttony")

    UIList.AddEntryItem("Item Storage Capacity: " + JMap.getFlt(TargetData, "SCLStomachStorage"))
    JArray.addStr(JA_OptionList, SKey + ".SCLShowStomachStorage")
  EndIf

  UIList.AddEntryItem("Items Stored: " + SCXLib.countItemType(akTarget, 2, TargetData))
  JArray.addStr(JA_OptionList, SKey + ".SCLShowNumItemsStored")
EndFunction

Bool Function handleUIEStatFromList(Actor akTarget, String asValue)
  Int TargetData = getTargetData(akTarget)
  If asValue == "SCLShowStomachStatus"
    Debug.MessageBox(getStomachStatus(akTarget, TargetData))
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowStomachFullness"
    Debug.MessageBox("How full this actor's stomach is in units.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowStomachBase"
    Debug.MessageBox("How much this actor is able to hold in their stomach, before adjustments, in units.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowStomachStretch"
    Debug.MessageBox("How much this actor is able to stretch their stomach. Multiplies the adjusted base capacity to give the max capacity. The actor experiences discomfort beyond the adjusted base.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowStomachAdjBase"
    Debug.MessageBox("How much this actor is able to hold in their stomach in units. Base capacity multiplied by the actor's size.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowStomachMaxBase"
    Debug.MessageBox("How much this actor is able to hold in their stomach before vomiting.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowDigestRate"
    Debug.MessageBox("How fast this actor can break down items (in units/hour).")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowGluttony"
    Debug.MessageBox("How much this actor likes to eat. Currently unused.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLShowNumItemsStored"
    Debug.MessageBox("Current number of items being held without digesting in the actor's stomach.")
    Utility.Wait(0.1)
  ElseIf asValue == "SCLEditStomachBase"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new base capacity value here.")
    UIInput.OpenMenu()
    Float Result = UIInput.GetResultString() as Float
    If Result <= 0
      Result = 0.1
    EndIf
    JMap.setFlt(TargetData, "SCLStomachCapacity", Result)
    Return True
  ElseIf asValue == "SCLEditStomachStretch"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new stretch value here.")
    UIInput.OpenMenu()
    Float Result = UIInput.GetResultString() as Float
    If Result <= 0
      Result = 0.1
    EndIf
    JMap.setFlt(TargetData, "SCLStomachStretch", Result)
    Return True
  ElseIf asValue == "SCLEditDigestRate"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new digestion rate value here.")
    UIInput.OpenMenu()
    Float Result = UIInput.GetResultString() as Float
    If Result < 0
      Result = 0
    EndIf
    JMap.setFlt(TargetData, "SCLDigestRate", Result)
    Return True
  ElseIf asValue == "SCLEditGluttony"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new gluttony value here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    JMap.setInt(TargetData, "SCLGluttony", Result)
    Return True
  ElseIf asValue == "SCLEditStomachStorage"
    UITextEntryMenu UIInput = UIExtensions.GetMenu("UITextEntryMenu", True) as UITextEntryMenu
    UIInput.SetPropertyString("text", "Enter new stomach storage limit value here.")
    UIInput.OpenMenu()
    Int Result = UIInput.GetResultString() as Int
    If Result < 0
      Result = 0
    EndIf
    JMap.setInt(TargetData, "SCLStomachStorage", Result)
    Return True
  EndIf
  Return False
EndFunction
;*******************************************************************************

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

Float Function getExpandTimer(Actor akTarget, Int aiTargetData = 0)
  {Returns length of time (in-game hours) until next expand event happens}
  Int TargetData = getData(akTarget, aiTargetData)
  Return SCLSet.DefaultExpandTimer * JMap.getFlt(TargetData, "SCLExpandTimerBonus", 1)
EndFunction

Float Function giveExpandBonus(Actor akTarget, Int aiMultiply = 1, Int aiTargetData = 0)
  {Gives the actor additional base capacity, augmented by buffs}
  Int TargetData = getData(akTarget, aiTargetData)
  Int OverfullTier = getCurrentOverfull(akTarget, TargetData)
  Float Bonus = SCLSet.DefaultExpandBonus * JMap.getFlt(TargetData, "SCLExpandBonusMulti", 1)
  If OverfullTier > 1
    Bonus *= ((OverfullTier - 1) * 0.1) + 1
  EndIf
  Bonus *= aiMultiply
  Notice("Adding expand bonus of " + Bonus + " to " + nameGet(akTarget))
  JMap.setFlt(TargetData, "SCLStomachCapacity", JMap.getFlt(TargetData, "SCLStomachCapacity") + Bonus)
  JMap.setFlt(TargetData, "SCLExpandNum", JMap.getFlt(TargetData, "SCLExpandNum") + 1)

  Return Bonus
EndFunction

Float Function getMaxCap(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return getAdjCap(akTarget, TargetData) * JMap.getFlt(TargetData, "SCLStomachStretch")
EndFunction

Float Function getAdjCap(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getFlt(TargetData, "SCLStomachCapacity") * akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False) * SCLSet.AdjBaseMulti
EndFunction

Float Function getOverfullPercent(Actor akTarget, Int aiTargetData = 0)
  Int TargetData
  If aiTargetData
    TargetData = aiTargetData
  Else
    TargetData = getTargetData(akTarget)
  EndIf
  Float Fullness = JMap.getFlt(TargetData, "STFullness")
  Float Base = getAdjCap(akTarget, TargetData)
  If Fullness > Base
    Float Percent = Fullness - Base / (Base * 1.5) - Base
    Return Percent
  Else
    Return 0
  EndIf
EndFunction

Int Function getOverfullTier(Float afValue, Float afFullness)
  Int Tier
  If afValue > 2
    Tier = 12
  ElseIf afValue > 1.8
    Tier = 11
  ElseIf afValue > 1.6
    Tier = 10
  ElseIf afValue > 1.4
    Tier = 8
  ElseIf afValue > 1.2
    Tier = 7
  ElseIf afValue > 1
    Tier = 6
  ElseIf afValue > 0.8
    Tier = 5
  ElseIf afValue > 0.6
    Tier = 4
  ElseIf afValue > 0.4
    Tier = 3
  ElseIf afValue > 0.2
    Tier = 2
  ElseIf afValue
    Tier = 1
  Else
    Tier = 0
  EndIf
  If afValue
    Int AddAmount = Math.Floor(afFullness / 100) ;Right now, it every 100 units per tier, maybe adjust this to be more extreme
    Tier += AddAmount
  EndIf
  Return Tier
EndFunction

Int Function getAllStomachContents(Actor akTarget, Int aiTargetData = 0)
   If !JValue.isMap(aiTargetData)
     aiTargetData = getTargetData(akTarget)
   EndIf
   If !Stomach
     Stomach = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, "Stomach") as SCX_BaseItemArchetypes
   EndIf
   Return Stomach.getAllContents(akTarget, aiTargetData)
 EndFunction

Bool Function isInContainer(Form akItem)
  Int JM_DataEntry = getItemDatabaseEntry(akItem)
  Return JMap.getInt(JM_DataEntry, "IsInContainer") as Bool
EndFunction

Bool Function isNotFood(Form akItem)
  Int JM_DataEntry = getItemDatabaseEntry(akItem)
  Return JMap.getInt(JM_DataEntry, "IsNotFood") as Bool
EndFunction

Bool Function isDigestible(Form akItem)
  {Basically a convenience function to test both the above}
  Int JM_DataEntry = getItemDatabaseEntry(akItem)
  If JMap.getInt(JM_DataEntry, "IsInContainer") == 0 && JMap.getInt(JM_DataEntry, "IsNotFood") == 0
    Return True
  Else
    Return False
  EndIf
EndFunction

Float Function getLiquidRatio(Form akItem)
  Int JM_DataEntry = getItemDatabaseEntry(akItem)
  Float Ratio = JMap.getFlt(JM_DataEntry, "LiquidRatio")
  Ratio = PapyrusUtil.ClampFloat(Ratio, 0, 1)
  Return Ratio
EndFunction

Bool Function isSKSEPluginInstalled(String Plugin) Global
  If SKSE.GetPluginVersion(Plugin) == -1
    Return False
  Else
    Return True
  EndIf
EndFunction


Int ScriptDataVersion = 1
Function genActorProfile(Actor akTarget, Bool abBasic, Int aiTargetData)
  If !abBasic
    Int StomachChance = Utility.RandomInt()
    If StomachChance > 90
      Int RandomBase = Utility.RandomInt(25, 50)
      JMap.setFlt(aiTargetData, "SCLStomachCapacity", RandomBase)
      JMap.setFlt(aiTargetData, "SCLStomachStretch", 1.75)
      ;JMap.setInt(TargetData, "SCLStoredLimitUp", 2)
      JMap.setFlt(aiTargetData, "SCLDigestRate", 3)
    ElseIf StomachChance > 50
      Int RandomBase = Utility.RandomInt(10, 15)
      JMap.setFlt(aiTargetData, "SCLStomachCapacity", RandomBase)
      ;JMap.setInt(TargetData, "SCLStoredLimitUp", 1)
      JMap.setFlt(aiTargetData, "SCLStomachStretch", 1.6)
      JMap.setFlt(aiTargetData, "SCLDigestRate", 1)
    Else
      Int RandomBase = Utility.RandomInt(2, 5)
      JMap.setFlt(aiTargetData, "SCLStomachCapacity", RandomBase)
      JMap.setFlt(aiTargetData, "SCLStomachStretch", 1.5)
      JMap.setFlt(aiTargetData, "SCLDigestRate", 0.5)
    EndIf
  Else
    JMap.setFlt(aiTargetData, "SCLStomachCapacity", 3)
    JMap.setFlt(aiTargetData, "SCLStomachStretch", 1.5)
    JMap.setFlt(aiTargetData, "SCLDigestRate", 0.5)
  EndIf
  ;JMap.setFlt(TargetData, "LastUpdateTime", Utility.GetCurrentGameTime())
  ;JMap.setFlt(TargetData, "STLastFullness", 0)
  ;JMap.setObj(TargetData, "SCLTrackingData", JMap.object())
  ;JMap.setInt(TargetData, "SCX_ActorDataVersion", ScriptDataVersion)
EndFunction

;Item Functions ****************************************************************
Int Function addItem(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, String asType, String asStoredArchPlusType = "", Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
  Return Stomach.addToContents(akTarget, akReference, akBaseObject, asType, asStoredArchPlusType, afWeightValueOverride, aiItemCount, abMoveNow)
EndFunction

ObjectReference Function findRefFromBase(Int JF_Contents, Form akBaseObject)
  ObjectReference i = JFormMap.nextKey(JF_Contents) as ObjectReference
  While i
    If i.GetBaseObject() == akBaseObject
      Return i
    EndIf
    i = JFormMap.nextKey(JF_Contents, i) as ObjectReference
  EndWhile
  Return None
EndFunction

Function moveToHoldingCell(ObjectReference akRef)
  ;akRef.DisableNoWait()
  akRef.MoveTo(SCLSet.SCL_HoldingCell)
  ;akRef.EnableNoWait()
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

Int Function findObjBundle(Int JF_ContentsMap, Form akBaseObject)
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

Function updateDamage(Actor akTarget, Int aiTargetData = 0)
  ;Need to rethink how this is applied. Make sure that if the calculated tier is greater that max num of spells,
  ;it picks the highest one
  ;Also remember to add modifier based on current fullness (if > 100, add 1 tier)
  Int TargetData
  If aiTargetData
    TargetData = aiTargetData
  Else
    TargetData = getTargetData(akTarget)
  EndIf
  Float Fullness = JMap.getFlt(TargetData, "SCLStomachFullness")
  Float MaxCap = getMaxCap(akTarget, TargetData)

  If Fullness > JMap.getFlt(aiTargetData, "SCLHighestStomachFullness")
    JMap.setFlt(aiTargetData, "SCLHighestStomachFullness", Fullness)
  EndIf

  If Fullness > MaxCap && canVomit(akTarget)
    Stomach.removeAmountActorItems(akTarget,Fullness * 0.3, 0.2, 0.2)
    addVomitDamage(akTarget)
    Stomach.updateArchetype(akTarget)
    JMap.setInt(TargetData, "SCLTotalTimesVomited", JMap.getInt(TargetData, "SCLTotalTimesVomited") + 1)
  EndIf

  Float Overfull = getOverfullPercent(akTarget, TargetData)
  Int OverfullTier = getOverfullTier(Overfull, Fullness)

  If OverfullTier > SCLSet.SCL_OverfullSpellArray.length - 1  ;Just using this as a test marker, all spell arrays should be filled the same
    OverfullTier = SCLSet.SCL_OverfullSpellArray.length - 1 ;Ensures that the overfull tier does not go above spells set
  EndIf

  Int CurrentOverfull = getCurrentOverfull(akTarget, TargetData)
  If OverfullTier != CurrentOverfull
    SCLSet.SCL_OverfullSpellArray[0].cast(akTarget) ;If it's tier 0, it casts the dispel effect and nothing else
    Utility.Wait(0.2)
    SCLSet.SCL_OverfullSpellArray[OverfullTier].cast(akTarget)
    JMap.setInt(TargetData, "SCLAppliedOverfullTier", OverfullTier)
  EndIf

  Int Storage = SCXLib.countItemType(akTarget, 2, True)
  Int StorageMax = JMap.getInt(TargetData, "SCLStomachStorage")
  If Storage > StorageMax

    Int Level = ((Storage - StorageMax) / 2) + (StorageMax - 1)
    If Level > SCLSet.SCL_StoredDamageArray.length - 1
      Level = SCLSet.SCL_StoredDamageArray.length - 1
    EndIf

    Int CurrentStorageDamage = getCurrentStorageDamage(akTarget, TargetData)
    If Level != CurrentStorageDamage
      SCLSet.SCL_StoredDamageArray[Level].cast(akTarget)
      JMap.setInt(TargetData, "SCLAppliedStorageTier", Level)
    EndIf
  ElseIf getCurrentStorageDamage(akTarget, TargetData) != 0
    SCLSet.SCL_StoredDamageArray[0].cast(akTarget)
    JMap.setInt(TargetData, "SCLAppliedStorageTier", 0)
  EndIf
EndFunction

Int Function getCurrentOverfull(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCLAppliedOverfullTier")
EndFunction

Int Function getCurrentStorageDamage(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCLAppliedStorageTier")
EndFunction

Bool Function canVomit(Actor akTarget)
  Return !akTarget.HasMagicEffect(SCLSet.SCL_VomitDamageEffect)
  ;Return !akTarget.HasSpell(SCL_VomitDamageSpell)
EndFunction

Function addVomitDamage(Actor akTarget)
  SCLSet.SCL_VomitDamageSpell.cast(akTarget)
EndFunction

;Vomit Functions ***************************************************************
Function vomitAll(Actor akTarget, Bool ReturnFood = False)
  Stomach.removeAllActorItems(akTarget, ReturnFood)
EndFunction

Function vomitAmount(Actor akTarget, Float afRemoveAmount, Float afStoredRemoveChance = 0.0, Float afOtherRemoveChance = 0.0)
  Stomach.removeAmountActorItems(akTarget, afRemoveAmount, afStoredRemoveChance, afOtherRemoveChance)
EndFunction

Function vomitSpecificItem(Actor akTarget, String asType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyBreakdownItems = True)
  Stomach.removeSpecificActorItems(akTarget, "Stomach", asType, akReference, akBaseObject, aiItemCount, abDestroyBreakdownItems)
EndFunction
