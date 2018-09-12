ScriptName SCV_EffectTesting Extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Notification("Effect Started on " + akTarget.GetLeveledActorBase().GetName())
EndEvent
