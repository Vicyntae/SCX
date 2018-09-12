ScriptName SCX_MonitorFinder Extends SCX_BaseQuest

Formlist Property SCX_RejectList Auto
Quest Property SCX_MonitorManagerQuest Auto
FormList Property SCX_TrackRaceList Auto
Form[] Property LoadedActors Auto
Form[] Property TeammatesList Auto
GlobalVariable Property SCX_SET_MaxActorTracking Auto ;Default 20
Int Property MaxActorTracking
  Int Function Get()
    Return SCX_SET_MaxActorTracking.GetValueInt()
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableFollowerTracking Auto;Default 0
Bool Property EnableFollowerTracking
  Bool Function Get()
    Return SCX_SET_EnableFollowerTracking.GetValueInt() as Bool
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableUniqueTracking Auto ;Default 0
Bool Property EnableUniqueTracking
  Bool Function Get()
    Return SCX_SET_EnableUniqueTracking.GetValueInt() as Bool
  EndFunction
EndProperty

GlobalVariable Property SCX_SET_EnableNPCTracking Auto ;Default 0
Bool Property EnableNPCTracking
  Bool Function Get()
    Return SCX_SET_EnableNPCTracking.GetValueInt() as Bool
  EndFunction
EndProperty
Int DMID = 3
;Can we devise a system to prioitize teammates?

Bool Function Start()
  Bool bReturn = Parent.Start()
  ;Notice("Starting up, getting actors")
  If !SCX_MonitorManagerQuest.IsRunning()
    ;Notice("Monitor Manager not running!")
    SCX_MonitorManagerQuest.Start()
    Utility.Wait(2)
  EndIf
  ReferenceAlias PlayerAlias = SCX_MonitorManagerQuest.GetNthAlias(0) as ReferenceAlias
  If PlayerAlias.GetActorReference() != PlayerRef
    ;Notice("Filling PlayerAlias")
    PlayerAlias.ForceRefTo(PlayerRef)
  EndIf
  If !LoadedActors || LoadedActors.length != SCX_MonitorManagerQuest.GetNumAliases()
    ;Notice("Loaded Actors List not found! Remaking list...")
    LoadedActors = getActors()
  EndIf
  Form[] NewActors = getNewActors()
  Int JA_Teammates = JArray.object()
  ;Notice("Removing no longer loaded actors")
  Int i
  Int MaxTrack = MaxActorTracking
  Int LoadedNum = LoadedActors.length
  While i < LoadedNum
    Actor LoadedActor = LoadedActors[i] as Actor
    If LoadedActor && LoadedActor != PlayerRef
      Int j = NewActors.find(LoadedActor)
      If j < 0
        ;Notice(nameGet(LoadedActor) + " is not in New Actors list! Removing...")
        LoadedActors[i] = None
        removeFromLoadedActors(LoadedActor, i)
      ElseIf i > MaxTrack ;Check if actor positions are filled
        LoadedActors[i] = None
        removeFromLoadedActors(LoadedActor, i)
      EndIf
    EndIf
    i += 1
  EndWhile

  ;Notice("Adding new actors")
  i = 0
  LoadedNum = NewActors.length
  While i < LoadedNum
    Actor NewActor = NewActors[i] as Actor
    If NewActor && NewActor != PlayerRef
      Bool NoList
      If (NewActor.IsInFaction(SCXSet.CurrentFollowerFaction) || NewActor.IsInFaction(SCXSet.PotentialFollowerFaction))
        If !EnableFollowerTracking
          SCX_RejectList.AddForm(NewActor.GetLeveledActorBase())
          NoList = True
        EndIf
      ElseIf NewActor.GetLeveledActorBase().IsUnique()
        If !EnableUniqueTracking
          SCX_RejectList.AddForm(NewActor.GetLeveledActorBase())
          NoList = True
        EndIf
      ElseIf !EnableNPCTracking
        SCX_RejectList.AddForm(NewActor.GetLeveledActorBase())
        NoList = True
      EndIf
      Race Trackrace = NewActor.GetRace()
      If !Trackrace.HasKeyword(SCXSet.ActorTypeNPC)
        If !SCX_TrackRaceList.HasForm(Trackrace)
          SCX_RejectList.AddForm(NewActor.GetLeveledActorBase())
          NoList = True
        EndIf
      EndIf
      If !NoList
        Int j = LoadedActors.find(NewActor)
        If j < 0
          ;Notice(nameGet(NewActor) + " is not in Monitor Manager! Adding...")
          Int k = addToLoadedActors(NewActor)
          If k != -1
            LoadedActors[k] = NewActor
          Else
            ;Notice("No slots open!")
          EndIf
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  Return bReturn
EndFunction

