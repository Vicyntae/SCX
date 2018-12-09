ScriptName SCVPerkExpectPushback Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Quest Property FreeformRiften19 Auto
Quest Property FreeformRiften09 Auto
Quest Property MQ204 Auto
Spell Property VoiceUnrelentingForce1 Auto
Spell Property VoiceUnrelentingForce2 Auto
Spell Property VoiceUnrelentingForce3 Auto

Function Setup()
  ;/Name = "Expect Pushback"
  Description = New String[4]
  Description[0] = "Knock back enemies back after an enemy's failed devour attempt."
  Description[1] = "Staggers enemies after an enemy's failed devour attempt. Restores stamina."
  Description[2] = "Increases force of knock back. Restores magicka."
  Description[3] = "Increases force of knock back even more. Buffs your attacking power."
  Requirements = New String[4]
  Requirements[0] = "No Requirements"
  Requirements[1] = "Possess the word 'Force', be at level 7, and show your prowess of hand-to-hand combat in Riften."
  Requirements[2] = "Possess the word 'Balance', be at level 15, and a retrieve a woman's prized weapon for her."
  Requirements[3] = "Possess the word 'Push', be at level 25, and meet a true master of the Voice."/;
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  Int Level = akTarget.GetLevel()
  If aiPerkLevel == 1 && PlayerRef.HasSpell(VoiceUnrelentingForce1) && Level >= 7 && FreeformRiften19.IsCompleted()  ;Complete Bloody Nose
    Return True
  ElseIf aiPerkLevel == 2 && PlayerRef.HasSpell(VoiceUnrelentingForce2) && Level >= 15 && FreeformRiften09.IsCompleted() ;Complete Grimsever's Return
    Return True
  ElseIf aiPerkLevel == 2 && PlayerRef.HasSpell(VoiceUnrelentingForce3) && Level >= 25 && MQ204.IsCompleted() ;Complete The Throat of the World
  EndIf
EndFunction

Bool Function showPerk(Actor akTarget)
  Return True
EndFunction
