ScriptName SCV_BaseAnimation Extends SCX_BaseAnimation
Int Property MinActors Auto
Int Property MaxActors Auto
Float Property ScaleMin Auto
Float Property ScaleMax Auto
Float Property DistanceMin Auto
Float Property DistanceMax Auto
SCVSettings Property SCVSet Auto
SCVLibrary Property SCVLib Auto
SCVStrugglingArchetype Property Struggling Auto

;/Standard Prey Profile Keys
Success
Lethal
SizeRatio
Distance
RaceString
VoreType/;

Int Function _getSCX_JC_List()
	Return SCVSet.JM_VoreAnimationList
EndFunction

Function OpenMouth(Actor ActorRef) ;Sets Mouth state
	ClearPhoneme(ActorRef)
	ActorRef.SetExpressionOverride(16, 80)
	MfgConsoleFunc.SetPhonemeModifier(ActorRef, 0, 1, 60)
	;Utility.WaitMenuMode(0.1)
endFunction

function CloseMouth(Actor ActorRef)
	ActorRef.SetExpressionOverride(7, 50)
	MfgConsoleFunc.SetPhonemeModifier(ActorRef, 0, 1, 0)
	;Utility.WaitMenuMode(0.1)
endFunction

function ClearPhoneme(Actor ActorRef)
	int i
	while i <= 15
		MfgConsoleFunc.SetPhonemeModifier(ActorRef, 0, i, 0)
		i += 1
	endWhile
endFunction
