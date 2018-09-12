ScriptName SCVStruggleTracker Extends ActiveMagicEffect

SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Notification("Struggle Tracker started! handling finished actor " + akTarget.GetLeveledActorBase().GetName())
  SCVLib.handleFinishedActor(akTarget)
EndEvent
