ScriptName SCVMonitor Extends SCX_BaseMonitor

Function Cleanup(SCX_Monitor akMonitor, Actor akTarget)
  akTarget.RemoveSpell(SCVSet.SCV_HasOVStrugglePrey)
  akTarget.RemoveSpell(SCVSet.SCV_HasAVStrugglePrey)
EndFunction

Function handleDeath(SCX_Monitor akMonitor, Actor akTarget, Actor akKiller)
  If SCVlib.hasPrey(MyActor, ActorData)
    SCVLib.handleFinishedActor(MyActor)
  EndIf
EndFunction
