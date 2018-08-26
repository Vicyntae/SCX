ScriptName SCVStruggleSpell Extends ActiveMagicEffect

SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCX_BasePerk Property Constriction Auto
SCX_BasePerk Property Acid Auto
SCX_BasePerk Property ThrillingStruggle Auto
SCX_BasePerk Property CorneredRat Auto
SCX_BasePerk Property StruggleSorcery Auto
String Property DebugName
  String Function Get()
    Return "[SCVStruggle " + Pred.GetLeveledActorBase().GetName() + "] "
  EndFunction
EndProperty
Bool EnableDebugMessages = True
Spell Property BaseSpell Auto
Actor Property PlayerRef Auto
Int ActorData
Actor Pred
MagicEffect Property AlchRestoreStamina Auto

Spell Property SCV_TEST_StaminaSpell Auto
Event OnEffectStart(Actor akTarget, Actor akCaster)
  Pred = akTarget
  Notice("Struggle spell started!")
  ActorData = SCXLib.getTargetData(Pred)
  RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
  updateStruggle(Pred, aiTargetData = ActorData)
  performStruggle(Pred, ActorData)
  RegisterForSingleUpdate(0.1)
EndEvent

Function updateStruggle(Actor akTarget, Float afHigherStruggle = 0.0, Float afHigherDamage = 0.0, Int aiTargetData = 0)
  {Recursive function, checks pred and all prey for how much damage is done.}
  Notice("Updating struggle on " + akTarget.GetLeveledActorBase().GetName())
  Int TargetData = SCVLib.getData(akTarget, aiTargetData)
  Int Contents = SCXLib.getContents(akTarget, "Struggling", "Breakdown", TargetData)
  Float PredStruggleLevel = JMap.getFlt(TargetData, "SCV_PredStruggleRating", 1)
  Float PredDamageLevel = JMap.getFlt(TargetData, "SCV_PredDamageRating")
  ;Int PredStrugglePerk = Constriction.getPerkLevel(akTarget)
  ;Int PredStrugglePerk = Acid.getPerkLevel(akTarget)
  Float TotalPreyStruggle = afHigherStruggle
  Float TotalPreyDamage = afHigherDamage
  Form i = JFormMap.nextKey(Contents)
  While i
    If i as Actor
      Actor akActor = i as Actor
      Int PreyData = SCVLib.getTargetData(akActor)
      Float StruggleAdd
      Float DamageAdd
      If PreyData
        StruggleAdd = JMap.getFlt(PreyData, "SCV_PreyStruggleRating")
        DamageAdd = JMap.getFlt(PreyData, "SCV_PreyDamageRating")
      Else
        StruggleAdd = 1
      EndIf
      If !StruggleAdd
        StruggleAdd = 1
      EndIf
      TotalPreyStruggle += StruggleAdd
      TotalPreyDamage += DamageAdd
      updateStruggle(akActor, PredStruggleLevel, PredDamageLevel, PreyData)
    EndIf
    i = JFormMap.nextKey(Contents, i)
  EndWhile

  If akTarget.Is3DLoaded() || akTarget == PlayerRef
    SCVLib.setProxy(akTarget, "Health", akTarget.GetActorValue("Health"))
    SCVLib.setProxy(akTarget, "Stamina", akTarget.GetActorValue("Stamina"))
    SCVLib.setProxy(akTarget, "Magicka", akTarget.GetActorValue("Magicka"))
  EndIf

  JMap.setFlt(TargetData, "SCV_StruggleRank", TotalPreyStruggle)
  ;Note(SCVLib.nameGet(akTarget) + " struggle rank = " + TotalPreyStruggle)
  JMap.setFlt(TargetData, "SCV_DamageRank", TotalPreyDamage)
  ;Note(SCVLib.nameGet(akTarget) + " damage rank = " + TotalPreyDamage)
EndFunction

