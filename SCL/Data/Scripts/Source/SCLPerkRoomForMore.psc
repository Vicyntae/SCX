ScriptName SCLPerkRoomForMore Extends SCX_BasePerk
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto

;*******************************************************************************
;/Info
;*******************************************************************************

Description: Increases Base Capacity by:
  *2.5
  *5
  *10
  *15
  *20
;*******************************************************************************
Requirements: Digest a total of * Units:
  *50
  *150
  *500
  *1000
  *3000
;*******************************************************************************
/;

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= AbilityArray.Length - 1
    Return True
  EndIf
  Int TargetData = SCLib.getData(akTarget, aiTargetData)
  Int Req
  If aiPerkLevel == 1
    Req = 50
  ElseIf aiPerkLevel == 2
    Req = 150
  ElseIf aiPerkLevel == 3
    Req = 500
  ElseIf aiPerkLevel == 4
    Req = 1000
  ElseIf aiPerkLevel == 5
    Req = 3000
  ElseIf aiPerkLevel >= 6
    Return False
  EndIf
  Float DigestFood = JMap.getFlt(TargetData, "SCLTotalDigestedFood")
  If DigestFood >= Req
    Return True
  Else
    Return False
  EndIf
EndFunction

Bool Function takePerk(Actor akTarget, Bool abOverride = False, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int i = getPerkLevel(akTarget) + 1
  If canTake(akTarget, i, abOverride)
    Float AddAmount
    If i == 1
      AddAmount = 2.5
    ElseIf i == 2
      AddAmount = 5
    ElseIf i == 3
      AddAmount = 10
    ElseIf i == 4
      AddAmount = 15
    ElseIf i == 5
      AddAmount = 20 ;JMap.getFlt(aiTargetData, "SCLStomachBase") * 0.1
    ;/ElseIf i == 6
      AddAmount = JMap.getFlt(aiTargetData, "SCLStomachBase") * 0.2
    ElseIf i == 7
      AddAmount = JMap.getFlt(aiTargetData, "SCLStomachBase") * 0.3
    ElseIf i == 8
      AddAmount = JMap.getFlt(aiTargetData, "SCLStomachBase") * 0.5/;
    EndIf
    JMap.setFlt(aiTargetData, "SCLStomachBase", JMap.getFlt(aiTargetData, "SCLStomachBase") + AddAmount)
    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction
