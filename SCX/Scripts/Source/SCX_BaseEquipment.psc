ScriptName SCX_BaseEquipment Extends Armor

Float Property Threshold Auto

String[] Property BodyMorphs Auto
String Property MorphKeyName Auto
Function removeMorphs(Actor akTarget)
  Int i = BodyMorphs.length
  While i
    i -= 1
    NiOverride.ClearBodyMorph(akTarget, BodyMorphs[i], MorphKeyName)
  EndWhile
EndFunction


Function ApplyMorphs(Actor akTarget, Float afSize)
  Int i
  Int NumMorphs = BodyMorphs.length
  ;Debug.Notification("Start Size = " + afSize)
  If Threshold >= 0
    afSize -= Threshold
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
EndFunction