;/Event OnInit()
  Notice("Starting up, getting actors")
  If !SCX_MonitorManagerQuest.IsRunning()
    Notice("Monitor Manager not running!")
    Return
  EndIf
  If !SCXLib.LoadedActors
    SCXLib.LoadedActors = getActors()
  EndIf
  Form[] NewActors = getNewActors()

  ;Notice("Removing no longer loaded actors")
  Int i = SCXLib.LoadedActors.length
  While i
    i -= 1
    Actor LoadedActor = SCXLib.LoadedActors[i] as Actor
    If LoadedActor && LoadedActor != PlayerRef
      Int j = NewActors.find(LoadedActor)
      If j < 0
        ;Notice(SCXLib.nameGet(LoadedActor) + " is not in New Actors list! Removing...")
        SCXLib.LoadedActors[i] = None
        removeFromLoadedActors(LoadedActor, i)
      EndIf
    EndIf
  EndWhile

  ;Notice("Adding new actors")
  i = NewActors.length
  While i
    i -= 1
    Actor NewActor = NewActors[i] as Actor
    If NewActor && NewActor != PlayerRef
      Int j = SCXLib.LoadedActors.find(NewActor)
      If j < 0
        ;Notice(SCXLib.nameGet(NewActor) + " is not in Monitor Manager! Adding...")
        Int k = addToLoadedActors(NewActor)
        If k != -1
          SCXLib.LoadedActors[k] = NewActor
        Else
          Notice("No slots open!")
        EndIf
      EndIf
    EndIf
  EndWhile
EndEvent/;

Function removeFromLoadedActors(Actor akTarget, Int i)
  ;Notice("Removing Alias " + i + ": " + akTarget.GetLeveledActorBase().GetName())
  (SCX_MonitorManagerQuest.GetNthAlias(i) as ReferenceAlias).Clear()
  ;/Int i = SCX_MonitorManagerQuest.GetNumAliases()
  While i
    i -= 1
    Notice("Remove: Checking Alias " + i)
    ReferenceAlias LoadedAlias = SCX_MonitorManagerQuest.GetNthAlias(i) as ReferenceAlias
    If LoadedAlias.GetActorReference() == akTarget
      Notice("Remove: Found " akTarget.GetLeveledActorBase().GetName())
      LoadedAlias.Clear()
      Return
    EndIf
  EndWhile/;
EndFunction

Int Function addToLoadedActors(Actor akTarget)
  Int i
  Int NumAlias = SCX_MonitorManagerQuest.GetNumAliases()
  Int MaxTrack = MaxActorTracking
  If MaxTrack > NumAlias - 1
    MaxTrack = NumAlias - 1
  EndIf
  ;Note("Adding to loaded actor list. MaxTrack = " + MaxTrack)
  While i <= MaxTrack
    ;Notice("Add: Checking Alias " + i)
    ReferenceAlias LoadedAlias = SCX_MonitorManagerQuest.GetNthAlias(i) as ReferenceAlias
    If !LoadedAlias.GetActorReference()
      ;Notice("Add: Found empty alias " + i)
      LoadedAlias.ForceRefTo(akTarget)
      Return i
    EndIf
    i += 1
  EndWhile
  Return -1
EndFunction

Form[] Function getActors()
;Notice("Getting current actor list...")
  Int i
  Int NumAlias = SCX_MonitorManagerQuest.GetNumAliases()
  ;Note("NumAliases = " + NumAlias)
  Form[] ReturnArray = Utility.CreateFormArray(NumAlias, None)
  While i <  NumAlias
    ReferenceAlias LoadedAlias = SCX_MonitorManagerQuest.GetNthAlias(i) as ReferenceAlias
    Actor Target = LoadedAlias.GetActorReference()
    If Target
      ;Notice("Loaded actor = " + nameGet(Target))
      ReturnArray[i] = Target
    EndIf
    i += 1
  EndWhile
  Return ReturnArray
EndFunction

Form[] Function getNewActors()
  ;Notice("Getting new actors list...")
  Int i
  Int NumAlias = GetNumAliases()
  ;Note("NumAliases = " + NumAlias)
  Int JA_Teammates = JArray.object()
  Form[] ReturnArray = Utility.CreateFormArray(NumAlias, None)
  Faction FollowFact = SCXSet.CurrentFollowerFaction
  While i < NumAlias
    ReferenceAlias LoadedAlias = GetNthAlias(i) as ReferenceAlias
    Actor Target = LoadedAlias.GetActorReference()
    If Target
      ;Notice("Found Actor: " + nameGet(Target))
      ReturnArray[i] = Target
      If Target.IsInFaction(FollowFact)
        JArray.addForm(JA_Teammates, Target)
      EndIf
    EndIf
    i += 1
  EndWhile
  If JValue.empty(JA_Teammates) && TeammatesList.length != 0
    TeammatesList = None
  Else
    TeammatesList = Utility.CreateFormArray(JArray.count(JA_Teammates))
    JArray.writeToFormPArray(JA_Teammates, TeammatesList)
  EndIf
  Return ReturnArray
EndFunction
