ScriptName SCVSpell Extends ActiveMagicEffect
SCX_Library Property SCXLib Auto
SCVLibrary Property SCVLib Auto
SCX_Settings Property SCXSet Auto
SCVSettings Property SCVSet Auto
Bool EnableDebugMessages = True
String Property Setting_VoreType Auto
String[] Property Setting_TagList Auto
Bool Property Setting_AllAtOnce Auto
Bool Property Setting_Lethal Auto
Race Property WolfRace Auto

SCX_BasePerk Property SCV_FollowerofNamira Auto
Keyword Property ActorTypeNPC Auto

SCX_BasePerk Property SCV_MetalMuncher Auto
Keyword Property ActorTypeDwarven Auto

SCX_BasePerk Property SCV_DragonDevourer Auto
Keyword Property ActorTypeDragon Auto

SCX_BasePerk Property SCV_SpiritSwallower Auto
Keyword Property ActorTypeGhost Auto

SCX_BasePerk Property SCV_DaedraDieter Auto
Keyword Property ActorTypeDaedra Auto

SCX_BasePerk Property SCV_ExpiredEpicurian Auto
Keyword Property ActorTypeUndead Auto

Actor Property PlayerRef Auto
String Property DebugName
  String Function Get()
    Return "[SCV VoreSpell "+ GetTargetActor().GetLeveledActorBase().GetName() + "] "
  EndFunction
EndProperty

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Notice("Spell cast! Target = " + akTarget.GetLeveledActorBase().GetName() + ", Caster = " + akCaster.GetLeveledActorBase().GetName())

  If !checkEnabledActors(akCaster, akTarget)
    Return
  EndIf

  Bool FirstPrey
  Int PredData = SCXLib.getTargetData(akCaster)
  Int JF_PreyList = JMap.getObj(PredData, "SCV_AffectedPreyList")
  If !JF_PreyList
    FirstPrey = True
    JF_PreyList = JFormMap.object()
    JMap.setObj(JF_PreyList, "SCV_AffectedPreyList", JF_PreyList)
  Else
    Int NumPrey = JMap.getInt(PredData, "SCV_AffectedPreyQueue") + 1
    JMap.setInt(PredData, "SCV_AffectedPreyQueue", NumPrey)
  EndIf

  Bool Success = False
  If !canVore(akCaster, akTarget)
    Notice("Caster " + akCaster.GetLeveledActorBase().GetName() + " can't devour this prey!")
  Else
    Float Chance = calculateChance(akCaster, akTarget)
    Success = Chance >= Utility.RandomFloat()
  EndIf

  Int JM_PreyProfile = createPreyProfile(akCaster, akTarget, Success)
  JFormMap.setObj(JF_PreyList, akTarget, JM_PreyProfile)

  If FirstPrey
    ;Utility.Wait(0.1)
    Int i
    While JMap.getInt(PredData, "SCV_AffectedPreyQueue") > 0 && i < 50
      Utility.Wait(0.01)
      i += 1
    EndWhile
  Else
    JMap.setInt(PredData, "SCV_AffectedPreyQueue", JMap.getInt(PredData, "SCV_AffectedPreyQueue") - 1)
    Return
  EndIf

  JMap.removeKey(PredData, "SCV_AffectedPreyList")
  JMap.removeKey(PredData, "SCV_AffectedPreyQueue")

  sendPreyList(akCaster, JF_PreyList)
EndEvent

