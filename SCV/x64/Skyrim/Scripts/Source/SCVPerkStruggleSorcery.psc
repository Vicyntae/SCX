ScriptName SCVPerkStruggleSorcery Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
;*******************************************************************************
;/Info
;*******************************************************************************

Description: Allows actor to draw from their magicka pool while struggling.
  Also increases magicka struggle resistance by
  *1.2
  *1.5
;*******************************************************************************
Requirements: Have more than
*50
*70
*100
In either Destruction, Alteration, or Conjuration
;*******************************************************************************
/;


Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= AbilityArray.length - 1
    Return True
  EndIf
  Int Dest = akTarget.GetActorValue("Destruction") as int
  Int Alt = akTarget.GetActorValue("Alteration") as int
  Int Conj = akTarget.GetActorValue("Conjeration") as int
  If aiPerkLevel == 1 && (Dest >= 50 || Alt >= 50 || Conj >= 50)
    Return True
  ElseIf aiPerkLevel == 2 && (Dest >= 70 || Alt >= 70 || Conj >= 70)
    Return True
  ElseIf aiPerkLevel == 1 && (Dest >= 100 || Alt >= 100 || Conj >= 100)
    Return True
  EndIf
  Return False
EndFunction
