ScriptName SCLPerkHeavyBurden Extends SCX_BasePerk
MagicEffect Property SCL_HeavyBurdenReqTrackerEffect Auto ;goes on a spell attached to reference alias, conditioned to recognize heavy effects
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
Function Setup()
  Name = "Heavy Burden"
  Description = New String[6]
  Description[0] = "Allows actor to move freely when their weight is high."
  Description[1] = "Allows actor to move freely when their weight exceeds " + (100 * (1 + 1)) + "."
  Description[2] = "Allows actor to move freely when their weight exceeds " + (100 * (2 + 1)) + "."
  Description[3] = "Allows actor to move freely when their weight exceeds " + (100 * (3 + 1)) + "."
  Description[4] = "Allows actor to move freely when their weight exceeds " + (100 * (4 + 1)) + "."
  Description[5] = "Allows actor to move freely when their weight exceeds " + (100 * (5 + 1)) + "."

  Requirements = New String[6]
  Requirements[0] = "No Requirements."
  Requirements[1] = "Have " + (150 * (1 + 1)) + " units in your stomach at some point and reach level " + (150 * (1 + 1)) / 10 + "."
  Requirements[2] = "Have " + (150 * (2 + 1)) + " units in your stomach at some point and reach level " + (150 * (2 + 1)) / 10 + "."
  Requirements[3] = "Have " + (150 * (3 + 1)) + " units in your stomach at some point and reach level " + (150 * (3 + 1)) / 10 + "."
  Requirements[4] = "Have " + (150 * (4 + 1)) + " units in your stomach at some point and reach level " + (150 * (4 + 1)) / 10 + "."
  Requirements[5] = "Have " + (150 * (5 + 1)) + " units in your stomach at some point and reach level " + (150 * (5 + 1)) / 10 + "."
EndFunction

Function reloadMaintenence()
  Setup()
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel < AbilityArray.Length
    Return True
  EndIf
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int MaxWeight = 150 * (aiPerkLevel + 1)
  Int Level = akTarget.GetLevel()
  If aiPerkLevel <= 5 && JMap.getInt(aiTargetData, "SCLHeavyBurdenTracker") == 1 && Level >= MaxWeight / 10
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
    JMap.setFlt(aiTargetData, "SCLHeavyBurden", JMap.getFlt(aiTargetData, "SCLHeavyBurden") + 1)
    JMap.setInt(aiTargetData, "SCLHeavyBurdenTracker", 0)

    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction
