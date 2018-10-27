ScriptName SCX_Monitor Extends SCX_BaseRefAlias
Actor _MyActor
Actor Property MyActor
  Actor Function Get()
    Return _MyActor
  EndFunction
  Function Set(Actor a_val)
    If a_val
      _MyActor = a_val
      ActorData = SCXLib.getTargetData(a_val, True)
      ScriptID = "SCX_Monitor " + MyActorName
    Else
      _MyActor = None
      ActorData = 0
      ScriptID = "SCX_Monitor"
    EndIf
  EndFunction
EndProperty
Int Property ActorData Auto
String Property MyActorName
  String Function Get()
    If MyActor
      Return MyActor.GetLeveledActorBase().GetName()
    Else
      Return ""
    EndIf
  EndFunction
EndProperty

String Function _getStrKey()
  Return "SCX_Monitor" + GetID()
EndFunction

Event OnInit()

EndEvent

Function setupMonitor()
  EnableDebugMessages = True
  Notice("Running setup...")
  ;Lock()
  Actor Target = GetActorReference()
  If Target && Target != MyActor
    MyActor = Target
  EndIf

  If Target
    Int JA_UpdateList = (GetOwningQuest() as SCX_MonitorManager).JA_MonitorUpdatePrioityList
    Int i
    Int NumLibs = JArray.count(JA_UpdateList)
    Notice("Number of Libraries =" + NumLibs)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_UpdateList, i) as SCX_BaseLibrary
      If Lib
        Note("Library Found!")
        Lib.monitorSetup(Self, MyActor)
      Else
        Note("Library not found!")
      EndIf
      i += 1
    EndWhile
  EndIf
  RegisterForModEvent("SCX_MonitorUpdate", "OnMonitorUpdate")
  ;Unlock()/;
EndFunction

Function ForceRefTo(ObjectReference akNewRef)
  ;Notice("ForceRefTo called, performing setup again.")
  Notice("ForceRefTo Called.")
  If MyActor
    UnregisterForAllModEvents()
    Int JA_UpdateList = (GetOwningQuest() as SCX_MonitorManager).JA_MonitorUpdatePrioityList
    Int i
    Int NumLibs = JArray.count(JA_UpdateList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_UpdateList, i) as SCX_BaseLibrary
      If Lib
        Lib.monitorCleanup(Self, MyActor)
      EndIf
      i += 1
    EndWhile
  EndIf
  Parent.ForceRefTo(akNewRef)
  setupMonitor()
EndFunction

Function Clear()
  If MyActor
    UnregisterForAllModEvents()
    Int JA_UpdateList = (GetOwningQuest() as SCX_MonitorManager).JA_MonitorUpdatePrioityList
    Int i
    Int NumLibs = JArray.count(JA_UpdateList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_UpdateList, i) as SCX_BaseLibrary
      If Lib
        Lib.monitorCleanup(Self, MyActor)
      EndIf
      i += 1
    EndWhile
  EndIf
  Parent.Clear()
EndFunction

Event OnMonitorUpdate(Form akTarget, Float afTimePassed, float afCurrentUpdateTime, Bool abDailyUpdate)
  If MyActor && akTarget == MyActor
    Int JA_UpdateList = (GetOwningQuest() as SCX_MonitorManager).JA_MonitorUpdatePrioityList
    Int i
    Int NumLibs = JArray.count(JA_UpdateList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_UpdateList, i) as SCX_BaseLibrary
      If Lib
        Lib.monitorUpdate(Self, MyActor, ActorData, afTimePassed, afCurrentUpdateTime, abDailyUpdate)
      EndIf
      i += 1
    EndWhile
  EndIf
EndEvent

Event OnDeath(Actor akKiller)
  Int JA_UpdateList = (GetOwningQuest() as SCX_MonitorManager).JA_MonitorUpdatePrioityList
  Int i
  Int NumLibs = JArray.count(JA_UpdateList)
  While i < NumLibs
    SCX_BaseLibrary Lib = JArray.getForm(JA_UpdateList, i) as SCX_BaseLibrary
    If Lib
      Lib.monitorDeath(Self, MyActor, akKiller)
    EndIf
    i += 1
  EndWhile
EndEvent

Function reloadMaintenence()
  RegisterForModEvent("SCX_MonitorUpdate", "OnMonitorUpdate")
  If MyActor
    Int JA_UpdateList = (GetOwningQuest() as SCX_MonitorManager).JA_MonitorUpdatePrioityList
    Int i
    Int NumLibs = JArray.count(JA_UpdateList)
    While i < NumLibs
      SCX_BaseLibrary Lib = JArray.getForm(JA_UpdateList, i) as SCX_BaseLibrary
      If Lib
        Lib.monitorReloadMaintenence(Self, MyActor)
      EndIf
      i += 1
    EndWhile
  EndIf
EndFunction

Bool Property _Lock = False Auto
Function Lock()
  {Prevents multiple threads from running at the same time
  Does not keep track of which thread came first, will pass at first come
  Will break itself after 100 iterations}
  If _Lock
    Int i
    While _Lock && i < 100
      Utility.WaitMenuMode(0.5)
      i += 1
    EndWhile
  EndIf
  _Lock = True
EndFunction

Function Unlock()
  _Lock = False
EndFunction

Bool Property _EXLocked = False Auto
Bool Function LockEX()
  {Exclusionary lock, will toss out any function calls made after the first
  Make sure to return the function after recieving false
  If !LockEX()
    Return
  EndIf}
  If _EXLocked
    Return False
  EndIf
  _EXLocked = True
  Return True
EndFunction

Function UnlockEX()
  _EXLocked = False
EndFunction
