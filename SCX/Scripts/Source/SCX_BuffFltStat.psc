ScriptName SCX_BuffFltStat Extends ActiveMagicEffect
{Increases/Decreases JContainers stat in the targetactor's ActorData
Magnitude = stat increase amount}
String Property Setting_StatKey Auto
Bool Property Setting_Recover Auto
Float StoredStat

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Int ActorData = SCX_Library.getActorData(akTarget)
  StoredStat = GetMagnitude()
  JMap.setFlt(ActorData, Setting_StatKey, JMap.getFlt(ActorData, Setting_StatKey) + StoredStat)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  If Setting_Recover
    Int ActorData = SCX_Library.getActorData(akTarget)
    JMap.setFlt(ActorData, Setting_StatKey, JMap.getFlt(ActorData, Setting_StatKey) - StoredStat)
  EndIf
EndEvent
