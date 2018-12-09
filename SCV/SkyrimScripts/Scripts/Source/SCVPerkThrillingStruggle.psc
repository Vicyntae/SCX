ScriptName SCVPerkThrillingStruggle Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Quest Property MS02 Auto ;Complete No One Escapes Cidhna Mine
Quest Property MS07 Auto ;Complete Lights Out!
Function Setup()
  Name = "Thrilling Struggle"
  Description = New String[4]
  Description[0] = "Increases stamina/magicka damage done to one's predator."
  Description[1] = "Increases stamina/magicka damage done to one's predator slightly."
  Description[2] = "Increases stamina/magicka damage done to one's predator moderately."
  Description[3] = "Increases stamina/magicka damage done to one's predator significantly."
  Requirements = New String[4]
  Requirements[0] = "No Requirements"
  Requirements[1] = "Have at least 250 points of energy and a resistance skill of at least 20."
  Requirements[2] = "Have at least 350 points of energy, a resistance skill of at least 40, and escape a wrongful imprisonment."
  Requirements[3] = "Have at least 700 points of energy, a resistance skill of at least 60, and cause an incident at sea."
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  Int TargetData = SCVLib.getData(akTarget, aiTargetData)
  Int Resist = SCVLib.getVoreLevel(akTarget, "Resistance", TargetData)
  Float Energy = SCVLib.getPreyEnergy(akTarget)
  If aiPerkLevel == 1 && Energy >= 250 && Resist >= 20
    Return True
  ElseIf aiPerkLevel == 1 && Energy >= 350 && Resist >= 40 && (MS02.IsCompleted())  ;Complete No One Escapes Cidhna Mine
    Return True
  ElseIf aiPerkLevel == 3 && Energy >= 700 && Resist >= 60 && MS07.IsCompleted() ;Complete Lights Out!
    Return True
  EndIf
EndFunction

Bool Function showPerk(Actor akTarget)
  Return True
EndFunction
