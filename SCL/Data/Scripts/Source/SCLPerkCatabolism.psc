ScriptName SCLPerkCatabolism Extends SCX_BasePerk
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto

;*******************************************************************************
;/Info
;*******************************************************************************

Description: Increases Digestion Rate by:
  *0.5
  *1
  *3
  *5
  *10
;*******************************************************************************
Requirements: Digest a total of * Items:
  *20
  *50
  *150
  *400
  *1000
;*******************************************************************************
/;

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= AbilityArray.Length - 1
    Return True
  EndIf
  Int Req
  If aiPerkLevel == 1
    Req = 20
  ElseIf aiPerkLevel == 2
    Req = 50
  ElseIf aiPerkLevel == 3
    Req = 150
  ElseIf aiPerkLevel == 4
    Req = 400
  ElseIf aiPerkLevel == 5
    Req = 1000
  ElseIf aiPerkLevel >= 6
    Return False
  EndIf
  Int NumItemsDigest = JMap.getInt(aiTargetData, "SCLNumItemsDigested")
  If NumItemsDigest >= Req
    Return True
  EndIf
  Return False
EndFunction

Bool Function takePerk(Actor akTarget, Bool abOverride = False, Int aiTargetData = 0)
  Int TargetData = SCLib.getData(akTarget, aiTargetData)
  Int i = getPerkLevel(akTarget) + 1
  If canTake(akTarget, i, abOverride)
    Float AddAmount
    If i == 1
      AddAmount = 0.5
    ElseIf i == 2
      AddAmount = 1
    ElseIf i == 3
      AddAmount = 3
    ElseIf i == 4
      AddAmount = 5
    ElseIf i == 5
      AddAmount = 10
    EndIf
    JMap.setFlt(TargetData, "SCLDigestRate", JMap.getFlt(TargetData, "SCLDigestRate", 0.5) + AddAmount)
    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction
