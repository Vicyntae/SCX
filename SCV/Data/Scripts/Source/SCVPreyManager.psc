ScriptName SCVPreyManager Extends SCX_BaseQuest
{Gathers prey for preds using multi-prey skills}
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCV_BaseAnimation Property BlankAnim Auto
Keyword Property ActorTypeNPC Auto
Race Property WolfRace Auto
Function Setup()
  JF_PredList = JValue.Retain(JFormMap.object())
EndFunction

Function reloadMaintenence()
  RegisterForModEvent("SCVPreyGather", "OnPreyListRecieved")
EndFunction

Int JF_PredList
Event OnPreyListRecieved(Form akPred, Int JF_PreyList, Bool allAtOnce, Int JA_TagList)
  Actor Pred = akPred as Actor
  If !Pred
    Return
  EndIf

  ;/If allAtOnce
    Alias MultiAnim = getMultiAnim(Pred, JF_PredList, JA_TagList)
    If MultiAnim
      executeAnimation()
    EndIf
  EndIf/;

  Int NumPrey = JFormMap.count(JF_PreyList)
  Alias[] AnimArray = Utility.CreateAliasArray(NumPrey)
  Int i
  While i < NumPrey
    Actor Prey = JFormMap.getNthKey(JF_PreyList, i) as Actor
    Note("Retrieving animation for " + nameGet(akPred) + " and " + nameGet(Prey))
    AnimArray[i] = getRandomAnim(Pred, Prey, JFormMap.getObj(JF_PreyList, Prey), JA_TagList)
    i += 1
  EndWhile

  i = 0
  While i < NumPrey
    Actor Prey = JFormMap.getNthKey(JF_PreyList, i) as Actor
    SCV_BaseAnimation Anim = AnimArray[i] as SCV_BaseAnimation
    If Anim
      Actor[] Actors = New Actor[2]
      Actors[0] = Pred
      Actors[1] = Prey
      Int[] Datas = New Int[2]
      Datas[1] = JFormMap.getObj(JF_PreyList, Prey, JA_TagList)
      Anim.prepAnimation(Actors, Datas, JA_TagList)
      Anim.runAnimation(Actors, Datas, JA_TagList)
    EndIf
    i += 1
  EndWhile
EndEvent

Alias Function getRandomAnim(Actor akPred, Actor akPrey, Int JM_PreyInfo, Int JA_TagList)
  String AnimType = JMap.getStr(JM_PreyInfo, "VoreType")
  Note("VoreType = " + AnimType)
  Bool Success = JMap.getInt(JM_PreyInfo, "Success") as Bool
  If !Success
    Int JA_MasterAnimList = JDB.solveObj(".SCX_ExtraData.SCVAnimations.VoreFail")
    Int Index = Utility.RandomInt(0, JArray.count(JA_MasterAnimList) - 1)
    String AnimID = JArray.getStr(JA_MasterAnimList, Index)
    Return getSCX_BaseAlias(SCVSet.JM_VoreAnimationList, AnimID) as Alias
  EndIf

  String PredRace = SCVLib.getRaceString(akPred)
  Int JA_MasterAnimList = JDB.solveObj(".SCX_ExtraData.SCVAnimations." + AnimType)
  Int JA_AnimArray = JArray.object()
  JArray.addFromArray(JA_AnimArray, JA_MasterAnimList)
  Bool Found
  While !Found && JArray.count(JA_AnimArray) > 0
    Note("Number of animations available =" + JArray.count(JA_AnimArray))
    Int Index = Utility.RandomInt(0, JArray.count(JA_AnimArray) - 1)
    String AnimID = JArray.getStr(JA_AnimArray, Index)
    Note("Checking animation " + AnimID)
    SCV_BaseAnimation Anim = getSCX_BaseAlias(SCVSet.JM_VoreAnimationList, AnimID) as SCV_BaseAnimation

    Actor[] Actors = New Actor[2]
    Actors[0] = akPred
    Actors[1] = akPrey
    Int[] Info = New Int[2]
    Info[1] = JM_PreyInfo
    If Anim.checkActors(Actors, Info, JA_TagList)
      Return Anim as Alias
    EndIf
    JArray.eraseIndex(JA_AnimArray, Index)
    JArray.unique(JA_AnimArray)
  EndWhile
  Alias BackupAnim = getSCX_BaseAlias(SCVSet.JM_VoreAnimationList, JMap.getStr(SCVSet.JM_DefaultAnimList, PredRace)) as Alias
  If BackupAnim
    Return BackupAnim
  Else
    Return BlankAnim
  EndIf
EndFunction

String Function getRaceString(Actor akTarget)
  Race akRace = akTarget.GetRace()
  If akRace.HasKeyword(ActorTypeNPC)
    Return "Human"
  ElseIf akRace == WolfRace
    Return "Wolf"
  Else
    Return ""
  EndIf
EndFunction
