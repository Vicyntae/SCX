ScriptName SCVSpellAlarmCheck Extends ActiveMagicEffect

SCX_BasePerk Property SCV_FriendlyFood Auto
Actor Property PlayerRef Auto
Faction Property PotentialFollowerFaction Auto
Faction Property CurrentFollowerFaction Auto
SCX_BasePerk Property SCV_Stalker Auto
Bool Property Setting_Lethal Auto
Event OnEffectStart(Actor akTarget, Actor akCaster)
  If akCaster == PlayerRef || akCaster.IsInFaction(PotentialFollowerFaction)
    Int PerkLevel = SCV_FriendlyFood.getPerkLevel(PlayerRef)
    If PerkLevel >= 5
      Return
    ElseIf (akTarget.IsInFaction(PotentialFollowerFaction) || akTarget.IsInFaction(CurrentFollowerFaction))
      If Setting_Lethal && PerkLevel >= 3
        Return
      ElseIf PerkLevel >= 1
        Return
      EndIf
    ElseIf akTarget.GetRelationshipRank(PlayerRef) >= 2
      If Setting_Lethal && PerkLevel >= 4
        Return
      ElseIf PerkLevel >= 2
        Return
      EndIf
    ElseIf akCaster.IsSneaking() && akCaster.IsDetectedBy(akTarget)
      Return
    EndIf
    akTarget.SendAssaultAlarm()
  EndIf
EndEvent
