ScriptName SCX_SpeedMultFix Extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
  RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
  GetTargetActor().ModActorValue("CarryWeight", 0.1)
  Utility.Wait(0.1)
  GetTargetActor().ModActorValue("CarryWeight", -0.1)
EndEvent
