ScriptName SCLMonitor Extends ActiveMagicEffect

SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
SCX_Settings Property SCXSet Auto
SCX_Library Property SCXLib Auto

String Property DebugName
  String Function Get()
    return "[SCLMonitor " + nameGet(GetTargetActor()) + "] "
  EndFunction
EndProperty

Bool EnableDebugMessages = True
Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Notification("SCL Monitor Starting!...")
EndEvent

;/Event OnQuickUpdate()
  Notice("quickUpdate received")
  Float Percent = SCLib.getOverfullPercent(MyActor)
  If Percent != 0
    Float ReactChance = Utility.RandomFloat()
    ReactChance *= Percent + 1
    If ReactChance >= 0.9
      ;Note("*Groaning Noise*")
      ;Play groaning topic
      PlayerThoughtDB(MyActor, "SCLOverfullMessage")
    EndIf
  EndIf
EndEvent/;

Int JF_AddQueue
Int AddQueueNum = 0
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  If akBaseObject as Potion || akBaseObject as Ingredient
    Int JM_Entry = SCLib.getItemDatabaseEntry(akBaseObject)
    Note("Item equipped: " + akBaseObject.GetName() + ". Entry found: " + JValue.isExists(JM_Entry))
    If JMap.getInt(JM_Entry, "STIsNotFood") == 0 || (akBaseObject as Potion).IsPoison()
      SCLib.Notice(akBaseObject.GetName() + " was eaten!")
      Bool FirstItem
      If !JF_AddQueue
        JF_AddQueue = JValue.retain(JFormMap.object())
        FirstItem = True
      Else
        AddQueueNum += 1
      EndIf
      If akReference
        If JFormMap.hasKey(JF_AddQueue, akReference)
          JFormMap.setInt(JF_AddQueue, akReference, JFormMap.getInt(JF_AddQueue, akReference) + 1)
        Else
          JFormMap.setInt(JF_AddQueue, akReference, 1)
        EndIf
      Else
        If JFormMap.hasKey(JF_AddQueue, akBaseObject)
          JFormMap.setInt(JF_AddQueue, akBaseObject, JFormMap.getInt(JF_AddQueue, akBaseObject) + 1)
        Else
          JFormMap.setInt(JF_AddQueue, akBaseObject, 1)
        EndIf
      EndIf
      Utility.Wait(0.5)
      If FirstItem
        While AddQueueNum > 0
          Utility.Wait(1)
        EndWhile
      Else
        AddQueueNum -= 1
        Return
      EndIf
      Form ItemKey = JFormMap.nextKey(JF_AddQueue)
      While ItemKey
        Form Base
        If ItemKey as ObjectReference
          Base = (ItemKey as ObjectReference).GetBaseObject()
        Else
          Base = ItemKey
        EndIf
        SCLib.Stomach.addToContents(GetTargetActor(), ItemKey as ObjectReference, Base, "Breakdown", aiItemCount = JFormMap.getInt(JF_AddQueue, ItemKey, 1))
        ItemKey = JFormMap.nextKey(JF_AddQueue, ItemKey)
      EndWhile
      SCLib.Stomach.updateArchetype(GetTargetActor())
      SCLib.updateDamage(GetTargetActor())
      Int Handle = ModEvent.Create("SCLActorItemEaten")
      ModEvent.PushForm(Handle, GetTargetActor())
      ModEvent.PushInt(Handle, JF_AddQueue)
      ModEvent.Send(Handle)
      JF_AddQueue = JValue.release(JF_AddQueue)
    EndIf
  EndIf
EndEvent

String Function nameGet(Form akTarget)
  If akTarget as SCX_Bundle
    Return (akTarget as SCX_Bundle).ItemForm.GetName()
  ElseIf akTarget as Actor
    Return (akTarget as Actor).GetLeveledActorBase().GetName()
  ElseIf akTarget as ObjectReference
    Return (akTarget as ObjectReference).GetBaseObject().GetName()
  Else
    Return akTarget.GetName()
  EndIf
EndFunction
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Debug Functions
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bool Function PlayerThought(Actor akTarget, String sMessage1 = "", String sMessage2 = "", String sMessage3 = "", Int iOverride = 0)
  {Use this to display player information. Returns whether the passed actor is
  the player.
  Make sure sMessage1 is 1st person, sMessage2 is 2nd person, sMessage3 is 3rd person
  Make sure at least one is filled: it will default to it regardless of setting
  Use iOverride to force a particular message}

  If akTarget == Game.GetPlayer()
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
  If akTarget == Game.GetPlayer()
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
