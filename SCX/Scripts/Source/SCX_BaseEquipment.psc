ScriptName SCX_BaseEquipment Extends Armor

;Holds armor before (=0) and armor after (=1) in chain
SCX_BaseEquipment[] Property ArmorChain Auto

String Property DebugName
  String Function Get()
    Return "[SCX_BaseEquip " + GetName() + "] "
  EndFunction
EndProperty

Bool EnableDebugMessages = True

;Holds the point at which the armor will equip next in chain. Will be ignored if -1
Float[] Property Thresholds Auto

;Will apply these morphs to the character based on size passed.
;May want to adjust how they are applied (applied flat - Thresholds[0])
String[] Property BodyMorphs Auto

;If true, will remove the morphs applied by this armor prior to equiping the next one
Bool[] Property MorphUndo Auto
;Holds a key unique to this chain of armors to easily remove any morphs w/NiOverride
String Property MorphKeyName Auto

Function removeMorphs(Actor akTarget)
  Note("Removing Morphs...")
  Int i = BodyMorphs.length
  While i
    i -= 1
    NiOverride.ClearBodyMorph(akTarget, BodyMorphs[i], MorphKeyName)
  EndWhile
EndFunction


Armor Function ApplyMorphs(Actor akTarget, Float afSize)
  Note("Thresholds size = " + Thresholds.Length)
  Note("Applying morphs, size = " + afSize + ", Thresholds = " + Thresholds[0] + ", " + Thresholds[1])
  If Thresholds[0] != -1 && afSize < Thresholds[0]
    Note("Below bottom threshold! moving to previous tier!")
    akTarget.UnequipItem(Self, False, True)
    akTarget.RemoveItem(Self, 1, True)
    If MorphUndo[0]
      removeMorphs(akTarget)
    EndIf
    akTarget.AddItem(ArmorChain[0], 1, True)
    akTarget.EquipItem(ArmorChain[0], False, True)
    Return ArmorChain[0].ApplyMorphs(akTarget, afSize)
  ElseIf Thresholds[1] != -1 && afSize > Thresholds[1]
    Note("Above top threshold! Moving to next tier!")
    akTarget.UnequipItem(Self, False, True)
    akTarget.RemoveItem(Self, 1, True)
    If MorphUndo[1]
      removeMorphs(akTarget)
    EndIf
    akTarget.AddItem(ArmorChain[0], 1, True)
    akTarget.EquipItem(ArmorChain[1], False, True)
    Return ArmorChain[1].ApplyMorphs(akTarget, afSize)
  EndIf
  Int i
  Int NumMorphs = BodyMorphs.length
  Debug.Notification("Start Size = " + afSize)
  If Thresholds[0] >= 0
    afSize -= Thresholds[0]
  EndIf
  afSize -= 1
  If afSize < 0
    afSize = 0
  EndIf
  afSize /= 100
  Debug.Notification("End Size = " + afSize)
  While i < NumMorphs
    Note("Setting morph " + BodyMorphs[i])
    NiOverride.SetBodyMorph(akTarget, BodyMorphs[i], MorphKeyName, afSize)
    i += 1
  EndWhile
  NiOverride.UpdateModelWeight(akTarget)
  Return Self
EndFunction

;Debug Functions +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
