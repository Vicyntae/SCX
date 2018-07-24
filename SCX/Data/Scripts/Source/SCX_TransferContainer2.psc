ScriptName SCX_TransferContainer2 Extends ObjectReference
Int DMID = 4
String Property DebugName
  String Function Get()
    Return "[SCX_Transfer2 " + Target.GetLeveledActorBase().GetName() + "] "
  EndFunction
EndProperty
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
Actor Property PlayerRef Auto
Actor Target
Int TargetData
Bool Locked
String Archetype
SCX_BaseItemArchetypes ArchetypeForm
Bool EnableDebugMessages


ObjectReference Property akReturn Auto  ;Emergency place to put items in case something goes wrong
Actor Property TransferTarget
  Function Set(Actor akActor)
    Target = akActor
    TargetData = SCXLib.getTargetData(akActor)
  EndFunction
EndProperty
String Property Destination Auto

String Property TransferArchetype
  Function Set(String asArchetype)
    SCX_BaseItemArchetypes Arch = SCXLib.getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, asArchetype) as SCX_BaseItemArchetypes
    If Arch
      ArchetypeForm = Arch
      Archetype = asArchetype
    EndIf
  EndFunction
EndProperty

Bool _UpdateLocked = False
Function UpdateLock()
  If _UpdateLocked
    While _UpdateLocked
      Utility.WaitMenuMode(0.1)
    EndWhile
  EndIf
  _UpdateLocked = True
EndFunction

Function UpdateUnlock()
  ;/If GetNumItems() == 0
    SCX_.quickUpdate(Target, True)
  EndIf/;
  _UpdateLocked = False
EndFunction

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
  UpdateLock()
  If ArchetypeForm
    ArchetypeForm.addTransferItem(Target, akItemReference, akBaseItem, aiItemCount)
  Else
    Issue("Archetype file not found! Returning item...", 1)
    If akItemReference
      RemoveItem(akItemReference, aiItemCount, False, akReturn)
    Else
      RemoveItem(akBaseItem, aiItemCount, False, akReturn)
    EndIf
  EndIf
  UpdateUnlock()
EndEvent

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Debug Functions
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bool Function PlayerThought(Actor akTarget, String sMessage1 = "", String sMessage2 = "", String sMessage3 = "", Int iOverride = 0)
  {Use this to display player information. Returns whether the passed actor is
  the player.
  Make sure sMessage1 is 1st person, sMessage2 is 2nd person, sMessage3 is 3rd person
  Make sure at least one is filled: it will default to it regardless of setting
  Use iOverride to force a particular message}

  If akTarget == PlayerRef
    Int Setting = SCXSet.PlayerMessagePOV
    If Setting == -1
      Return True
    EndIf
    If (sMessage1 && Setting == 1) || iOverride == 1
      Debug.Notification(sMessage1)
    ElseIf (sMessage2 && Setting == 2) || iOverride == 2
      Debug.Notification(sMessage3)
    ElseIf (sMessage3 && Setting == 3) || iOverride == 3
      Debug.Notification(sMessage3)
    ElseIf sMessage3
      Debug.Notification(sMessage3)
    ElseIf sMessage1
      Debug.Notification(sMessage1)
    ElseIf sMessage2
      Debug.Notification(sMessage2)
    Else
      Issue("Empty player thought. Skipping...", 1)
    EndIf
    Return True
  Else
    Return False
  EndIf
EndFunction

Bool Function PlayerThoughtDB(Actor akTarget, String sKey, Int iOverride = 0, Int JA_Actors = 0, Int aiActorIndex = -1)
  {Use this to display player information. Returns whether the passed actor is
  the player.
  Pulls message from database; make sure sKey is valid.
  Will add POV int to end of key, so omit it in the parameter}
  If akTarget == PlayerRef
    Int Setting
    If iOverride != 0
      Setting = iOverride
    Else
      Setting = SCXSet.PlayerMessagePOV
    EndIf
    If Setting == -1
      Return True
    EndIf
    String sMessage = SCXLib.getMessage(sKey + Setting, -1, True, JA_Actors, aiActorIndex)
    If sMessage
      Debug.Notification(sMessage)
    Else
      PlayerThought(akTarget, SCXLib.getMessage(sKey + 1, -1, True, JA_Actors, aiActorIndex), SCXLib.getMessage(sKey + 2, -1, True, JA_Actors, aiActorIndex), SCXLib.getMessage(sKey + 3, -1, True, JA_Actors, aiActorIndex))
    EndIf
    Return True
  Else
    Return False
  EndIf
EndFunction

Function Popup(String sMessage)
  {Shows MessageBox, then waits for menu to be closed before continuing}
  Debug.MessageBox(DebugName + sMessage)
  Halt()
EndFunction

Function Halt()
  {Wait for menu to be closed before continuing}
  While Utility.IsInMenuMode()
    Utility.Wait(0.5)
  EndWhile
EndFunction

Function Note(String sMessage)
  Debug.Notification(DebugName + sMessage)
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Notice(String sMessage)
  {Displays message in notifications and logs if globals are active}
  If EnableDebugMessages
    Debug.Notification(DebugName + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Issue(String sMessage, Int iSeverity = 0, Bool bOverride = False)
  {Displays a serious message in notifications and logs if globals are active
  Use bOverride to ignore globals}
  If bOverride || EnableDebugMessages
    String Level
    If iSeverity == 0
      Level = "Info"
    ElseIf iSeverity == 1
      Level = "Warning"
    ElseIf iSeverity == 2
      Level = "Error"
    EndIf
    Debug.Notification(DebugName + Level + " " + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage, iSeverity)
EndFunction