Function performStruggle(Actor akTarget, Int aiTargetData = 0)
  {Recursive function, deals struggle damage to predator and all prey within them}
  Note(akTarget.GetLeveledActorBase().GetName() + " is loaded in area: " + akTarget.Is3DLoaded())
  Int TargetData = SCVLib.getData(akTarget, aiTargetData)
  Float Struggle = JMap.getFlt(TargetData, "SCV_StruggleRank")
  Float Damage = JMap.getFlt(TargetData, "SCV_DamageRank")
  Int MagicPerk = StruggleSorcery.getPerkLevel(akTarget)
  Notice(SCVLib.nameGet(akTarget) + " stamina proxy = " + SCVLib.getProxy(akTarget, "Stamina") + "/" + SCVLib.getProxyBase(akTarget, "Stamina") + ", " + SCVLib.getProxyPercent(akTarget, "Stamina"))
  Float StaminaPercent = akTarget.GetActorValuePercentage("Stamina")
  ;/If akTarget != PlayerRef && StaminaPercent < 0.5
    Float Chance = Utility.RandomFloat()
    If Chance < 0.3
      Int i
      Int NumItems = akTarget.GetNumItems()
      Bool Taken
      While i < NumItems && !Taken
        Form Item = akTarget.getNthForm(i)
        If Item && Item as Potion
          If !(Item as Potion).IsFood() || !(Item as Potion).IsPoison()
            MagicEffect[] Effects = (Item as Potion).GetMagicEffects()
            Int StaminaFind = Effects.Find(AlchRestoreStamina)
            If StaminaFind >= 0
              akTarget.EquipItem(Item)
              Taken = True
            EndIf
          EndIf
        EndIf
        i += 1
      EndWhile
    EndIf
  EndIf/;
  If Struggle
    Float SReduce = JMap.getFlt(TargetData, "SCV_StaminaStruggleResist", 1)
    Float SMod = SCVSet.StruggleMod
    If MagicPerk
      Float MReduce = JMap.getFlt(TargetData, "SCV_MagicStruggleResist", 1)
      akTarget.DamageActorValue("Stamina", ((Struggle* SMod) / 2) / SReduce)
      akTarget.DamageActorValue("Magicka", ((Struggle* SMod) / 2) / MReduce)
      SCVLib.modProxy(akTarget, "Stamina", -((Struggle* SMod) / 2) / SReduce)
      SCVLib.modProxy(akTarget, "Magicka", -((Struggle * SMod) / 2) / MReduce)
    Else
      akTarget.DamageActorValue("Stamina", (Struggle* SMod) / SReduce)
      SCVLib.modProxy(akTarget, "Stamina", -(Struggle* SMod) / SReduce)
    EndIf
  EndIf
  If Damage
    Float DMod = SCVSet.DamageMod
    akTarget.DamageActorValue("Health", Damage * DMod)
    SCVLib.modProxy(akTarget, "Health", -(Damage * DMod))
  EndIf
  Float Stamina = akTarget.GetActorValuePercentage("Stamina")
  Float StaminaProxy = SCVLib.getProxyPercent(akTarget, "Stamina")
  If SCVLib.isInPred(akTarget, TargetData)
    SCVLib.giveVoreExp(akTarget, "Resistance", Math.Ceiling(Struggle + Damage), TargetData)
  EndIf
  If akTarget.Is3DLoaded() || akTarget == PlayerRef
    If akTarget.IsDead()
      SCVLib.handleFinishedActor(akTarget)
    ElseIf Stamina <= 0.05
      Float Magicka = akTarget.GetActorValuePercentage("Magicka")
      If !MagicPerk || Magicka <= 0.05
        SCVLib.Notice("Actor is exhausted! Handling finished actor.")
        SCVLib.handleFinishedActor(akTarget)
      EndIf
    EndIf
  Else
    If SCVLib.getProxy(akTarget, "Health") <= 0
      akTarget.Kill(SCVLib.getPred(akTarget))
      SCVLib.handleFinishedActor(akTarget)
    ElseIf StaminaProxy <= 0.05
      Float MagickaProxy = SCVLib.getProxyPercent(akTarget, "Magicka")
      If !MagicPerk || MagickaProxy <= 0.05
        SCVLib.handleFinishedActor(akTarget)
      EndIf
    EndIf
  EndIf

  If akTarget != Pred
    SCV_TEST_StaminaSpell.Cast(akTarget)
    If !akTarget.HasSpell(SCVSet.FollowSpell)
      akTarget.AddSpell(SCVSet.FollowSpell)
    EndIf
  EndIf

  Int Contents = SCXLib.getContents(akTarget, "Struggling", "Breakdown", TargetData)
  Form i = JFormMap.nextKey(Contents)
  While i
    If i as Actor
      performStruggle(i as Actor)
    EndIf
    i = JFormMap.nextKey(Contents, i) as Actor
  EndWhile
EndFunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Notice("Struggle effect removed!")
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
