ScriptName SCWLibrary Extends SCX_BaseLibrary

Function WF_SolidRemoveSpecific(Actor akTarget, Int aiItemType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyDigestItems = True)
  If !akReference && !akBaseObject
    Return
  EndIf
  If aiItemType != 3 || aiItemType != 4
    Return
  EndIf
  Int JF_ContentsMap = getContents(akTarget, aiItemType)
  SCLWFSolidWaste Refuse = WF_SolidRemovePerform(akTarget, False)
  If akReference
    If akReference as Actor
      extractActor(akTarget, akReference as Actor, aiItemType, Refuse)
    ElseIf akReference as SCLBundle
      If !abDestroyDigestItems || aiItemType != 3
        Refuse.addItem((akReference as SCLBundle).ItemForm, (akReference as SCLBundle).NumItems, False)
      EndIf
      akReference.Delete()
    Else
      If !abDestroyDigestItems || aiItemType != 3
        Refuse.AddItem(akReference as ObjectReference, 1, False)
      EndIf
      ;akReference.Delete()
    EndIf
    WF_sendSolidRemoveEvent(akTarget, 3, False, akReference)
    JFormMap.removeKey(JF_ContentsMap, akReference)
  Else
    SCLBundle Bundle = findBundle(JF_ContentsMap, akBaseObject)
    If Bundle
      Bool bEmpty = False
      Int AddItems = Bundle.NumItems
      Bundle.NumItems -= aiItemCount
      If Bundle.NumItems > 0
        AddItems = aiItemCount
        bEmpty = True
      EndIf
      If !abDestroyDigestItems || aiItemType != 1
        Refuse.addItem(Bundle.ItemForm, AddItems, False)
      EndIf
      If bEmpty
        JFormMap.removeKey(JF_ContentsMap, Bundle)
        Bundle.Delete()
      Else
        Int JM_ItemEntry = JFormMap.getObj(JF_ContentsMap, Bundle)
        JMap.setFlt(JM_ItemEntry, "WeightValue", JMap.getFlt(JM_ItemEntry, "ActiveWeightValue") + (JMap.getFlt(JM_ItemEntry, "IndvWeightValue") * Bundle.NumItems))
      EndIf
      WF_sendSolidRemoveEvent(akTarget, 3, False, Bundle)
    EndIf
  EndIf
EndFunction

Function WF_sendSolidRemoveEvent(Actor akTarget, Int aiSolidRemoveType, Bool bLeveledRemains, Form akSpecificItem = None)
  Int E = ModEvent.Create("SCLWFRemoveSolidEvent")
  ModEvent.PushForm(E, akTarget)
  ModEvent.PushInt(E, aiSolidRemoveType)
  ModEvent.PushBool(E, bLeveledRemains)
  ModEvent.PushForm(E, akSpecificItem)
  ModEvent.Send(E)
EndFunction

SCLWFSolidWaste Function WF_placeSolidWaste(ObjectReference akPosition, Int aiType = 0)
  SCLWFSolidWaste Refuse
  If aiType == 0
    Refuse = akPosition.PlaceAtMe(SCLSet.SCL_WF_RefuseBase) as SCLWFSolidWaste
  ;ElseIf aiType == 1
  EndIf
  Refuse.MoveTo(akPosition, 64 * Math.Sin(akPosition.GetAngleZ()), 64 * Math.Cos(akPosition.GetAngleZ()), 0, False)
  Refuse.SetAngle(0, 0, 0)
  Return Refuse
EndFunction

