ScriptName SCVPerkStrokeOfLuck Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Perk Property GoldenTouch Auto
Quest Property TG09 Auto
Function Setup()
  ;/Name = "Stroke of Luck"
  Description = New String[4]
  Description[0] = "Gives a chance that a pred's devour attempt will fail."
  Description[1] = "Gives a 5% chance that a predator's devour attempt will fail."
  Description[2] = "Gives a 10% chance that a predator's devour attempt will fail."
  Description[3] = "Gives a 20% chance that a predator's devour attempt will fail."

  Requirements = New String[4]
  Requirements[0] = "No Requirements"
  Requirements[1] = "Have at least 25 Lockpicking, and avoid being eaten 5 times."
  Requirements[2] = "Have at least 55 Lockpicking, have at least 5 lucky moments, and be very fortunate in finding gold."
  Requirements[3] = "Have at least 60 Lockpicking, have at least 20 lucky moments, and perform your deed to the darkness."/;
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int Lockpicking = akTarget.GetActorValue("Lockpicking") as Int
  If aiPerkLevel == 1 && JMap.getInt(aiTargetData, "SCV_StrokeOfLuckAvoidVore") >= 5 && Lockpicking >= 25
    Return True
  ElseIf aiPerkLevel == 2 && JMap.getInt(aiTargetData, "SCV_StrokeOfLuckActivate") >= 5 && Lockpicking >= 55 && PlayerRef.HasPerk(GoldenTouch)
    Return True
  ElseIf aiPerkLevel == 3 && JMap.getInt(aiTargetData, "SCV_StrokeOfLuckActivate") >= 20 && Lockpicking >= 80 && TG09.IsCompleted()  ;Complete Darkness Returns
    Return True
  EndIf
EndFunction
