ScriptName SCX_BaseItemArchetypes Extends SCX_BaseRefAlias Hidden
{AKA different "containers" that items can reside in that get removed in similar ways.
EX. Stomach, Colon, Vagina, etc.
ID = name of alias}
Int Function _getSCX_JC_List()
  Return SCXSet.JM_BaseArchetypes
EndFunction

Int[] Property ItemTypes Auto
Int[] Property ItemStoredTypes Auto ;Any items with the key "StoredItemType" will be searched for and obtained in these JFormMaps
String[] Property ShortDescriptions Auto
String[] Property FullDescriptions Auto
String[] Property ContentsKeys Auto

Int Property MainStorageType = 0 Auto ;Where are items stored?
Int Property MainBreakdownType = 0 Auto ;Where are they broken down?
Int Property MainBuildupType = 0 Auto   ;Where are the built up?
String Property TotalWeightKey Auto

Float Function updateArchetype(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Float Total
  Int i = ItemTypes.length
  While i
    i -= 1
    Int JF_Contents = getContents(akTarget, ItemTypes[i], aiTargetData)
    If JValue.isFormMap(JF_Contents)
      Total += sumWeightValues(JF_Contents)
    EndIf
  EndWhile
  i = ItemStoredTypes.length
  While i
    i -= 1
    Int JF_Contents = getContents(akTarget, ItemStoredTypes[i], aiTargetData)
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

Function removeSpecificActorItems(Actor akTarget, Int aiItemType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyBreakdownItems = True)
EndFunction

ObjectReference Function performRemove(Actor akTarget, Bool abLeveled)
EndFunction

Function addTransferItem(Actor akTarget, ObjectReference akItemReference = None, Form akBaseItem = None, Int aiItemCount = 1)
EndFunction

Function addUIEActorContents(Actor akTarget, UIListMenu UIList, Int JI_ItemList, Int JI_OptionList, Int aiMode = 0)
  Int JF_Contents = JValue.retain(getAllContents(akTarget))
  Form ItemKey = JFormMap.nextKey(JF_Contents)
  ReferenceAlias[] ItemBases = New ReferenceAlias[128]
  While ItemKey
    Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
    If JValue.isMap(JM_ItemEntry)
      Int ItemType = JMap.getInt(JM_ItemEntry, "ItemType")
      SCX_BaseItemType Base = ItemBases[ItemType] as SCX_BaseItemType
      If Base == None
        Base = SCXLib.getSCX_BaseAlias(SCXSet.JI_BaseItemTypes, aiBaseID = ItemType) as SCX_BaseItemType
        ItemBases[ItemType] = Base
      EndIf
      String ItemDesc = Base.getItemListDesc(ItemKey, JM_ItemEntry)
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

Bool Function HandleUIEActorContents(Actor akTarget, Form akItem, Int aiItemType, String asAction, Int aiMode = 0)
  If asAction == "Extract"
    removeSpecificActorItems(akTarget, aiItemType, akItem as ObjectReference, akItem)
    Return True
  EndIf
  Return False
EndFunction

Int Function getAllContents(Actor akTarget, Int aiTargetData = 0)
  {Gathers form-value pairs from all contents types and returns them in new JFormMap}
  If JValue.isExists(aiTargetData)
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  Int JF_CompiledContents = JValue.retain(JFormMap.object())
  Int j = 0
  Int NumItemTypes = ItemTypes.length
  While j < NumItemTypes
    Int JF_Contents = SCXLib.getContents(akTarget, ItemTypes[j], aiTargetData)
    JFormMap.addPairs(JF_CompiledContents, JF_Contents, True)
    j += 1
  EndWhile
  j = 0
  NumItemTypes = ItemStoredTypes.length
  While j < NumItemTypes
    Int JF_Contents = SCXLib.getContents(akTarget, ItemStoredTypes[j], aiTargetData)
    Form FormKey = JFormMap.nextKey(JF_Contents)
    While FormKey
      Int JM_ItemEntry = JFormMap.getObj(JF_Contents, FormKey)
      If ItemTypes.Find(JMap.getInt(JM_ItemEntry, "StoredItemType"))
        JFormMap.setObj(JF_CompiledContents, FormKey, JM_ItemEntry)
      Endif
      FormKey = JFormMap.nextKey(JF_Contents)
    EndWhile
    j += 1
  EndWhile
  JValue.release(JF_CompiledContents)
  Return JF_CompiledContents
EndFunction

Int Function getBreakdownContents(Actor akTarget, Int aiTargetData = 0)
  {Gathers form-value pairs from breakdown contents types and returns them in new JFormMap}
  If MainBreakdownType > 0
    If JValue.isExists(aiTargetData)
      aiTargetData = SCXLib.getTargetData(akTarget)
    EndIf
    Int JF_CompiledContents = JValue.retain(JFormMap.object())
    Int JF_Breakdown = SCXLib.getContents(akTarget, MainBreakdownType, aiTargetData)
    JFormMap.addPairs(JF_CompiledContents, JF_Breakdown, True)
    Int j = 0
    Int NumItemTypes = ItemStoredTypes.length
    While j < NumItemTypes
      Int JF_Contents = SCXLib.getContents(akTarget, ItemStoredTypes[j], aiTargetData)
      Form FormKey = JFormMap.nextKey(JF_Contents)
      While FormKey
        Int JM_ItemEntry = JFormMap.getObj(JF_Contents, FormKey)
        If JMap.getInt(JM_ItemEntry, "StoredItemType") == MainBreakdownType
          JFormMap.setObj(JF_CompiledContents, FormKey, JM_ItemEntry)
        Endif
        FormKey = JFormMap.nextKey(JF_Contents)
      EndWhile
      j += 1
    EndWhile
    JValue.release(JF_CompiledContents)
    Return JF_CompiledContents
  Else
    Return 0
  EndIf
EndFunction

Int Function getBuildupContents(Actor akTarget, Int aiTargetData = 0)
  {Gathers form-value pairs from buildup contents types and returns them in new JFormMap}
  If MainBuildupType > 0
    If JValue.isExists(aiTargetData)
      aiTargetData = SCXLib.getTargetData(akTarget)
    EndIf
    Int JF_CompiledContents = JValue.retain(JFormMap.object())
    Int JF_Breakdown = SCXLib.getContents(akTarget, MainBuildupType, aiTargetData)
    JFormMap.addPairs(JF_CompiledContents, JF_Breakdown, True)
    Int j = 0
    Int NumItemTypes = ItemStoredTypes.length
    While j < NumItemTypes
      Int JF_Contents = SCXLib.getContents(akTarget, ItemStoredTypes[j], aiTargetData)
      Form FormKey = JFormMap.nextKey(JF_Contents)
      While FormKey
        Int JM_ItemEntry = JFormMap.getObj(JF_Contents, FormKey)
        If JMap.getInt(JM_ItemEntry, "StoredItemType") == MainBuildupType
          JFormMap.setObj(JF_CompiledContents, FormKey, JM_ItemEntry)
        Endif
        FormKey = JFormMap.nextKey(JF_Contents)
      EndWhile
      j += 1
    EndWhile
    JValue.release(JF_CompiledContents)
    Return JF_CompiledContents
  Else
    Return 0
  EndIf
EndFunction

Int Function getStoredContents(Actor akTarget, Int aiTargetData)
  {Gathers form-value pairs from storage types and returns them in new JFormMap}
  If MainStorageType > 0
    If !JValue.isExists(aiTargetData)
      aiTargetData = SCXLib.getTargetData(akTarget)
    EndIf
    Int JF_CompiledContents = JValue.retain(JFormMap.object())
    Int JF_Breakdown = SCXLib.getContents(akTarget, MainStorageType, aiTargetData)
    JFormMap.addPairs(JF_CompiledContents, JF_Breakdown, True)
    Int j = 0
    Int NumItemTypes = ItemStoredTypes.length
    While j < NumItemTypes
      Int JF_Contents = SCXLib.getContents(akTarget, ItemStoredTypes[j], aiTargetData)
      Form FormKey = JFormMap.nextKey(JF_Contents)
      While FormKey
        Int JM_ItemEntry = JFormMap.getObj(JF_Contents, FormKey)
        If JMap.getInt(JM_ItemEntry, "StoredItemType") == MainStorageType
          JFormMap.setObj(JF_CompiledContents, FormKey, JM_ItemEntry)
        Endif
        FormKey = JFormMap.nextKey(JF_Contents)
      EndWhile
      j += 1
    EndWhile
    JValue.release(JF_CompiledContents)
    Return JF_CompiledContents
  Else
    Return 0
  EndIf
EndFunction

Bool Function checkTransferItem(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
  Return False
EndFunction

Function displayTransferItemAccept(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
EndFunction

Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemType, Int aiStoredItemType = 0, Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
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
  Int ItemType = JMap.getInt(JM_ItemEntry, "ItemType")
  String Desc
  Int Index = ItemTypes.find(ItemType)
  If Index != -1
    Desc = ShortDescriptions[Index]
  Else
    SCX_BaseItemArchetypes Arch = getArchFromType(ItemType)
    If Arch
      Int Index2 = Arch.ItemTypes.find(ItemType)
      If Index2 != -1
        Desc = Arch.ShortDescriptions[Index]
      EndIf
    EndIf
  EndIf
  Float WeightValue = JMap.getFlt(JM_ItemEntry, "WeightValue")
  String Finished = Name + ": " + Desc + ": " + WeightValue
  Return Finished
EndFunction
