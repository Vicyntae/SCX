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
  While i < NumMorphs
    Float applyVal = afSize - Threshold
    NiOverride.SetBodyMorph(akTarget, BodyMorphs[i], MorphKeyName, applyVal)
    i += 1
  EndWhile
EndFunction
