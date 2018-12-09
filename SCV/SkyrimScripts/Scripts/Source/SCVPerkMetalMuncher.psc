ScriptName SCVPerkMetalMuncher Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Quest Property MS04Reward Auto
Quest Property MG06 Auto
Quest Property DA04 Auto
Function Setup()
  ;/Name = "Metal Muncher"
  Description = New String[4]
  Description[0] = "Allows you to eat Dwemer Automatons."
  Description[1] = "Allows you to eat Dwemer Automatons."
  Description[2] = "Increases chances of success in devouring Dwemer Automatons by 5% and gives a chance of acquiring bonus items from them."
  Description[3] = "Increases chances of success in devouring Dwemer Automatons by 10%."

  Requirements = New String[4]
  Requirements[0] = "No Requirements"
  Requirements[1] = "Have a digestion rate of at least 2, be at level 15, and possess the knowledge of the ancient Dwemer."
  Requirements[2] = "Have a digestion rate of at least 5, be at level 25, consume 30 Dwemer Automatons, and discover the secret of the Dwemer Oculory."
  Requirements[3] = "Have a digestion rate of at least 8, be at level 30, consume 60 Dwemer Automatons, and unlock the container with the heart of a god."/;
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  If SCVLib.isPred(akTarget)
    Float DigestRate = JMap.getFlt(aiTargetData, "STDigestionRate")
    Int Level = akTarget.GetLevel()
    Int NumEatenPrey = JMap.getInt(aiTargetData, "SCV_NumDwarvenEaten")
    If aiPerkLevel == 1 && DigestRate >= 2 && Level >= 15 && PlayerRef.HasSpell(MS04Reward) ;Complete quest Unfathomable Depths
      Return True
    ElseIf aiPerkLevel == 2 && DigestRate >= 5 && Level >= 25 && NumEatenPrey >= 30 && MG06.IsCompleted() ;Complete Quest Revealing the Unseen
      Return True
    ElseIf aiPerkLevel == 3 && DigestRate >= 8 && Level >= 30 && NumEatenPrey >= 60 && (DA04.IsCompleted())  ;Complete (or fail) Quest Discerning the Transmundane
      Return True
    EndIf
  EndIf
EndFunction

Bool Function showPerk(Actor akTarget)
  If SCVLib.isPred(PlayerRef)
    Return True
  Else
    Return False
  EndIf
EndFunction