Function WF_addSolidIllnessEffect(Actor akTarget, Int afIllnessLevel, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int CurrentLevel = JMap.getInt(TargetData, "IllnessLevel")
  If afIllnessLevel > 0
    If afIllnessLevel != CurrentLevel
      SCLSet.WF_SolidIllnessDebuffSpells[afIllnessLevel].Cast(akTarget)
      JMap.setInt(TargetData, "IllnessLevel", afIllnessLevel)
    EndIf
  Else
    If CurrentLevel != 0
      SCLSet.WF_SolidIllnessDebuffSpells[0].Cast(akTarget)
      JMap.setInt(TargetData, "IllnessLevel", 0)
    EndIf
  EndIf
EndFunction

Function WF_RemoveSolidContents(Actor akTarget, ObjectReference akTargetContainer, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int JF_Contents = getContents(akTarget, 3, TargetData)
  If !JValue.empty(JF_Contents)
    ObjectReference CurrentItem = JFormMap.nextKey(JF_Contents) as ObjectReference
    While CurrentItem
      If CurrentItem as SCLBundle
        Int ItemNum = (CurrentItem as SCLBundle).NumItems
        Form CurrentForm = (CurrentItem as SCLBundle).ItemForm
        akTargetContainer.AddItem(CurrentForm, ItemNum, False)
      ElseIf CurrentItem as Actor
        extractActor(akTarget, CurrentItem as Actor, 3, akTargetContainer)
      ElseIf CurrentItem
        akTargetContainer.addItem(CurrentItem, 1, False)
      EndIf
      CurrentItem = JFormMap.nextKey(JF_Contents, CurrentItem) as ObjectReference
    EndWhile
  EndIf
  JFormMap.clear(JF_Contents)

  JF_Contents = getContents(akTarget, 4, TargetData)
  If !JValue.empty(JF_Contents)
    ObjectReference CurrentItem = JFormMap.nextKey(JF_Contents) as ObjectReference
    While CurrentItem
      If CurrentItem as SCLBundle
        Int ItemNum = (CurrentItem as SCLBundle).NumItems
        Form CurrentForm = (CurrentItem as SCLBundle).ItemForm
        akTargetContainer.AddItem(CurrentForm, ItemNum, False)
      ElseIf CurrentItem as Actor
        extractActor(akTarget, CurrentItem as Actor, 3, akTargetContainer)
      ElseIf CurrentItem
        akTargetContainer.addItem(CurrentItem, 1, False)
      EndIf
      CurrentItem = JFormMap.nextKey(JF_Contents, CurrentItem) as ObjectReference
    EndWhile
  EndIf
  JFormMap.clear(JF_Contents)
EndFunction

;*******************************************************************************
;Waste Functions (WF)
;*******************************************************************************
;/Design Doc: Solid, Liquid, Gas system
Solids/Liquids build up with digestion of solid/liquid foods
Gases build up with any digestion, affected by the global setting and individual increase

;Solids ************************************************************************
Solids capacity dosen't increase naturally, instead must be upgraded
If you eat too much, you poop too much. Simple.
Max solid capacity acts like stomach capacity, grows and shrinks with size.
Can also be buffed/debuffed. Raw/Rotten foods will reduce this drastically
Works on an Int-Float system: When you eat something, will rise w/ float value. If it reaches next Int, give next tier.
Resets to Nearest Int over time. Allows for "resistance"
Delecate eaters will get sick with any item, more hearty ones can eat larger/more rotten foods at once
When you reach max, get "need" debuff. Strength will increase as long as you haven't pooped.
Speed increases w/sickness
Will also increases depending on length since last poop (start at 8 hours) regardless of amount
Will eventually force you to poop

Keys:
  WF_CurrentSolidAmount
  WF_SolidBase
  WF_SolidCapMulti
  WF_SolidTimePast
  IllnessBuildUp  Increases when you eat rotten food
  IllnessThreshold  If gets above this point, adds debuff
  IllnessLevel
Contents IDs:
  Breaking Down Map: 3
  Stored Map: 4
ItemData Keys:
  WF_SolidBaseLower
Variables:
  SCLSet.WF_SolidActive
  SCLSet.WF_SolidAdjBaseMulti
  SCLSet.IllnessBuildUpDecrease

Perks:
  WF_BasementStorage: 1: Increases max insert size. 2: Increases max storage capacity.
;Liquids ***********************************************************************
Liquids capacity increases based on level.
When you reach max, get "need" debuff. Strength will increase as long as you haven't peeed.
Will also increases depending on length since last pee (start at 8 hours) regardless of amount
Will eventually force you to pee
Not much here at the moment, need to think about more features.

Keys:
  WF_CurrentLiquidAmount
  WF_LiquidBase
  WF_LiquidTimePast
  WF_LiquidCapMulti
Variables:
  SCLSet.WF_LiquidActive
  SCLSet.WF_LiquidAdjBaseMulti
;Gases *************************************************************************
Maybe not impliment yet.

Keys:
  WF_CurrentGasAmount
  WF_GasBase
  WF_GasTimePast
  WF_GasCapMulti
Variables:
  SCLSet.WF_GasActive
  SCLSet.WF_GasAdjBaseMulti

;TODO List *********************************************************************
  Perks
  Figure out storage
/;

Float Function WF_getAdjSolidBase(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getFlt(TargetData, "WF_SolidBase", 1) * akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False) * SCLSet.WF_SolidAdjBaseMulti * JMap.getFlt(TargetData, "WF_SolidCapMulti", 1)
EndFunction

Float Function WF_getTotalSolidFullness(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Float ReturnValue = JMap.getFlt(TargetData, "WF_CurrentSolidAmount")
  ReturnValue += JMap.getFlt(TargetData, getContentsKey(3))
  ReturnValue += JMap.getFlt(TargetData, getContentsKey(4))
  Return ReturnValue
EndFunction

Float Function WF_getAdjLiquidBase(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return JMap.getFlt(TargetData, "WF_LiquidBase", 1) * akTarget.GetScale() * NetImmerse.GetNodeScale(akTarget, "NPC Root [Root]", False) * SCLSet.WF_LiquidAdjBaseMulti * JMap.getFlt(TargetData, "WF_LiquidCapMulti", 1)
EndFunction


Float Function WF_getSolidMaxInsert(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int SecondPerkLevel = getTotalPerkLevel(akTarget, "WF_BasementStorage")
  Float MaxInsert = Math.pow(SecondPerkLevel, 2) + 0.5
  If MaxInsert < 0
    MaxInsert = 0.5
  EndIf
  Return MaxInsert
EndFunction

Int Function WF_getSolidMaxNumItems(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Return getTotalPerkLevel(akTarget, "WF_BasementStorage", TargetData)
EndFunction

Function WF_LiquidRemove(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Debug.Notification("Urinating...")
  If akTarget.HasSpell(SCLSet.WF_LiquidDebuffSpell)
    akTarget.RemoveSpell(SCLSet.WF_LiquidDebuffSpell)
  EndIf
  JMap.setFlt(TargetData, "WF_CurrentLiquidAmount", 0)
EndFunction

SCLWFSolidWaste Function WF_SolidRemovePerform(Actor akTarget, Bool bLeveledRemains)
  If !akTarget.IsSneaking()
    Int i
    While !akTarget.IsSneaking() && i < 10
      Utility.Wait(0.5)
      akTarget.StartSneaking()
      i += 1
    EndWhile
  EndIf
  If akTarget == PlayerRef
    Game.ForceThirdPerson()
    Game.DisablePlayerControls()
  EndIf
  ;Play noise and animation here.
  SCLWFSolidWaste Waste = WF_placeSolidWaste(akTarget)
  If akTarget == PlayerRef
    Game.EnablePlayerControls()
  EndIf
  Return Waste
EndFunction

Function WF_SolidRemove(Actor akTarget, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  SCLWFSolidWaste Refuse = WF_SolidRemovePerform(akTarget, False)
  WF_removeSolidContents(akTarget, Refuse, TargetData)
  If akTarget.HasSpell(SCLSet.WF_SolidDebuffSpell)
    akTarget.RemoveSpell(SCLSet.WF_SolidDebuffSpell)
  EndIf
  JMap.setFlt(TargetData, "WF_SolidTimePast", 0)
  JMap.setFlt(TargetData, "WF_CurrentSolidAmount", 0)
  Int Illness = JMap.getInt(TargetData, "IllnessLevel")
  Illness -= 1
  If Illness < 0
    Illness = 0
  EndIf
  WF_addSolidIllnessEffect(akTarget, Illness)
EndFunction

Function WF_SolidRemoveNum(Actor akTarget, Int aiNumToRemove, Bool abRemoveBreakingDown = False, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int JF_ContentsMap = getContents(akTarget, 4, TargetData)
  SCLWFSolidWaste Refuse = WF_SolidRemovePerform(akTarget, False)
  ObjectReference ItemKey = JFormMap.nextKey(JF_ContentsMap) as ObjectReference
  Int JA_Remove = JArray.object()
  While aiNumToRemove && ItemKey
    If ItemKey
      If ItemKey as Actor
        extractActor(akTarget, ItemKey as Actor, 4, Refuse)
        aiNumToRemove -= 1
        JArray.addForm(JA_Remove, ItemKey)
      ElseIf ItemKey as SCLBundle
        Int NumOfItems = (ItemKey as SCLBundle).NumItems
        If NumOfItems > aiNumToRemove
          NumOfItems -= aiNumToRemove
          Refuse.AddItem((ItemKey as SCLBundle).ItemForm, aiNumToRemove, True)
          aiNumToRemove = 0
          (ItemKey as SCLBundle).NumItems = NumOfItems
        Else
          Refuse.AddItem((ItemKey as SCLBundle).ItemForm, NumOfItems, True)
          aiNumToRemove -= NumOfItems
          JArray.addForm(JA_Remove, ItemKey)
        EndIf
      Else
        Refuse.AddItem(ItemKey, 1, True)
        aiNumToRemove -= 1
        JArray.addForm(JA_Remove, ItemKey)
      EndIf
    EndIf
  ItemKey = JFormMap.nextKey(JF_ContentsMap, ItemKey) as ObjectReference
  EndWhile
  JF_eraseKeys(JF_ContentsMap, JA_Remove)
  If abRemoveBreakingDown && aiNumToRemove
    JF_ContentsMap = getContents(akTarget, 3, TargetData)
    JA_Remove = JArray.object()
    ItemKey = JFormMap.nextKey(JF_ContentsMap) as ObjectReference
    While aiNumToRemove && ItemKey
      If ItemKey
        If ItemKey as Actor
          extractActor(akTarget, ItemKey as Actor, 3, Refuse)
          aiNumToRemove -= 1
          JArray.addForm(JA_Remove, ItemKey)
        ElseIf ItemKey as SCLBundle
          Int NumOfItems = (ItemKey as SCLBundle).NumItems
          If NumOfItems > aiNumToRemove
            NumOfItems -= aiNumToRemove
            ;Refuse.AddItem((ItemKey as SCLBundle).ItemForm, aiNumToRemove, True)
            aiNumToRemove = 0
            (ItemKey as SCLBundle).NumItems = NumOfItems
          Else
            ;Refuse.AddItem((ItemKey as SCLBundle).ItemForm, NumOfItems, True)
            aiNumToRemove -= NumOfItems
            JArray.addForm(JA_Remove, ItemKey)
          EndIf
        Else
          ;Refuse.AddItem(ItemKey, 1 True)
          aiNumToRemove -= 1
          JArray.addForm(JA_Remove, ItemKey)
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_ContentsMap, ItemKey) as ObjectReference
    EndWhile
  EndIf
EndFunction
