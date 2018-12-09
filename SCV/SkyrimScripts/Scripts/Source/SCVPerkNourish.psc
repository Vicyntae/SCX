ScriptName SCVPerkNourish Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Quest Property MS14Quest Auto
Quest Property Favor109 Auto
Quest Property FreeformFalkreathQuest03B Auto
;/Function Setup()
  Name = "Nourishment"
  Description =  New String[4]
  Description[0] = "Gives health regeneration when one has digesting prey."
  Description[1] = "Gives slight health regeneration when one has digesting prey."
  Description[2] = "Gives slight health and stamina regeneration when one has digesting prey."
  Description[3] = "Gives slight health, stamina, and magicka regeneration when one has digesting prey."
  Requirements =  New String[4]
  Requirements[0] = "No Requirements"
  Requirements[1] = "Have at least 20 Light Armor, have at least 200 Magicka, and discover the cause of a tragic fire."
  Requirements[2] = "Have at least 40 Light Armor, have at least 300 Magicka, and assist the wizard of the Blue Palace."
  Requirements[3] = "Have at least 60 Light Armor, have at least 400 Magicka and put an end to a sealed evil in Falkreath."
EndFunction/;

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  Int ArmorLevel = akTarget.GetActorValue("LightArmor") as Int
  Int Magicka = akTarget.GetActorValue("Magicka") as Int
  If aiPerkLevel == 1 && ArmorLevel >= 20 && Magicka >= 200 && MS14Quest.IsCompleted()  ;Complete Laid to Rest
    Return True
  ElseIf aiPerkLevel == 2 && ArmorLevel >= 40 && Magicka >= 300 && Favor109.IsCompleted()  ;Complete Kill the Vampire
    Return True
  ElseIf aiPerkLevel == 3 && ArmorLevel >= 60 && Magicka >= 400 && FreeformFalkreathQuest03B.IsCompleted()  ;Complete Dark Ancestor
    Return True
  EndIf
EndFunction

Bool Function showPerk(Actor akTarget)
  If SCVLib.isOVPred(PlayerRef)
    Return True
  Else
    Return False
  EndIf
EndFunction

Bool Function takePerk(Actor akTarget, Bool abOverride = False, Int aiTargetData = 0)
  If !JValue.isExists(aiTargetData)
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  Int i = getPerkLevel(akTarget) + 1
  If canTake(akTarget, i, abOverride, aiTargetData)
    If JMap.getFlt(aiTargetData, "SCVNourishLevel") < 1
      JMap.setFlt(aiTargetData, "SCVNourishLevel", 1)
    EndIf
    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction
