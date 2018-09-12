ScriptName SCX_BaseAnimation Extends SCX_BaseRefAlias

Int Property MinNumActors = 1 Auto
Int Property MaxNumActors = 1 Auto
Package Property SCX_ActorHoldPackage Auto
Bool Function checkActors(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
EndFunction

Function prepAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
EndFunction

Function runAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
EndFunction

String[] Property RacesActor00 Auto
String[] Property RacesActor01 Auto
String[] Property RacesActor02 Auto
String[] Property RacesActor03 Auto
String[] Property RacesActor04 Auto
String[] Property RacesActor05 Auto
String[] Property RacesActor06 Auto
String[] Property RacesActor07 Auto
String[] Property RacesActor08 Auto
String[] Property RacesActor09 Auto

Function resetAnimGraph(Actor akTarget)
  Form REquip = akTarget.GetEquippedObject(1)
	Form LEquip = akTarget.GetEquippedObject(0)
	If REquip
		If REquip as Weapon || (REquip as Armor).IsShield()
			akTarget.UnequipItemEx(REquip, 1)
		ElseIf(REquip as Spell)
			akTarget.UnequipSpell(Requip as Spell, 1)
		EndIf
	EndIf
	If LEquip
		If LEquip as Weapon || (LEquip as Armor).IsShield()
			akTarget.UnequipItemEx(LEquip, 0)
		ElseIf(LEquip as Spell)
			akTarget.UnequipSpell(Requip as Spell, 0)
		EndIf
	EndIf
	Utility.Wait(0.1)
	If REquip
		If REquip as Weapon || (REquip as Armor && (REquip as Armor).IsShield())
			akTarget.EquipItemEx(REquip, 1, False, True)
		ElseIf REquip as Spell
			akTarget.EquipSpell(REquip as Spell, 1)
		EndIf
	EndIf
	If LEquip
		If LEquip as Weapon || (LEquip as Armor && (LEquip as Armor).IsShield())
			akTarget.EquipItemEx(LEquip, 2, False, True)
		ElseIf LEquip as Spell
			akTarget.EquipSpell(LEquip as Spell, 0)
		EndIf
	EndIf
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
