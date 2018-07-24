ScriptName SCLibrary Extends SCX_BaseLibrary
;*******************************************************************************
;Variables and Properties
;*******************************************************************************
SCLSettings Property SCLSet Auto
Int Property JCReqAPI = 3 Auto
Int Property JCReqFV = 3 Auto

SCX_BaseItemType Property ItemType01 Auto
SCX_BaseItemType Property ItemType02 Auto
SCX_BaseItemArchetypes Property Stomach Auto
SCX_BaseBodyEdit Property Belly Auto

;Others ************************************************************************

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
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Status", getStomachStatus(akTarget, aiTargetData)), "Stats.SCLibrary.SCLShowStomachStatus")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Fullness", JMap.getFlt(aiTargetData, "SCLStomachFullness")), "Stats.SCLibrary.SCLShowStomachFullness")
  If DEnable
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Base Capacity", JMap.getFlt(aiTargetData, "SCLStomachCapacity"), "{2}"), "Stats.SCLibrary.SCLEditStomachBase")
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Stretchiness", JMap.getFlt(aiTargetData, "SCLStomachStretch", 1), "x{2}"), "Stats.SCLibrary.SCLEditStomachStretch")
  Else
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Base Capacity", JMap.getFlt(aiTargetData, "SCLStomachCapacity")), "Stats.SCLibrary.SCLShowStomachBase")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Stretchiness", JMap.getFlt(aiTargetData, "SCLStomachStretch")), "Stats.SCLibrary.SCLShowStomachStretch")
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Adjusted Capacity", getAdjCap(akTarget, aiTargetData)), "Stats.SCLibrary.SCLShowStomachAdjBase")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Max Capacity", getMaxCap(akTarget, aiTargetData)), "Stats.SCLibrary.SCLShowStomachMaxBase")

  If DEnable
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Digestion Rate", JMap.getFlt(aiTargetData, "SCLDigestRate")), "Stats.SCLibrary.SCLEditDigestRate")
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Gluttony", JMap.getInt(aiTargetData, "SCLGluttony")), "Stats.SCLibrary.SCLEditGluttony")
    JIntMap.setStr(JI_Options, MCM.AddSliderOption("Edit Item Storage Capacity", JMap.getInt(aiTargetData, "SCLStomachStorage")), "Stats.SCLibrary.SCLEditStomachStorage")
  Else
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Digestion Rate", JMap.getFlt(aiTargetData, "SCLDigestRate")), "Stats.SCLibrary.SCLShowDigestRate")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Gluttony", JMap.getInt(aiTargetData, "SCLGluttony")), "Stats.SCLibrary.SCLShowGluttony")
    JIntMap.setStr(JI_Options, MCM.AddTextOption("Item Storage Capacity", JMap.getInt(aiTargetData, "SCLStomachStorage")), "Stats.SCLibrary.SCLShowStomachStorage")
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Items Stored", SCXLib.countItemType(akTarget, 2, aiTargetData)), "Stats.SCLibrary.SCLShowNumItemsStored")
  JIntMap.setStr(JI_Options, MCM.AddMenuOption("Show Stomach Contents", ""), "Stats.SCLibrary.SCLShowStomachContents")

  MCM.AddEmptyOption()
EndFunction

Function addMCMActorRecords(SCX_ModConfigMenu MCM, Int JI_Options, Actor akTarget, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = getTargetData(akTarget)
  EndIf
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Total Digested Food", JMap.getFlt(aiTargetData, "SCLTotalDigestedFood")), "Records.SCLibrary.SCLTotalDigestedFood")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Number Times Vomited", JMap.getFlt(aiTargetData, "SCLTotalTimesVomited")), "Records.SCLibrary.SCLTotalTimesVomited")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Highest Stomach Fullness", JMap.getFlt(aiTargetData, "SCLHighestStomachFullness")), "Records.SCLibrary.SCLHighestStomachFullness")
  JIntMap.setStr(JI_Options, MCM.AddTextOption("Number of Digested Items", JMap.getFlt(aiTargetData, "SCLNumItemsDigested")), "Records.SCLibrary.SCLNumDigestedItems")

  MCM.AddEmptyOption()
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
    SliderValues[0] = JMap.getFlt(ActorData, "SCLStomachBase")
    SliderValues[1] = JMap.getFlt(ActorData, "SCLStomachBase")
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
    JMap.setFlt(ActorData, "SCLStomachBase", afValue)
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
      String ItemEntry
      If ItemType == 1
        ItemEntry = ItemType01.getItemListDesc(ItemKey, JM_ItemEntry)
      ElseIf ItemType == 2
        ItemEntry == ItemType02.getItemListDesc(ItemKey, JM_ItemEntry)
      Else
        SCX_BaseItemType ItemBase = getSCX_BaseAlias(SCXSet.JI_BaseItemTypes, aiBaseID = ItemType) as SCX_BaseItemType
        If ItemBase
          ItemEntry = ItemBase.getItemListDesc(ItemKey, JM_ItemEntry)
        EndIf
      EndIf
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
  Note("Running setup. Checking for spell. Spell = " + SCL_MonitorSpell as Bool)
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
  If Digesting
    Int i
    While Digesting && i < 50
      Utility.Wait(0.1)
      Digesting = JMap.getInt(aiTargetData, "SCLNowDigesting") as Bool
      i += 1
    EndWhile
  EndIf

  Float Fullness = Stomach.updateArchetype(akTarget, aiTargetData)
  ;Note("Fullness after update = " + Fullness)
  Float Max = getMaxCap(akTarget)

  If Fullness < 0
    Issue("updateFullness return a total of less than 0. Setting to 0")
    Fullness = 0
  EndIf

  ;JMap.setFlt(aiTargetData, "STFullness", Fullness)
  If Fullness > JMap.getFlt(aiTargetData, "SCLHighestStomachFullness")
    JMap.setFlt(aiTargetData, "SCLHighestStomachFullness", Fullness)
  EndIf

  Float Base = getAdjCap(akTarget, aiTargetData)

  If Fullness > Base
    Float Overfull = (Fullness - Base) / (Max - Base)

    Int OverfullTier
    If Overfull > 1
      OverfullTier = 6
    ElseIf Overfull > 0.8
      OverfullTier = 5
    ElseIf Overfull > 0.6
      OverfullTier = 4
    ElseIf Overfull > 0.4
      OverfullTier = 3
    ElseIf Overfull > 0.2
      OverfullTier = 2
    ElseIf Overfull
      OverfullTier = 1
    Else
      OverfullTier = 0
    EndIf

    If Overfull
      OverfullTier += Math.Floor(Fullness / 100) ;Right now, it every 100 units per tier, maybe adjust this to be more extreme
    EndIf

    If OverfullTier > SCLSet.SCL_OverfullSpellArray.length - 1  ;Just using this as a test marker, all spell arrays should be filled the same
      OverfullTier = SCLSet.SCL_OverfullSpellArray.length - 1 ;Ensures that the overfull tier does not go above spells set
    EndIf

    Int CurrentOverfull = JMap.getInt(aiTargetData, "SCLAppliedOverfullTier")
    If OverfullTier != CurrentOverfull
      SCLSet.SCL_OverfullSpellArray[0].cast(akTarget)
      Utility.Wait(0.2)
      SCLSet.SCL_OverfullSpellArray[OverfullTier].cast(akTarget) ;If it's tier 0, it casts the dispel effect and nothing else

      JMap.setInt(aiTargetData, "SCLAppliedOverfullTier", OverfullTier)
    EndIf
  ElseIf JMap.getInt(aiTargetData, "SCLAppliedOverfullTier")  != 0
    SCLSet.SCL_OverfullSpellArray[0].cast(akTarget) ;If it's tier 0, it casts the dispel effect and nothing else
    JMap.setInt(aiTargetData, "SCLAppliedOverfullTier", 0)
  EndIf

  ;Question: should this be here? Or should we move it to SCX or SCN?
  ;/Int HeavyPerk = JMap.getInt(aiTargetData, "SCLHeavyBurden")
  Int BaseWeight = 100 * (HeavyPerk + 1)
  If Fullness > BaseWeight
    Int MaxWeight = 150 * (HeavyPerk + 1)
    Float HeavyPercent = (Fullness - BaseWeight) / (MaxWeight - BaseWeight)
    Int HeavyTier
    If HeavyPercent > 1
      HeavyTier = 6
    ElseIf HeavyPercent > 0.8
      HeavyTier = 5
    ElseIf HeavyPercent > 0.6
      HeavyTier = 4
    ElseIf HeavyPercent > 0.4
      HeavyTier = 3
    ElseIf HeavyPercent > 0.2
      HeavyTier = 2
    ElseIf HeavyPercent
      HeavyTier = 1
    Else
      HeavyTier = 0
    EndIf
    If HeavyTier > SCLSet.SCL_HeavySpeedArray.length - 1
      HeavyTier = SCLSet.SCL_HeavySpeedArray.length - 1
    EndIf
    If HeavyTier >= 6
      JMap.setInt(aiTargetData, "SCL_HeavyBurdenTracker", 1)
    EndIf

    Int CurrentHeavy = JMap.getInt(aiTargetData, "SCLAppliedHeavyTier")
    If HeavyTier != CurrentHeavy
      SCLSet.SCL_HeavySpeedArray[HeavyTier].cast(akTarget)
      ;Add more spell arrays here.

      JMap.setInt(aiTargetData, "SCLAppliedHeavyTier", HeavyTier)
    EndIf
  ElseIf JMap.getInt(aiTargetData, "SCLAppliedHeavyTier") != 0
    SCLSet.SCL_HeavySpeedArray[0].cast(akTarget)
    JMap.setInt(aiTargetData, "SCLAppliedHeavyTier", 0)
  EndIf/;

  Int Storage = countItemType(akTarget, 2, True, aiTargetData)
  Int StorageMax = JMap.getInt(aiTargetData, "SCLStomachStorage")
  If Storage > StorageMax
    Int StorageTier = ((Storage - StorageMax) / 2) + (StorageMax - 1)
    If StorageTier > SCLSet.SCL_StoredDamageArray.length - 1
      StorageTier = SCLSet.SCL_StoredDamageArray.length - 1
    ElseIf StorageTier < 0
      StorageTier = 0
    EndIf
    Int CurrentStorageDamage = JMap.getInt(aiTargetData, "SCLAppliedStorageTier")
    If StorageTier != CurrentStorageDamage

      SCLSet.SCL_StoredDamageArray[StorageTier].cast(akTarget)
      JMap.setInt(aiTargetData, "SCLAppliedStorageTier", StorageTier)
    EndIf
  ElseIf JMap.getInt(aiTargetData, "SCLAppliedStorageTier") != 0
    SCLSet.SCL_StoredDamageArray[0].cast(akTarget)
    JMap.setInt(aiTargetData, "SCLAppliedStorageTier", 0)
  EndIf

  Belly.updateBodyPart(akTarget)
  If abDailyUpdate
    Notice("Performing daily update")
    ;performDailyUpdate(akTarget)
  Endif

  ;Notice("Finished updating " + akTarget.GetLeveledActorBase().GetName())
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
  JMap.setFlt(TargetData, "SCLStomachBase", JMap.getFlt(TargetData, "SCLStomachBase") + Bonus)
  JMap.setFlt(TargetData, "SCLExpandNum", JMap.getFlt(TargetData, "SCLExpandNum") + 1)

  Return Bonus
