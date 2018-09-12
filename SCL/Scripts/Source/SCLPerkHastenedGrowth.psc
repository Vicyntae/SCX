ScriptName SCLPerkHastenedGrowth Extends SCX_BasePerk
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
Function Setup()
  Description = New String[4]
  Description[0] = "Increases capacity growth rate."
  Description[1] = "Increases capacity growth rate by 10%."
  Description[2] = "Increases capacity growth rate by 30%."
  Description[3] = "Increases capacity growth rate by 50%."


  Requirements = New String[4]
  Requirements[0] = "No Requirements."
  Requirements[1] = "Experience 10 expansions and be at level 20."
  Requirements[2] = "Experience 30 expansions and be at level 40."
  Requirements[3] = "Experience 50 expansions and be at level 60."

EndFunction

Function reloadMaintenence()
  Setup()
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= AbilityArray.Length - 1
    Return True
  EndIf
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int ExpandNum = JMap.getInt(aiTargetData, "SCLExpandNum")
  Int Level = akTarget.getLevel()
  If aiPerkLevel == 1 && ExpandNum >= 10 && Level >= 20
    Return True
  ElseIf aiPerkLevel == 2 && ExpandNum >= 30 && Level >= 40
    Return True
  ElseIf aiPerkLevel == 3 && ExpandNum >= 50 && Level >= 60
    Return True
  EndIf
  Return False
EndFunction

Bool Function takePerk(Actor akTarget, Bool abOverride = False, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int i = getPerkLevel(akTarget) + 1
  If canTake(akTarget, i, abOverride)
    Float AddAmount
    If i == 1
      AddAmount = 0.1
    ElseIf i == 2
      AddAmount = 0.3
    ElseIf i == 3
      AddAmount = 0.5
    EndIf
    JMap.setFlt(aiTargetData, "SCLExpandBonusMulti", JMap.getFlt(aiTargetData, "SCLExpandBonusMulti", 1) + AddAmount)
    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction
