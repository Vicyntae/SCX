ScriptName SCLPerkStoredLimitUp Extends SCX_BasePerk
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
;*******************************************************************************
;/Info
;*******************************************************************************

Description: Increases Stomach Storage Capacity by:
  *1
  *1
  *3
  *3
  *5
;*******************************************************************************
Requirements: Have a base capacity of :
  *25
  *50
  *75
  *115
  *150
;*******************************************************************************
/;

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  Int TargetData = SCLib.getData(akTarget, aiTargetData)
  Int Req
  If aiPerkLevel == 1
    Req = 25
  ElseIf aiPerkLevel == 2
    Req == 50
  ElseIf aiPerkLevel == 3
    Req = 75
  ElseIf aiPerkLevel == 4
    Req = 115
  ElseIf aiPerkLevel == 5
    Req = 150
  EndIf
  If aiPerkLevel <= 5 && (abOverride || JMap.getFlt(TargetData, "SCLStomachBase") >= Req)
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
    Int AddAmount
    If i == 1
      AddAmount = 1
    ElseIf i == 2
      AddAmount = 2
    ElseIf i == 3
      AddAmount = 3
    ElseIf i == 4
      AddAmount = 3
    ElseIf i == 5
      AddAmount = 5
    EndIf
    JMap.setInt(aiTargetData, "SCLStomachStorage", JMap.getInt(aiTargetData, "SCLStomachStorage") + AddAmount)
    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction
