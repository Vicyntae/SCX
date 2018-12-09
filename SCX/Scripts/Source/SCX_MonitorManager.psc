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

Function reloadMaintenence()
  ;Note("Running reload maintenence...")
  RegisterForModEvent("SCX_Reset", "OnSCXReset")
  RegisterForSingleUpdate(UpdateRate)
EndFunction

Event OnMenuOpen(String menuName)
  UnregisterForUpdate()
EndEvent

Event OnMenuClose(string menuName)
  If menuName == "Sleep/Wait Menu"
    ;Note("Sleep Detected. Updating actors.")
    QueueDailyUpdate = True
    RegisterForSingleUpdate(0.1)
  EndIf
EndEvent

Bool SCXResetted = False
Event OnSCXReset()
  SCXResetted = True
EndEvent

Bool Function Start()
  Bool bReturn = Parent.Start()
  EnableDebugMessages = True
  ;Notice("Starting up monitor manager")
  ;Utility.Wait(3)
  ;RegisterForSleep()
  RegisterForMenu("Sleep/Wait Menu")
  RegisterForModEvent("SCLReset", "OnSCLReset")
  RegisterForSingleUpdate(UpdateRate)
  (GetNthAlias(0) as SCX_Monitor).setupMonitor()
  Return bReturn
EndFunction

Function Stop()
  UnregisterForUpdate()
  Parent.Stop()
EndFunction

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
      Notice("Building monitor update priority list...")
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
        ;Notice("Beginning full updates for " + nameGet(akTarget))
        Int handle = ModEvent.Create("SCX_MonitorUpdate")
        ModEvent.PushForm(handle, akTarget)
        ModEvent.PushFloat(handle, TimePassed)
        ModEvent.pushFloat(handle, CurrentUpdateTime)
        ModEvent.PushBool(handle, DailyUpdate)
        ModEvent.Send(handle)
      EndIf
      JMap.setFlt(TargetData, "LastUpdateTime", CurrentUpdateTime)
      Utility.Wait(UpdateDelay)
    EndIf
    i += 1
  EndWhile
  LastDailyUpdate = CurrentUpdateTime
  RegisterForSingleUpdate(UpdateRate)
EndEvent
