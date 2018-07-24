ScriptName SCX_BodyEditBelly Extends SCX_BaseBodyEdit

Spell Property SCX_BodyEditBellySpell Auto
Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If !akTarget.HasKeyword(SCXSet.ActorTypeNPC)
    Race akRace = akTarget.GetRace()
    If CreatureRaces.find(akRace) == -1
      Return
    EndIf
  EndIf
  Int TargetData = SCXLib.getTargetData(akTarget)
  JMap.setFlt(TargetData, "SCX_BodyEditBellyTargetValue", afValue)
  If asMethodOverride
    JMap.setStr(TargetData, MethodKey, asMethodOverride)
  EndIf
  If aiEquipSetOverride
    JMap.setInt(TargetData, EquipmentTierKey, aiEquipSetOverride)
  EndIf
  If !akTarget.HasSpell(SCX_BodyEditBellySpell)
    akTarget.AddSpell(SCX_BodyEditBellySpell, False)
  EndIf
EndFunction
