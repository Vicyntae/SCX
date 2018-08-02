ScriptName SCX_BuffIntStat Extends ActiveMagicEffect
{Increases/Decreases JContainers stat in the targetactor's ActorData
Magnitude = stat increase amount}
String Property Setting_PerkID Auto
Bool Property Setting_Recover Auto
Int StoredStat

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Int ActorData = SCX_Library.getActorData(akTarget)
  StoredStat = GetMagnitude() as Int
  JMap.setInt(ActorData, Setting_PerkID, JMap.getInt(ActorData, Setting_PerkID) + StoredStat)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  If Setting_Recover
    Int ActorData = SCX_Library.getActorData(akTarget)
    JMap.setInt(ActorData, Setting_PerkID, JMap.getInt(ActorData, Setting_PerkID) - StoredStat)
  EndIf
EndEvent
