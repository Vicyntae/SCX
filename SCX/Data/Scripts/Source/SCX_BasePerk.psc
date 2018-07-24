ScriptName SCX_BasePerk Extends SCX_BaseRefAlias Hidden

;Idea: on daily updates, we check the player for any available perks and save them to array. We then put a star next to available perks in menus.

;String Property PerkID Auto
String Property Name Auto
String[] Property Description Auto
String[] Property Requirements Auto
Spell[] Property AbilityArray Auto

String Property PerkGroup Auto
Float[] Property PerkCoords Auto
String[] Property PerkConnections Auto

Int Function _getSCX_JC_List()
  Return SCXSet.JM_PerkIDs
EndFunction

String Function getPerkName(Int aiPerkLevel)
  If aiPerkLevel
    Return AbilityArray[aiPerkLevel].GetName()
  Else
    Return Name
  EndIf
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  Return False
EndFunction

Bool Function takePerk(Actor akTarget, Bool abOverride = False, Int aiTargetData = 0)
  If JValue.isExists(aiTargetData)
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  Int i = getPerkLevel(akTarget) + 1
  If canTake(akTarget, i, abOverride, aiTargetData)
    akTarget.AddSpell(AbilityArray[i], True)
    Return True
  Else
    Notice("Actor ineligible for perk")
    Return False
  EndIf
EndFunction

String Function getDescription(Int aiPerkLevel = 0)
  If aiPerkLevel >= 0 && aiPerkLevel <= Description.Length - 1
    Return Description[aiPerkLevel]
  Else
    Return "Invalid Perk Level"
  EndIf
EndFunction

String Function getRequirements(Int aiPerkLevel = 0)
  If aiPerkLevel >= 0 && aiPerkLevel <= Requirements.Length - 1
    Return Requirements[aiPerkLevel]
  Else
    Return "Invalid Perk Level"
  EndIf
EndFunction

Int Function getPerkLevel(Actor akTarget)
  Int i = AbilityArray.Length
  While i > 1
    i -= 1
    If akTarget.HasSpell(AbilityArray[i])
      Return i
    EndIf
  EndWhile
  Return 0
EndFunction

Bool Function showPerk(Actor akTarget)
  Return True
EndFunction


Function setSelectOptions(SCX_ModConfigMenu MCM, String asValue, Int aiOption)
  Int CurrentPerkValue = getPerkLevel(MCM.SelectedActor)
  If canTake(MCM.SelectedActor, CurrentPerkValue + 1, SCXSet.DebugEnable)
    If MCM.ShowMessage(getDescription(CurrentPerkValue + 1) + "\n Requirements: " + getRequirements(CurrentPerkValue + 1) + "\n Take Perk " + getPerkName(CurrentPerkValue + 1) + "?", True, "Yes", "No")
      takePerk(MCM.SelectedActor, True)
      MCM.ShowMessage("Perk " + getPerkName(CurrentPerkValue + 1) + " taken! Some perk effects will not show until the menu is exited", False, "OK")
      JMap.setInt(MCM.JM_SelectedPerkLevel, GetName(), CurrentPerkValue + 1)
      MCM.ForcePageReset()
    EndIf
  Else
    MCM.ShowMessage(getPerkName(CurrentPerkValue + 1) + ": " + getDescription(CurrentPerkValue + 1) + "\n Requirements: " + getRequirements(CurrentPerkValue + 1), False, "OK")
  EndIf
EndFunction

Function setHighlight(SCX_ModConfigMenu MCM, String asValue, Int aiValue, Int aiOption)
  MCM.SetInfoText(getPerkName(aiValue) + ": " + getDescription(aiValue) + "\n Requirements: " + getRequirements(aiValue))
EndFunction
