ScriptName SCX_BaseItemArchetypes Extends SCX_BaseRefAlias Hidden
{AKA different "containers" that items can reside in that get removed in similar ways.
EX. Stomach, Colon, Vagina, etc.
ID = name of alias}
Int Function _getSCX_JC_List()
  Return SCXSet.JM_BaseArchetypes
EndFunction

String[] Property ItemTypes Auto  ;Instead of numbers, it will be Archetype.Type pairs. this lists possible types for this archetype
String[] Property ItemContentsKeys Auto
String[] Property ItemStoredTypes Auto  ;Arch.Type Pairs

String[] Property ShortDescriptions Auto
String[] Property FullDescriptions Auto

String Property TotalWeightKey Auto

Float Function updateArchetype(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Float Total
  String sKey = _getStrKey()
  Int i = ItemTypes.length
  While i
    i -= 1
    Int JF_Contents = getContents(akTarget, sKey, ItemTypes[i], aiTargetData)
    If JValue.isFormMap(JF_Contents)
      Total += sumWeightValues(JF_Contents)
    EndIf
  EndWhile
  i = ItemStoredTypes.length
  While i
    i -= 1
    String[] StoredKeys = StringUtil.Split(ItemStoredTypes[i], ".")
    Int JF_Contents = getContents(akTarget, StoredKeys[0], StoredKeys[1], aiTargetData)
    If JValue.isFormMap(JF_Contents)
      Total += sumStoredWeightValues(JF_Contents, ItemTypes)
    EndIf
  EndWhile
  JMap.setFlt(aiTargetData, TotalWeightKey, Total)
  Return Total
EndFunction

Function removeAllActorItems(Actor akTarget, Bool ReturnItems = False)
EndFunction

Function removeAmountActorItems(Actor akTarget, Float afRemoveAmount, Float afStoredRemoveChance = 0.0, Float afOtherRemoveChance = 0.0)
EndFunction

Function removeSpecificActorItems(Actor akTarget, String asArchetype, String asType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyDigestItems = True)
EndFunction

ObjectReference Function performRemove(Actor akTarget, Bool abLeveled)
EndFunction

Function addTransferItem(Actor akTarget, ObjectReference akItemReference = None, Form akBaseItem = None, Int aiItemCount = 1)
EndFunction

Function addUIEActorContents(Actor akTarget, UIListMenu UIList, Int JI_ItemList, Int JI_OptionList, Int aiMode = 0)
  Int JF_Contents = JValue.retain(getAllContents(akTarget))
  Form ItemKey = JFormMap.nextKey(JF_Contents)
  While ItemKey
    Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
    If JValue.isMap(JM_ItemEntry)
      Int ItemType = JMap.getInt(JM_ItemEntry, "ItemType")
      String ItemDesc = getItemListDesc(ItemKey, JM_ItemEntry)
      Int CurrentEntry = UIList.AddEntryItem(ItemDesc, entryHasChildren = True)
      JIntMap.setForm(JI_ItemList, CurrentEntry, ItemKey)
      String ArchName = GetName()
      Int ChildEntry1 = UIList.AddEntryItem("Extract Item", CurrentEntry, CurrentEntry)
      JIntMap.setStr(JI_OptionList, ChildEntry1, ArchName + "." + ItemType + ".Extract")
      ;Int ChildEntry2 = UIList.AddEntryItem("Switch Item State", CurrentEntry, CurrentEntry)
      ;JIntMap.setStr(JI_OptionList, ChildEntry2, ArchName + "." + ItemType + ".SwitchState")
    EndIf
    ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
  EndWhile
EndFunction

Bool Function HandleUIEActorContents(Actor akTarget, Form akItem, String asType, String asAction, Int aiMode = 0)
  If asAction == "Extract"
    removeSpecificActorItems(akTarget, _getStrKey(), asType, akItem as ObjectReference, akItem)
    Return True
  EndIf
  Return False
EndFunction

Int Function getAllContents(Actor akTarget, Int aiTargetData = 0)
  {Gathers form-value pairs from all contents types and returns them in new JFormMap}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int JF_CompiledContents = JValue.retain(JFormMap.object())
  Int j = 0
  Int NumItemTypes = ItemTypes.length
  While j < NumItemTypes
    Int JF_Contents = getContents(akTarget, ItemTypes[j], aiTargetData)
    JFormMap.addPairs(JF_CompiledContents, JF_Contents, True)
    j += 1
  EndWhile
  j = 0
  NumItemTypes = ItemStoredTypes.length
  While j < NumItemTypes
    Int JF_Contents = getContents(akTarget, ItemStoredTypes[j], aiTargetData)
    Form FormKey = JFormMap.nextKey(JF_Contents)
    While FormKey
      Int JM_ItemEntry = JFormMap.getObj(JF_Contents, FormKey)
      If ItemTypes.Find(JMap.getInt(JM_ItemEntry, "StoredItemType")) != -1
        JFormMap.setObj(JF_CompiledContents, FormKey, JM_ItemEntry)
      Endif
      FormKey = JFormMap.nextKey(JF_Contents)
    EndWhile
    j += 1
  EndWhile
  JValue.release(JF_CompiledContents)
  Return JF_CompiledContents
EndFunction

Bool Function checkTransferItem(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
  Return False
EndFunction

Function displayTransferItemAccept(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
EndFunction

Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, String asType, String asStoredArchPlusType = "", Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
EndFunction

Function displayTransferItemReject(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
EndFunction

String Function getItemListDesc(Form akItem, Int JM_ItemEntry)
  String Name
  If akItem as SCX_Bundle
    Form BundleItem = (akItem as SCX_Bundle).ItemForm
    Int NumItems = (akItem as SCX_Bundle).ItemNum
    If BundleItem as Actor
      Name = (BundleItem as Actor).GetLeveledActorBase().GetName() + "x" + NumItems
    ElseIf BundleItem as ObjectReference
      Name = (BundleItem as ObjectReference).GetBaseObject().GetName() + "x" + NumItems
    Else
      Name = BundleItem.GetName() + "x" + NumItems
    EndIf
  ElseIf akItem as Actor
    Name = (akItem as Actor).GetLeveledActorBase().GetName()
  ElseIf akItem as ObjectReference
    Name = (akItem as ObjectReference).GetBaseObject().GetName()
  Else
    Name = akItem.GetName()
  EndIf
  String Desc
  String[] ItemType = StringUtil.Split(JMap.getStr(JM_ItemEntry, "ItemType"), ".")
  If ItemType[0] == _getStrKey()
    Int Index = ItemTypes.find(ItemType[1])
    If Index != -1
      Desc = ShortDescriptions[Index]
    EndIf
  Else
    SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, ItemType[0]) as SCX_BaseItemArchetypes
    If Arch
      Int Index = Arch.ItemTypes.find(ItemType[1])
      If Index != -1
        Desc = Arch.ShortDescriptions[Index]
      EndIf
    EndIf
  EndIf

  Float WeightValue = JMap.getFlt(JM_ItemEntry, "WeightValue")
  String Finished = Name + ": " + Desc + ": " + WeightValue
  Return Finished
EndFunction
