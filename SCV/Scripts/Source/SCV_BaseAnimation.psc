ScriptName SCV_BaseAnimation Extends SCX_BaseAnimation
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
