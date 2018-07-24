ScriptName SCX_MonitorManager Extends SCX_BaseQuest

GlobalVariable Property SCX_SET_UpdateRate Auto ;Default 10
Float Property UpdateRate
  Float Function Get()
    Return SCX_SET_UpdateRate.GetValue()
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_UpdateDelay Auto ;Default 0.5
Float Property UpdateDelay
  Float Function Get()
    Return SCX_SET_UpdateDelay.GetValue()
  EndFunction
EndProperty

Function resetData()
EndFunction

String DebugName = "[SCX_MonitorManager] "
Int DMID = 4
Float LastDailyUpdate
Bool QueueDailyUpdate

Int Function GetStage()
  RegisterForModEvent("SCX_Reset", "OnSCXReset")
  RegisterForSingleUpdate(UpdateRate)
  Return Parent.GetStage()
EndFunction

;/Event OnSleepStop(bool abInterrupted)
  QueueDailyUpdate = True
  OnUpdate()
EndEvent/;

Event OnMenuOpen(String menuName)
  UnregisterForUpdate()
EndEvent

Event OnMenuClose(string menuName)
  ;If menuName = "Sleep/Wait Menu"
    ;Note("Sleep Detected. Updating actors.")
    QueueDailyUpdate = True
    RegisterForSingleUpdate(0.1)
    ;OnUpdate()
  ;EndIf
EndEvent

Bool SCXResetted = False
Event OnSCXReset()
  SCXResetted = True
EndEvent

Bool Function Start()
  Bool bReturn = Parent.Start()
  Utility.Wait(3)
  Notice("Starting up monitor manager")
  ;RegisterForSleep()
  RegisterForMenu("Sleep/Wait Menu")
  RegisterForModEvent("SCLReset", "OnSCLReset")
  RegisterForSingleUpdate(UpdateRate)
  (GetNthAlias(0) as SCX_Monitor).Setup()
  Return bReturn
EndFunction

Function Stop()
  UnregisterForUpdate()
  Parent.Stop()
EndFunction

;/Event OnInit()
  If !SCLibrary.getSCLModConfig().MCMInitialized
    Return
  EndIf
  Notice("Starting up monitor manager")
  RegisterForSleep()
  RegisterForModEvent("SCLReset", "OnSCLReset")
  RegisterForSingleUpdate(SCLib.UpdateRate)
  SCLibrary.addToReloadList(Self)
EndEvent/;

Int _JA_UpdatePrioityList
Bool _BuildingUpdateList
Int Property JA_MonitorUpdatePrioityList
  Int Function Get()
    If _BuildingUpdateList
      While _BuildingUpdateList
        Utility.Wait(0.1)
      EndWhile
    EndIf
    If !JValue.isExists(_JA_UpdatePrioityList) ;Need to generate list
      _BuildingUpdateList = True
      Debug.Notification("Building monitor update priority list...")
      _JA_UpdatePrioityList = JValue.retain(JArray.object())
      Int JI_PriorityList = JValue.retain(JIntMap.object())
      Int JM_MainLibList = SCXSet.JM_BaseLibraryList
      String LibraryName = JMap.nextKey(JM_MainLibList)
      While LibraryName
        SCX_BaseLibrary Lib = JMap.getForm(JM_MainLibList, LibraryName) as SCX_BaseLibrary
        If Lib
          Int Priority = Lib.monitorUpdatePriority
          If Priority != 0
            Int JM_PriorityList = JIntMap.getObj(JI_PriorityList, Priority)
            If !JM_PriorityList
              JM_PriorityList = JMap.object()
              JIntMap.setObj(JI_PriorityList, Priority, JM_PriorityList)
            EndIf
            JMap.setForm(JM_PriorityList, LibraryName, Lib)
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
            JArray.addForm(_JA_UpdatePrioityList, Lib)
          EndIf
          LibKey = JMap.nextKey(JM_PriorityList, LibKey)
        EndWhile
        i = JIntMap.nextKey(JI_PriorityList, i)
      EndWhile
      JI_PriorityList = JValue.release(JI_PriorityList)
      _BuildingUpdateList = False
    EndIf
    Return _JA_UpdatePrioityList
  EndFunction
EndProperty

