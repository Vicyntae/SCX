ScriptName SCNLibrary Extends SCX_BaseLibrary

;******************************************************************************
;AutoEat Functions
;*******************************************************************************
Float Function actorEat(Actor akTarget, Int aiType = 0, Float afDelay = 0.0, Bool abDisplayAnim = False)
  If !akTarget
    Return 0
  EndIf
  Int Future = SCLSet.ActorEatThreadManager.actorEatAsync(akTarget, aiType, afDelay, abDisplayAnim)
  Return SCLSet.ActorEatThreadManager.get_result(Future)
EndFunction

Int Function getGlutValue(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCLGluttony")
EndFunction

Int Function getInsobValue(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getInt(TargetData, "SCLInsobriety")
EndFunction

Float Function genMealValue(Int aiSeverity = -1, Actor akTarget = None, Int aiType, Int aiTargetData = 0)
  {Generates meal value based on gluttony value and ai type}
  Int Severity
  If aiSeverity > 0
    Severity = aiSeverity
  ElseIf akTarget
    Severity = getGlutValue(akTarget, aiTargetData)
  Else
    Return 0
  EndIf

  If Severity <= 0
    Return 0
  ElseIf aiType > 0
    Return Math.pow(0.05 * Severity, 1.8) * Math.Pow(1.1 * aiType, 2)
  ElseIf aiType < 0
    aiType = Math.floor(Math.abs(aiType))
    Return Math.pow(0.05 * Severity, 1.8) * Math.Pow(1.1 * aiType, 2)
  EndIf
EndFunction

;/Gluttony a rising value starting at 0 (no desire to eat) and escalating upwards
Meal values should increase exponentially
Base value should result in light snacks == 0.3, meals == 1, Full meals == 2
Time should decrease as Gluttony rises/;
Float Function getGlutMin(Int aiGlutValue = -1, Actor akTarget = None, Int aiTargetData = 0)
  Int Gluttony
  If aiGlutValue > 0
    Gluttony = aiGlutValue
  ElseIf akTarget
    Gluttony = getGlutValue(akTarget, aiTargetData)
  Else
    Return 0
  EndIf
  If Gluttony > 50
    Return Math.pow(Gluttony - 50, 1.2)
  Else
    Return -1
  EndIf
EndFunction

Float Function getGlutTime(Int aiGlutValue = -1, Actor akTarget = None, Int aiTargetData = 0)
  Int Gluttony
  If aiGlutValue > 0
    Gluttony = aiGlutValue
  ElseIf akTarget
    Gluttony = getGlutValue(akTarget, aiTargetData)
  Else
    Return 0
  EndIf
  If Gluttony <= 0
    Return -1
  Else
    Return Math.pow(0.9, Gluttony/3) * 1000
  EndIf
EndFunction

Float Function getPriceFactor(Actor akTarget)
  Float Speech = akTarget.GetActorValue("Speechcraft")
  Float BaseFactor = (3.3 * (100 - Speech) + 2 * Speech) / 100
  Float Haggle
  If akTarget.HasPerk(SCLSet.Haggling80)
    Haggle = 0.77
  ElseIf akTarget.HasPerk(SCLSet.Haggling60)
    Haggle = 0.8
  ElseIf akTarget.HasPerk(SCLSet.Haggling40)
    Haggle = 0.83
  ElseIf akTarget.HasPerk(SCLSet.Haggling20)
    Haggle = 0.87
  ElseIf akTarget.HasPerk(SCLSet.Haggling00)
    Haggle = 0.91
  Else
    Haggle = 1
  EndIf
  Float Allure = 1
  If akTarget.HasPerk(SCLSet.Allure)
    Bool AllureChance = Utility.RandomInt(0, 1)
    If AllureChance
      Allure = 0.91
    EndIf
  EndIf

  Float BuyModifier = Haggle * Allure
  Return BuyModifier / BaseFactor
EndFunction