EndFunction

Float Function getMaxCap(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return getAdjCap(akTarget, TargetData) * JMap.getFlt(TargetData, "STStretch")
EndFunction

Float Function getAdjCap(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getFlt(TargetData, "SCLStomachBase") * akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False) * SCLSet.AdjBaseMulti
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

Int Function getCurrentOverfull(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCLAppliedOverfullTier")
EndFunction

Float Function getHeavyPercent(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float HeavyPercent
  Float Fullness = SCXLib.getActorTotalWeightContained(akTarget, TargetData) ;JMap.getFlt(TargetData, "STFullness")  ;Replace this with total?
  Int PerkLevel = JMap.getInt(TargetData, "SCLHeavyBurden")
  Int MaxWeight = 150 * (PerkLevel + 1)
  Int BaseWeight = 100 * (PerkLevel + 1)
  If Fullness > BaseWeight
    HeavyPercent = (Fullness - BaseWeight) / (MaxWeight - BaseWeight)
  Else
    HeavyPercent = 0
  EndIf
  Return HeavyPercent
EndFunction

Int Function getHeavyTier(Float afValue)
  If afValue > 1
    Return 6
  ElseIf afValue > 0.8
    Return 5
  ElseIf afValue > 0.6
    Return 4
  ElseIf afValue > 0.4
    Return 3
  ElseIf afValue > 0.2
    Return 2
  ElseIf afValue
    Return 1
  Else
    Return 0
  EndIf
EndFunction

Int Function getCurrentHeavy(Actor akTarget, Int aiTargetData = 0)
  Int TargetData
  If aiTargetData
    TargetData = aiTargetData
  Else
    TargetData = getTargetData(akTarget)
  EndIf
  Return JMap.getInt(TargetData, "SCLAppliedHeavyTier")
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

;/Bool Function canStoreItem(Actor akTarget, Form akItem, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  If countItemTypes(akTarget, 2) < getTotalPerkLevel(akTarget, "SCLStoredLimitUp", TargetData)  ;Perks will increase this through OnEffectStart/OnEffectFinish chains (maybe)
    Float WeightValue = genWeightValue(akItem)
    If JMap.getFlt(TargetData, "STFullness") + WeightValue < getMax(akTarget, TargetData) || SCLSet.GodMode1
      Return True
    EndIf
  EndIf
  Return False
EndFunction/;

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
  ;JMap.setInt(TargetData, "SCLActorDataVersion", ScriptDataVersion)
EndFunction

;Item Functions ****************************************************************
Int Function addItem(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemType, Int aiStoredItemType = 0, Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
  Note("addItem run on SCLibrary.")
  Return Stomach.addToContents(akTarget, akReference, akBaseObject, aiItemType, aiStoredItemType, afWeightValueOverride, aiItemCount, abMoveNow)
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
  Float Fullness = JMap.getFlt(TargetData, "STFullness")

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

  ;/Float Heavy = getHeavyPercent(akTarget, TargetData)
  Int HeavyTier = getHeavyTier(Heavy)
  If HeavyTier > SCLSet.SCL_HeavySpeedArray.length - 1
    HeavyTier = SCLSet.SCL_HeavySpeedArray.length - 1
  EndIf
  Int CurrentHeavy = getCurrentHeavy(akTarget, TargetData)
  If HeavyTier != CurrentHeavy
    SCLSet.SCL_HeavySpeedArray[HeavyTier].cast(akTarget)
    ;Add more spell arrays here.

    JMap.setInt(TargetData, "SCLAppliedHeavyTier", HeavyTier)
  EndIf
  If HeavyTier >= 6
    JMap.setInt(TargetData, "SCLHeavyBurdenTracker", 1)
  EndIf/;

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

Function addSolidRemoveDamage(Actor akTarget)
EndFunction



;Vomit Functions ***************************************************************
Function vomitAll(Actor akTarget, Bool ReturnFood = False)
  Stomach.removeAllActorItems(akTarget, ReturnFood)
EndFunction

Function vomitAmount(Actor akTarget, Float afRemoveAmount, Float afStoredRemoveChance = 0.0, Float afOtherRemoveChance = 0.0)
  Stomach.removeAmountActorItems(akTarget, afRemoveAmount, afStoredRemoveChance, afOtherRemoveChance)
EndFunction

Function vomitSpecificItem(Actor akTarget, Int aiItemType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyBreakdownItems = True)
  Stomach.removeSpecificActorItems(akTarget, aiItemType, akReference, akBaseObject, aiItemCount, abDestroyBreakdownItems)
EndFunction
