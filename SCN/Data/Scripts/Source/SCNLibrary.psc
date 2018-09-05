ScriptName SCNLibrary Extends SCX_BaseLibrary

SCX_ModConfigMenu Property MCM Auto
SCNSettings Property SCNSet Auto

Int ScriptVersion = 0
Int Function checkVersion(Int aiStoredVersion)
  If MCM.Pages.find("$SCNMCMSettingsPage") == -1
    MCM.Pages = PapyrusUtil.PushString(MCM.Pages, "$SCNMCMSettingsPage")
  EndIf
  Utility.Wait(1)
  SCX_BaseLibrary SCLib = JMap.getForm(SCXSet.JM_BaseLibraryList, "SCL_Library") as SCX_BaseLibrary
  If SCLib
    SCNSet.SCL_Installed = True
  EndIf
  If ScriptVersion >= 1 && aiStoredVersion < 1
  EndIf

  Return ScriptVersion
EndFunction

Function monitorSetup(SCX_Monitor akMonitor, Actor akTarget)
  Note("Running monitor setup...")
  akTarget.AddSpell(SCNSet.SCN_CalorieUseTracker, True)
EndFunction


Float Function expendCalories(Actor akTarget, Float afValue)
  Int TargetData = getTargetData(akTarget)
  Int Weight = JMap.getInt(TargetData, "SCNWeightValue")
  Float Multi = 1 + (Weight / 100)
  Float Modify = JMap.getFlt(TargetData, "SCNCalorieBurnModify", 100) / 100
  Float Burned = Weight * Multi * SCNSet.GlobalCalorieUseMulti * Modify
  JMap.setFlt(TargetData, "SCNCurrentCalories", JMap.getFlt(TargetData, "SCNCurrentCalories") - Burned)
  Return Burned
EndFunction

Float Function addCalories(Actor akTarget, Float afValue)
  Int TargetData = getTargetData(akTarget)
  Float Gained = afValue * SCNSet.GlobalCalorieGainMulti
  JMap.setFlt(TargetData, "SCNCurrentCalories", JMap.getFlt(TargetData, "SCNCurrentCalories") + Gained)
EndFunction

Function updateWellness(Actor akTarget, Int aiTargetData)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf

  Float Calories = JMap.getFlt(aiTargetData, "SCNCurrentCalories")
  JMap.setFlt(aiTargetData, "SCNStoredCalories", JMap.getFlt(aiTargetData, "SCNStoredCalories") + Calories)

  If Calories < 0
    Int Malnourish = Math.Floor(Math.abs(Calories / 1000))
    If Malnourish
      (SCNSet.SCN_MalnourishSpellList.GetAt(Malnourish) as Spell).cast(akTarget)
    EndIf
  EndIf
  JMap.setFlt(aiTargetData, "SCNCurrentCalories", 0)

  Float Slept = JMap.getFlt(aiTargetData, "SCNTimeSlept")
  Int Tired = JMap.getInt(aiTargetData, "SCNTiredDamage")
  If Slept < 6
    Tired += 1
  Else
    Tired -= 3
  EndIf
  If Tired < 0
    Tired = 0
  EndIf
  (SCNSet.SCN_TiredSpellList.GetAt(Tired) as Spell).cast(akTarget)
  JMap.setInt(aiTargetData, "SCNTiredDamage", Tired)

EndFunction

Int Function addHungerDamage(Actor akTarget, Int aiTargetData = 0)
  Int Hunger = JMap.getInt(aiTargetData, "SCNHungerDamage")
  Hunger += 1
  (SCNSet.SCN_HungerDamageList.GetAt(Hunger) as Spell).Cast(akTarget)
  JMap.setInt(aiTargetData, "SCNHungerDamage", Hunger)
  Return Hunger
EndFunction

Function removeHungerDamage(Actor akTarget, Int aiTargetData = 0)
  (SCNSet.SCN_HungerDamageList.GetAt(0) as Spell).Cast(akTarget)
  JMap.setint(aiTargetData, "SCNHungerDamage", 0)
EndFunction
;******************************************************************************
;AutoEat Functions
;*******************************************************************************
;/Float Function actorEat(Actor akTarget, Int aiType = 0, Float afDelay = 0.0, Bool abDisplayAnim = False)
  If !akTarget
    Return 0
  EndIf
  ;Int Future = SCLSet.ActorEatThreadManager.actorEatAsync(akTarget, aiType, afDelay, abDisplayAnim)
  ;Return SCLSet.ActorEatThreadManager.get_result(Future)
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
;/Float Function getGlutMin(Int aiGlutValue = -1, Actor akTarget = None, Int aiTargetData = 0)
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
EndFunction/;
