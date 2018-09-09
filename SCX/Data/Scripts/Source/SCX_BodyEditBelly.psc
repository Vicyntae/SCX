ScriptName SCX_BodyEditBelly Extends SCX_BaseBodyEdit

Spell Property SCX_BodyEditBellySpell Auto

GlobalVariable Property SCX_BodyEditBellyEnable Auto
Function reloadMaintenence()
  SCX_BodyEditBellyEnable.SetValueInt(0)
  Utility.Wait(5)
  SCX_BodyEditBellyEnable.SetValueInt(1)
EndFunction

Function editBodyPart(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If !akTarget.HasKeyword(SCXSet.ActorTypeNPC)
    Race akRace = akTarget.GetRace()
    If CreatureRaces.find(akRace) == -1
      Return
    EndIf
  EndIf
  Int TargetData = SCXLib.getTargetData(akTarget)
  afValue *= Multiplier
  afValue *= (akTarget.GetLeveledActorBase().GetWeight() / 100 * HighScale) + 1
  afValue /= akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False)
  afValue = curveValue(afValue)
  afValue = PapyrusUtil.ClampFloat(afValue, Minimum, Maximum)

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
  Int Handle = ModEvent.Create("SCX_BodyEditBellySpellMethodUpdate")
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushBool(Handle, False)
  ModEvent.send(Handle)
EndFunction

Function rapidEdit(Actor akTarget, Float afValue, String asMethodOverride = "", Int aiEquipSetOverride = 0, String asShortModKey = "SCX.esp", String asFullModKey = "Skyrim Character Extended")
  If !akTarget.HasKeyword(SCXSet.ActorTypeNPC)
    Race akRace = akTarget.GetRace()
    If CreatureRaces.find(akRace) == -1
      Return
    EndIf
  EndIf
  Int TargetData = SCXLib.getTargetData(akTarget)
  afValue *= Multiplier
  afValue *= (akTarget.GetLeveledActorBase().GetWeight() / 100 * HighScale) + 1
  afValue /= akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False)
  afValue = curveValue(afValue)
  afValue = PapyrusUtil.ClampFloat(afValue, Minimum, Maximum)

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
  Int Handle = ModEvent.Create("SCX_BodyEditBellySpellMethodUpdate")
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushBool(Handle, True)
  ModEvent.send(Handle)
EndFunction

Function setMenuOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption, Int aiIndex)
  If asValue == "Methods"
    CurrentMethod = Methods[aiIndex]
    MCM.SetMenuOptionValue(aiOption, CurrentMethod)
    Int Handle = ModEvent.Create("SCX_BodyEditBellySpellMethodUpdate")
    ModEvent.send(Handle)
  Else
    Parent.setMenuOptions(MCM, asValue, aiOption, aiIndex)
  EndIf
EndFunction
