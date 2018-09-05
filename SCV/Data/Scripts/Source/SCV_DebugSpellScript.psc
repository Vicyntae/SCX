ScriptName SCV_DebugSpellScript Extends ActiveMagicEffect

Spell Property OralLethalVore Auto
Spell Property OralNonLethalVore Auto
Spell Property AnalLethalVore Auto
Spell Property AnalNonLethalVore Auto
Spell Property UnbirthLethalVore Auto
Spell Property UnbirthNonLethalVore Auto
Spell Property CockLethalVore Auto
Spell Property CockNonLethalVore Auto

SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Actor Property PlayerRef Auto
String Property DebugName
  String Function get()
    Return "[SCV_DebugSpell " + GetTargetActor().GetLeveledActorBase().GetName() + "] "
  EndFunction
EndProperty
Bool EnableDebugMessages = True

Event OnEffectStart(Actor akTarget, Actor akCaster)
  UIListMenu UIList = UIExtensions.GetMenu("UIListMenu", True) as UIListMenu
  Int JI_OptionList = JValue.retain(JIntMap.object())
  Int CurrentEntry = UIList.AddEntryItem("Max Stats", entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, CurrentEntry, "MaxStats")
  JIntMap.setStr(JI_OptionList, UIList.AddEntryItem("Oral", CurrentEntry), "MaxStatsOral")
  JIntMap.setStr(JI_OptionList, UIList.AddEntryItem("Anal", CurrentEntry), "MaxStatsAnal")
  JIntMap.setStr(JI_OptionList, UIList.AddEntryItem("Unbirth", CurrentEntry), "MaxStatsUnbirth")
  JIntMap.setStr(JI_OptionList, UIList.AddEntryItem("Cock", CurrentEntry), "MaxStatsCock")

  CurrentEntry = UIList.AddEntryItem("Force Vore (Player)", entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, CurrentEntry, "ForcePlayerVore")

  Int ChildEntry = UIList.AddEntryItem("Oral", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForcePlayerVoreOral")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForcePlayerVoreOralLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForcePlayerVoreOralNonLethal")

  ChildEntry = UIList.AddEntryItem("Anal", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForcePlayerVoreAnal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForcePlayerVoreAnalLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForcePlayerVoreAnalNonLethal")

  ChildEntry = UIList.AddEntryItem("Unbirth", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForcePlayerVoreUnbirth")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForcePlayerVoreUnbirthLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForcePlayerVoreUnbirthNonLethal")

  ChildEntry = UIList.AddEntryItem("Cock", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForcePlayerVoreCock")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForcePlayerVoreCockLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForcePlayerVoreCockNonLethal")


  CurrentEntry = UIList.AddEntryItem("Force Vore (Random)", entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, CurrentEntry, "ForceRandomVore")

  ChildEntry = UIList.AddEntryItem("Oral", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceRandomVoreOral")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceRandomVoreOralLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceRandomVoreOralNonLethal")

  ChildEntry = UIList.AddEntryItem("Anal", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceRandomVoreAnal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceRandomVoreAnalLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForcePlayerVoreAnalNonLethal")

  ChildEntry = UIList.AddEntryItem("Unbirth", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceRandomVoreUnbirth")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceRandomVoreUnbirthLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceRandomVoreUnbirthNonLethal")

  ChildEntry = UIList.AddEntryItem("Cock", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceRandomVoreCock")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceRandomVoreCockLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceRandomVoreCockNonLethal")


  CurrentEntry = UIList.AddEntryItem("Force Vore (Console)", entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, CurrentEntry, "ForceConsoleVore")

  ChildEntry = UIList.AddEntryItem("Oral", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceConsoleVoreOral")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceConsoleVoreOralLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceConsoleVoreOralNonLethal")

  ChildEntry = UIList.AddEntryItem("Anal", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceConsoleVoreAnal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceConsoleVoreAnalLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceConsoleVoreAnalNonLethal")

  ChildEntry = UIList.AddEntryItem("Unbirth", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceConsoleVoreUnbirth")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceConsoleVoreUnbirthLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceConsoleVoreUnbirthNonLethal")

  ChildEntry = UIList.AddEntryItem("Cock", CurrentEntry, entryHasChildren = True)
  JIntMap.setStr(JI_OptionList, ChildEntry, "ForceConsoleVoreCock")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("Lethal", ChildEntry), "ForceConsoleVoreCockLethal")
  JIntMap.setStr(JI_OptionList, UiList.AddEntryItem("NonLethal", ChildEntry), "ForceConsoleVoreCockNonLethal")

  UIList.OpenMenu()
  Int Option = UIList.GetResultInt()
  Note("Option = " + Option)
  String Selection = JIntMap.getStr(JI_OptionList, Option)
  Note("Selection = " + Selection)
  If Selection == "MaxStatsOral"
    Int TargetData = SCXLib.getTargetData(akTarget, True)
    JMap.setInt(TargetData, "SCV_IsOVPred", 1)
    JMap.setInt(TargetData, "SCV_OVLevel", 100)
    JMap.setFlt(TargetData, "SCLStomachCapacity", 2000)
    JMap.setFlt(TargetData, "SCLDigestRate", 300)
    JMap.setFlt(TargetData, "SCV_PredStruggleRating", 10)
    SCVlib.takeUpPerks(akTarget, "SCV_FollowerofNamira", 3)
  ElseIf Selection == "MaxStatsAnal"
    Int TargetData = SCXLib.getTargetData(akTarget, True)
    JMap.setInt(TargetData, "SCV_IsAVPred", 1)
    JMap.setInt(TargetData, "SCV_AVLevel", 100)
    JMap.setFlt(TargetData, "SCV_PredStruggleRating", 10)
    SCVlib.takeUpPerks(akTarget, "SCV_FollowerofNamira", 3)
  ElseIf Selection == "MaxStatsUnbirth"
    Int TargetData = SCXLib.getTargetData(akTarget, True)
    JMap.setInt(TargetData, "SCV_IsUVPred", 1)
    JMap.setInt(TargetData, "SCV_UVLevel", 100)
    JMap.setFlt(TargetData, "SCV_PredStruggleRating", 10)
    SCVlib.takeUpPerks(akTarget, "SCV_FollowerofNamira", 3)
  ElseIf Selection == "MaxStatsCock"
    Int TargetData = SCXLib.getTargetData(akTarget, True)
    JMap.setInt(TargetData, "SCV_IsCVPred", 1)
    JMap.setInt(TargetData, "SCV_CVLevel", 100)
    JMap.setFlt(TargetData, "SCV_PredStruggleRating", 10)
    SCVlib.takeUpPerks(akTarget, "SCV_FollowerofNamira", 3)
  ElseIf Selection == "ForcePlayerVoreOralLethal"
    If OralLethalVore
      Note("Spell found!")
    Else
      Note("Spell not found!")
    endIf
    OralLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreOralNonLethal"
    OralNonLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreAnalLethal"
    AnalLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreAnalNonLethal"
    AnalNonLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreUnbirthLethal"
    UnbirthLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreUnbirthNonLethal"
    UnbirthNonLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreCockLethal"
    CockLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForcePlayerVoreCockNonLethal"
    CockNonLethalVore.Cast(akTarget, akCaster)
  ElseIf Selection == "ForceRandomVoreOralLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      OralLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceRandomVoreOralNonLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      OralNonLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceRandomVoreAnalLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      AnalLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForcePlayerVoreAnalNonLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      AnalNonLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceRandomVoreUnbirthLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      UnbirthLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceRandomVoreUnbirthNonLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      UnbirthNonLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceRandomVoreCockLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      CockLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceRandomVoreCockNonLethal"
    Actor Victim = None
    Int i = 0
    Note("Forcing Random Vore, Searching for potential victim")
    While !Victim && i < 10
      Victim = Game.FindRandomActorFromRef(akTarget, 1024)
      If Victim == akTarget || Victim == PlayerRef
        Victim = None
      EndIf
      i += 1
      ;Debug.Notification("Attempt " + i)
    EndWhile
    If Victim == akTarget || Victim == PlayerRef
      Victim = None
    EndIf
    If Victim
      CockNonLethalVore.Cast(akTarget, Victim)
    EndIf
  ElseIf Selection == "ForceConsoleVoreOralLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      OralLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreOralNonLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      OralNonLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreAnalLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      AnalLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreAnalNonLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      AnalNonLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreUnbirthLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      UnbirthLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreUnbirthNonLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      UnbirthNonLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreCockLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      CockLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  ElseIf Selection == "ForceConsoleVoreCockNonLethal"
    Actor Victim = Game.GetCurrentConsoleRef() as Actor
    If Victim
      CockNonLethalVore.Cast(akTarget, Victim)
    Else
      Note("No Actor is selected in the console!")
    EndIf
  EndIf
  JI_OptionList = JValue.release(JI_OptionList)
  SCVLib.checkPredAbilities(akTarget)
  SCVLib.checkPredSpells(akTarget)
EndEvent
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