Bool Function checkEnabledActors(Actor akPred, Actor akPrey)
  If akPred != PlayerRef
    If akPred.GetLeveledActorBase().GetSex() == 0
      If (!SCVSet.EnableMTeamPreds && akPred.IsPlayerTeammate()) || (!SCVSet.EnableMPreds)
        Notice("Failed. Pred gender (M) has been disabled")
        Return False
      EndIf
    Else
      If (!SCVSet.EnableFTeamPreds && akPred.IsPlayerTeammate()) || (!SCVSet.EnableFPreds)
        Notice("Failed. Pred gender (F) has been disabled")
        Return False
      EndIf
    EndIf
  EndIf

  If Setting_VoreType == "Oral" && !SCVLib.isOVPred(akPred)
    SCVLib.PlayerThought(akPred, "I can't eat them. I'm not an oral predator!", "You can't eat them! You're not an oral predator!", akPred.GetLeveledActorBase().GetName() + " can't eat them! They're not an oral predator!")
    Return False
  ElseIf Setting_VoreType == "Anal" && !SCVLib.isAVPred(akPred)
    SCVLib.PlayerThought(akPred, "I can't eat them. I'm not an anal predator!", "You can't eat them! You're not an anal predator!", akPred.GetLeveledActorBase().GetName() + " can't eat them! They're not an anal predator!")
    Return False
  ElseIf Setting_VoreType == "Unbirth" && !SCVLib.isUVPred(akPred)
    SCVLib.PlayerThought(akPred, "I can't eat them. I'm not an unbirthing predator!", "You can't eat them! You're not an unbirthing predator!", akPred.GetLeveledActorBase().GetName() + " can't eat them! They're not an unbirthing predator!")
    Return False
  ElseIf Setting_VoreType == "Cock" && !SCVLib.isCVPred(akPred)
    SCVLib.PlayerThought(akPred, "I can't eat them. I'm not an cock predator!", "You can't eat them! You're not an cock predator!", akPred.GetLeveledActorBase().GetName() + " can't eat them! They're not an cock predator!")
    Return False
  EndIf

  If akPrey.IsEssential()
    If akPred == PlayerRef
      If !SCVSet.EnablePlayerEssentialVore
        Notice("Failed. Player has been restricted from eating essential NPCs")
        Return False
      EndIf
    ElseIf !SCVSet.EnableEssentialVore
      Notice("Failed. Actors have been restricted from eating essential NPCs")
      Return False
    EndIf
  EndIf
  Return True
EndFunction

Function sendPreyList(Actor akPred, Int JF_PreyList)
  Int JA_TagList = JArray.objectWithStrings(Setting_TagList)
  Int Handle = ModEvent.Create("SCVPreyGather")
  ModEvent.PushForm(Handle, akPred)
  ModEvent.PushInt(Handle, JF_PreyList)
  ModEvent.PushBool(Handle, Setting_AllAtOnce)
  ModEvent.PushInt(Handle, JA_TagList)
  ModEvent.Send(Handle)
EndFunction

Int Function createPreyProfile(Actor akPred, Actor akPrey, Bool abSuccess)
  Int JM_PreyProfile = JMap.object()

  Float PredScale = akPred.GetScale() * NetImmerse.GetNodeScale(akPred, "NPC Root [Root]", False)
  Float PreyScale = akPrey.GetScale() * NetImmerse.GetNodeScale(akPrey, "NPC Root [Root]", False)
  Float FinalScale = PredScale / PreyScale
  JMap.setInt(JM_PreyProfile, "Success", abSuccess as Int)
  JMap.setInt(JM_PreyProfile, "Lethal", Setting_Lethal as Int)
  JMap.setFlt(JM_PreyProfile, "SizeRatio", FinalScale)
  JMap.setFlt(JM_PreyProfile, "Distance", akPrey.GetDistance(akPred))
  JMap.setStr(JM_PreyProfile, "RaceString", getRaceString(akPrey))
  JMap.setStr(JM_PreyProfile, "VoreType", Setting_VoreType)
  Bool Dead = akPrey.IsDead() || akPrey.IsUnconscious() || akPrey.GetSleepState() == 3
  JMap.setInt(JM_PreyProfile, "Incapacitated", Dead as Int)
  ;Notice("Generating Profile: Success=" + abSuccess + ", VoreType=" + Setting_VoreType + ", RaceString=" + getRaceString(akPrey) + ", Size=" + FinalScale + ", Distance=" + akPrey.GetDistance(akPred))
  Return JM_PreyProfile
EndFunction