Event OnUpdate()
  Note("Updating monitors.")
  Float CurrentUpdateTime = Utility.GetCurrentGameTime()
  ;Notice("Updating actor list")
  Bool DailyUpdate = False
  If QueueDailyUpdate || CurrentUpdateTime - LastDailyUpdate > 1
    QueueDailyUpdate = False
    DailyUpdate = True
  EndIf

  Int i = 0
  Int NumAlias = GetNumAliases()
  ;Notice("NumAliases = " + NumAlias)
  ;Note("NumAliases = " + NumAlias)

  While i < NumAlias
    ReferenceAlias TrackingAlias = GetNthAlias(i) as ReferenceAlias
    ;Note("Looking at Alias " + TrackingAlias.GetName() + ", ID " + TrackingAlias.GetID())
    Actor akTarget = TrackingAlias.GetActorReference()
    If akTarget
      Int TargetData = getTargetData(akTarget)
      Float TimePassed = ((CurrentUpdateTime - (JMap.getFlt(TargetData, "LastUpdateTime")))*24) ;In hours
      If TargetData
        If JMap.getInt(TargetData, "SCLEnableUpdates")
          Notice("Beginning full updates for " + nameGet(akTarget))
          Int handle = ModEvent.Create("SCX_MonitorUpdate")
          ModEvent.PushForm(handle, akTarget)
          ModEvent.PushFloat(handle, TimePassed)
          ModEvent.pushFloat(handle, CurrentUpdateTime)
          ModEvent.PushBool(handle, DailyUpdate)
          ModEvent.Send(handle)
          ;(TrackingAlias as SCLMonitor).fullActorUpdate(TimePassed, DailyUpdate)
        Else
          Notice("Actor has declined to be updated")
        EndIf
        ;Notice("No target or invalid TargetData")
      EndIf
      JMap.setFlt(TargetData, "LastUpdateTime", CurrentUpdateTime)
      Utility.Wait(UpdateDelay)
    EndIf
    i += 1
  EndWhile
  LastDailyUpdate = CurrentUpdateTime
  RegisterForSingleUpdate(UpdateRate)
EndEvent

;Commenting all of these out until we finalize how this works. Until then, work on the SCLib versions
;/Int Function getTargetData(Actor akTarget)
{Consider: Generate an actor profile if findEntry returns 0}
Int Data = JFormDB.findEntry("SCLActorData", akTarget)
Return Data
EndFunction/;

;/Float Function getTotalBelly(Int aiTargetData)
  Int i = JArray.count(SCLib.JA_BellyValuesList)
  Float TotalWeight
  While i
    i -= 1
    TotalWeight += JMap.getFlt(aiTargetData, JArray.getStr(SCLib.JA_BellyValuesList, i))
  EndWhile
  Return TotalWeight
EndFunction/;


;/Function updateItemProcess(Actor akTarget, Int aiTargetData, Float afTimePassed)
  {AKA Digest function}
  Int ItemType = JIntMap.nextKey(SCLib.JI_ItemTypes, endKey = -1)
  While ItemType != -1
    Int JF_ItemList = JMap.getObj(aiTargetData, "Contents" + ItemType)
    If !JValue.empty(JF_ItemList)
      Int ProcessEvent = ModEvent.Create("SCLProcessEvent" + ItemType)
      ModEvent.pushForm(ProcessEvent, akTarget)
      ModEvent.pushInt(ProcessEvent, aiTargetData)
      ModEvent.pushInt(ProcessEvent, JF_ItemList)
      ModEvent.PushFloat(ProcessEvent, afTimePassed)
      ModEvent.send(ProcessEvent)
    EndIf
    ItemType = JIntMap.nextKey(SCLib.JI_ItemTypes, ItemType, -1)
  EndWhile
  ;Notice("Processing completed for " + SCLib.nameGet(akTarget))
EndFunction/;

;/Float Function updateFullness(Actor akTarget, Int aiTargetData)
  {Checks each reported fullness, set "STFullness to it"}
  ;Notice("updateFullness starting for " + akTarget.GetLeveledActorBase().GetName())
  Int ItemType = JIntMap.nextKey(SCLib.JI_ItemTypes, endKey = -1)
  Float Total
  While ItemType != -1
    Total += JMap.getFlt(aiTargetData, "ContentsFullness" + ItemType)
    ItemType = JIntMap.nextKey(SCLib.JI_ItemTypes, ItemType, -1)
  EndWhile
  Float Max = SCLib.getMax(akTarget)
  If Total > Max && JMap.getInt(aiTargetData, "SCLAllowOverflow") == 0 && !SCLib.GodMode1 && SCLib.canVomit(akTarget)
    Float Delta = Total - Max
    SCLib.vomitAmount(akTarget, Delta, True, 30, True)
    JMap.setInt(aiTargetData, "SCLAllowOverflowTracking", JMap.getInt(aiTargetData, "SCLAllowOverflowTracking") + 1)
    Total -= Delta
    SCLib.addVomitDamage(akTarget)
  ElseIf Total < 0
    Issue("updateFullness return a total of less than 0. Setting to 0")
    Total = 0
  EndIf
  JMap.setFlt(aiTargetData, "STFullness", Total)
  Return Total
EndFunction/;

;/Function updateDamage(Actor akTarget)
  Float Overfull = SCLib.getOverfullPercent(akTarget)
  Int OverfullTier = SCLib.getOverfullTier(Overfull)
  Int CurrentOverfull = SCLib.getCurrentOverfull(akTarget)
  If OverfullTier != CurrentOverfull
    akTarget.AddSpell(SCLib.SCL_OverfullAbilityArray[OverfullTier])
  EndIf

  Float Heavy = SCLib.getHeavyPercent(akTarget)
  Int HeavyTier = SCLib.getHeavyTier(Heavy)
  Int CurrentHeavy = SCLib.getCurrentHeavy(akTarget)
  If HeavyTier != CurrentHeavy
    akTarget.addSpell(SCLib.SCL_HeavyAbilityArray[HeavyTier])
  EndIf
EndFunction/;
