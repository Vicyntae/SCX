ScriptName SCVPerkDaedraDieter Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Quest Property DA01 Auto
Quest Property DA10 Auto
Quest Property DA07 Auto

Function Setup()
  ;/Name = "Daedra Dieter"
  Description = New String[4]
  Description[0] = "Allows you to eat daedra."
  Description[1] = "Allows you to eat daedra."
  Description[2] = "Increases chances of devouring daedra by 5%."
  Description[3] = "Increases chances of success in devouring daedra by another 5% and gives a chance of acquiring bonus items from them."
  Requirements = New String[4]
  Requirements[0] = "No Requirements"
  Requirements[1] = "Have at least 25 Conjuration Skill, be at level 10, and perform a task for the Prince of Dawn and Dusk."
  Requirements[2] = "Have at least 40 Conjuration Skill, be at level 20, consume 20 daedric enemies, and investigate the cursed stone home."
  Requirements[3] = "Have at least 60 Conjuration Skill, be at level 30, consume 50 daedric enemies, and reassemble a terrible weapon."/;
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  If SCVLib.isPred(akTarget)
    Float Conjure = akTarget.GetActorValue("Conjuration")
    Int Level = akTarget.GetLevel()
    Int NumEatenPrey = JMap.getInt(aiTargetData, "SCV_NumDaedraEaten")
    If aiPerkLevel == 1 && Conjure >= 25 && Level >= 10 && (DA01.IsCompleted());Complete The Black Star
      Return True
    ElseIf aiPerkLevel == 2 && Conjure >= 40 && Level >= 20 && NumEatenPrey >= 20 && (DA10.IsCompleted());Complete The House of Horrors
      Return True
    ElseIf aiPerkLevel == 3 && Conjure >= 60 && Level >= 30 && NumEatenPrey >= 50 && (DA07.IsCompleted()) ;Complete Pieces of the Past
      Return True
    EndIf
  EndIf
  Return False
EndFunction

Bool Function showPerk(Actor akTarget)
  If SCVLib.isPred(PlayerRef)
    Return True
  Else
    Return False
  EndIf
EndFunction