Float Function calculateChance(Actor Pred, Actor Prey)
  Int PredData = SCXLib.getTargetData(Pred)
  Int PreyData = SCXLib.getTargetData(Prey)
  String PredName = SCVLib.nameGet(Pred)
  String PreyName = SCVLib.nameGet(Prey)
  Float Chance

  If Prey.IsDead() || Prey.IsUnconscious() || Prey.GetSleepState() == 3
    Chance = 1
  Else
    Int PredSkill = SCVLib.getVoreLevelTotal(Pred, Setting_VoreType, PredData)
    Int PreySkill = SCVLib.getVoreLevelTotal(Prey, "Resistance", PreyData)
    Float PredHealthPercent = Pred.GetActorValuePercentage("Health")
    Float PreyHealthPercent = Prey.GetActorValuePercentage("Health")
    PredHealthPercent *= 1 + (PredSkill / 10)
    PreyHealthPercent *= 1 + (PreySkill / 10)

    ;Chance = SCVLib.clampFlt(PredHealthPercent - PreyHealthPercent, 0, 1)
    Chance = 1
    Chance *= 1 + (GetMagnitude() / 100)
  EndIf
  ;Notice("Initial Generated chance = " + Chance)

  Int LuckPerk = JMap.getInt(PredData, "SCV_StrokeOfLuck")
  If LuckPerk > 0
    Float LuckChance = Utility.RandomFloat()
    ;Notice("Luck Perk = " + LuckPerk + ", Chance = " + LuckChance)
    Float LuckSuccess = LuckPerk / 100
    If LuckChance < LuckSuccess
    ;If (LuckPerk == 1 && LuckChance < 10) || (LuckPerk == 2 && LuckChance < 20) || (LuckPerk == 3 && LuckChance < 30)
      Notice("Stroke of Luck success. Returning 0")
      JMap.setInt(PreyData, "SCV_StrokeOfLuckActivate", JMap.getInt(PreyData, "SCV_StrokeOfLuckActivate") + 1)
      ;Play noise here
      SCVLib.PlayerThought(Prey, "A stroke of luck!")
      Return 0
    EndIf
  EndIf

  ;Stalker Perk
  If Pred.IsSneaking() && !Pred.IsDetectedBy(Prey)
    Int StealthPerk = JMap.getInt(PredData, "SCV_Stalker")
    Notice("Stealth perk valid. Perk level = " + StealthPerk)
    If StealthPerk
      Chance *= (1 + (StealthPerk/100))
    EndIf
  EndIf

  If Prey.IsBleedingOut()
    Notice("Prey is bleeding out. Chance set to 1")
    Chance = 1
  EndIf

  ;HungerPerks
  Int Hunger = JMap.getInt(PredData, "SCV_IntenseHunger")
  If Hunger
    Notice("Hunger perk valid. Perk level = " + Hunger)
    Chance *= (1 + (Hunger / 100))
  EndIf

  Race PreyRace = Prey.GetRace()

  If PreyRace.HasKeyword(ActorTypeDragon)
    Int TruePerkRank = SCV_DragonDevourer.getPerkLevel(Pred)
    Int PerkRank = JMap.getInt(PredData, "SCV_DragonBonusVoreMult")
    If TruePerkRank < 1
      Notice("Actor Type Dragon. Perk not taken. Returning 0")
      Notice(PreyName + " is a Dragon! " + PredName + " does not have perk! Returning 0")
      SCVLib.PlayerThought(Pred, "That's a bloody dragon! I can't even imagine eating that!", "That's a dragon! How could you even think about eating that!?", "That's a dragon! " + PredName + " can't eat that!")
      Return 0
    ElseIf PerkRank
      Chance *= 1 + (PerkRank / 100)
    EndIf
  ElseIf PreyRace.HasKeyword(ActorTypeGhost)
    Int TruePerkRank = SCV_SpiritSwallower.getPerkLevel(Pred)
    Int PerkRank = JMap.getInt(PredData, "SCV_GhostBonusVoreMult")
    If TruePerkRank < 1
      Notice("Actor Type Ghost. Perk not taken. Returning 0")
      Notice(PreyName + " is a Ghost! " + PredName + " does not have perk! Returning 0")
      SCVLib.PlayerThought(Pred, "By the gods, I can't eat a ghost! What was I thinking!?", "You fail to grab hold of the ghost, because there's nothing there.", PredName + " can't hold the ghost!")
      Return 0
    ElseIf PerkRank
      Chance *= 1 + (PerkRank / 100)
    EndIf
  ElseIf PreyRace.HasKeyword(ActorTypeDwarven)
    Int TruePerkRank = SCV_MetalMuncher.getPerkLevel(Pred)
    Int PerkRank = JMap.getInt(PredData, "SCV_DwemerBonusVoreMult")
    If TruePerkRank < 1
      Notice("Actor Type Dwarven. Perk not taken. Returning 0")
      Notice(PreyName + " is automaton! " + PredName + " does not have perk! Returning 0")
      SCVLib.PlayerThought(Pred, "It's made of metal! I can't eat that!", "It's made of metal! You can't eat that!", "It's made of metal! " + PredName +" can't eat that!")
      Return 0
    ElseIf PerkRank
      Chance *= 1 + (PerkRank / 100)
    EndIf
  ElseIf PreyRace.HasKeyword(ActorTypeDaedra)
    Int TruePerkRank = SCV_DaedraDieter.getPerkLevel(Pred)
    Float PerkRank = JMap.getFlt(PredData, "SCV_DaedraBonusVoreMult")
    If TruePerkRank < 1
      Notice("Actor Type Daedra. Perk not taken. Returning 0")
      Notice(PreyName + " is Daedra! " + PredName + " does not have perk! Returning 0")
      SCVLib.PlayerThought(Pred, "It's a daedra! I can't eat that!", "You don't have the nerve to try and eat the daedra", PredName + " couldn't overpower the daedra")
      Return  0
    ElseIf PerkRank
      Chance *= 1 + (PerkRank / 100)
    EndIf
  ElseIf PreyRace.HasKeyword(ActorTypeNPC)
    Int TruePerkRank = SCV_FollowerofNamira.getPerkLevel(Pred)
    Int PerkRank = JMap.getInt(PredData, "SCV_HumanBonusVoreMult")
    If TruePerkRank < 1
      Notice("Actor Type NPC. Perk not taken. Returning 0")
      SCVLib.PlayerThought(Pred, "They're human! I can't eat them!", "They're human! You can't eat them!", "They're human! " + PredName + " can't eat them!")
      Return 0
    ElseIf PerkRank
      Chance *= 1 + (PerkRank / 100)
    EndIf
  ElseIf PreyRace.HasKeyword(ActorTypeUndead)
    Int TruePerkRank = SCV_ExpiredEpicurian.getPerkLevel(Pred)
    Int PerkRank = JMap.getInt(PredData, "SCV_UndeadBonusVoreMult")
    If TruePerkRank < 1
      Notice("Actor Type Undead. Perk not taken. Returning 0")
      Notice(PreyName + " is Undead! " + PredName + " does not have perk! Returning 0")
      SCVLib.PlayerThought(Pred, "It's bones and dust! I don't want to eat that!", "You most certainly don't want to eat that.", PredName + "recoils at the thought of eating dusty bones.")
      Return 0
    ElseIf PerkRank
      Chance *= 1 + (PerkRank / 100)
    EndIf
  EndIf

  Return Chance
