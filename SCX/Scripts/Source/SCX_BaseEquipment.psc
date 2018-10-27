ScriptName SCX_BaseEquipment Extends Armor

;Holds armor before (=0) and armor after (=1) in chain
SCX_BaseEquipment[] Property ArmorChain Auto

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
  Int i = BodyMorphs.length
  While i
    i -= 1
    NiOverride.ClearBodyMorph(akTarget, BodyMorphs[i], MorphKeyName)
  EndWhile
EndFunction


Armor Function ApplyMorphs(Actor akTarget, Float afSize)
  If Thresholds[0] != -1 && afSize < Thresholds[0]
    akTarget.UnequipItem(Self, False, True)
    akTarget.RemoveItem(Self, 1, True)
    If MorphUndo[0]
      removeMorphs(akTarget)
    EndIf
    akTarget.AddItem(ArmorChain[0], 1, True)
    akTarget.EquipItem(ArmorChain[0], False, True)
    Return ArmorChain[0].ApplyMorphs(akTarget, afSize)
  ElseIf Thresholds[1] != -1 && afSize > Thresholds[1]
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
  ;Debug.Notification("Start Size = " + afSize)
  If Thresholds[0] >= 0
    afSize -= Thresholds[0]
  EndIf
  afSize -= 1
  If afSize < 0
    afSize = 0
  EndIf
  afSize /= 100
  ;Debug.Notification("End Size = " + afSize)
  While i < NumMorphs
    NiOverride.SetBodyMorph(akTarget, BodyMorphs[i], MorphKeyName, afSize)
    i += 1
  EndWhile
  NiOverride.UpdateModelWeight(akTarget)
  Return Self
EndFunction