EndFunction

String Function getRaceString(Actor akTarget)
  Race akRace = akTarget.GetRace()
  If akRace.HasKeyword(SCXSet.ActorTypeNPC)
    Return "Human"
  ElseIf akRace == WolfRace
    Return "Wolf"
  Else
    Return ""
  EndIf
EndFunction

Bool Function canVore(Actor akPred, Actor akPrey)
  If Setting_VoreType == "Oral"
    If SCVSet.SCL_Installed
      SCLibrary SCLib = JMap.getForm(SCXSet.JM_BaseLibraryList, "SCL_Library") as SCLibrary
      Int PredData = SCXLib.getTargetData(akPred)
      Float DigestValue = SCXLib.genWeightValue(akPrey, True) ;Can we calculate this later and perform a fail animation instead?
      Float Fullness = JMap.getFlt(PredData, "STFullness")
      Float Max = SCLib.getMaxCap(akPred, PredData)

      If (Fullness + DigestValue > Max)
        Notice("Failed. Pred cannot fit prey.")
        SCXLib.PlayerThoughtDB(akPred, "SCVPredCantEatFull")
        Return False
      Else
        Return True
      EndIf
    Else
      Return True
    EndIf
  ElseIf Setting_VoreType == "Anal"
    Return True
  EndIf
  Return False
EndFunction
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Debug Functions
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Popup(String sMessage)
  {Shows MessageBox, then waits for menu to be closed before continuing}
  Debug.MessageBox(DebugName + sMessage)
  Halt()
EndFunction

Function Halt()
  {Wait for menu to be closed before continuing}
  While Utility.IsInMenuMode()
    Utility.Wait(0.5)
  EndWhile
EndFunction

Function Note(String sMessage)
  Debug.Notification(DebugName + sMessage)
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Notice(String sMessage)
  {Displays message in notifications and logs if globals are active}
  If EnableDebugMessages
    Debug.Notification(DebugName + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Issue(String sMessage, Int iSeverity = 0, Bool bOverride = False)
  {Displays a serious message in notifications and logs if globals are active
  Use bOverride to ignore globals}
  If bOverride || EnableDebugMessages
    String Level
    If iSeverity == 0
      Level = "Info"
    ElseIf iSeverity == 1
      Level = "Warning"
    ElseIf iSeverity == 2
      Level = "Error"
    EndIf
    Debug.Notification(DebugName + Level + " " + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage, iSeverity)
EndFunction
