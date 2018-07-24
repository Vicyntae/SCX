ScriptName SCWColonArchetype Extends SCX_BaseItemArchetypes

Function removeAllActorItems(Actor akTarget, Bool ReturnItems = False);Rewrite of WF_SolidRemovePerform function
  ObjectReference WasteContainer = performRemove(akTarget, False)
  Int i = ItemTypes.Length
  While i
    i -= 1
    Int JF_Contents = getContents(akTarget, ItemTypes[i])
    Form ItemKey = JFormMap.nextKey(JF_Contents)
    While ItemKey
      If ItemKey as Actor
        extractActor(akTarget, ItemKey as Actor, ItemTypes[i], WasteContainer)
      ElseIf ItemKey as ObjectReference && ((ReturnItems && ItemTypes[i] == 3) || ItemTypes[i] == 4 )
        If ItemKey as SCLBundle ;Do we need to delete the SCL Bundle? or can we just move it into the container and erase it after it adds its contents?
          WasteContainer.AddItem((ItemKey as SCLBundle).ItemForm, (ItemKey as SCLBundle).NumItems, False)
          (ItemKey as ObjectReference).Delete()
        Else
          WasteContainer.AddItem(ItemKey as ObjectReference, 1, False)
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndWhile
    JValue.clear(JF_Contents)
  EndWhile

  i = ItemStoredTypes.Length
  Int JA_Remove
  While i
    i -= 1
    JA_Remove = JValue.releaseAndRetain(JA_Remove, JArray.object())
    Int JF_Contents = getContents(akTarget, ItemStoredTypes[i])
    Form ItemKey = JFormMap.nextKey(JF_Contents)
    While ItemKey
      Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
      Int Stored = JMap.getInt(JM_ItemEntry, "StoredItemType")
      If ItemTypes.find(Stored) != -1
        If ItemKey as Actor ;Always return actors
          extractActor(akTarget, ItemKey as Actor, ItemStoredTypes[i], WasteContainer)
        ElseIf ItemKey as ObjectReference  ;since we don't know what these are, always return them
          If ItemKey as SCLBundle ;Do we need to delete the SCL Bundle? or can we just move it into the container and erase it after it adds its contents?
            WasteContainer.AddItem((ItemKey as SCLBundle).ItemForm, (ItemKey as SCLBundle).NumItems, False)
            (ItemKey as ObjectReference).Delete()
          Else
            WasteContainer.AddItem(ItemKey as ObjectReference, 1, False)
          EndIf
        EndIf
        JArray.addForm(JA_Remove, ItemKey)
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndWhile
    JF_eraseKeys(JF_Contents, JA_Remove)
  EndWhile
  JValue.release(JA_Remove)
  SCXLib.UpdateAllContents(akTarget, TargetData)
  sendDefecateEvent(akTarget, 1, False)
EndFunction

Function removeAmountActorItems(Actor akTarget, Float afRemoveAmount, Bool abRemoveStored = False, Int aiStoredRemoveChance = 0, Bool abRemoveOtherItems = False, Int aiOtherRemoveChance = 0)
  {Might not remove exactly the right amount
  Stored items removed will not count towards this}
  Notice("defecateAmount beginning for " + nameGet(akTarget))
  ObjectReference WasteContainer = performRemove(akTarget, False)

  ;Remove part of afRemoveAmount from each entry
  Int JF_Contents = getContents(akTarget, 3)
  Int JA_Remove = JValue.retain(JArray.object())
  Int NumOfItems = JFormMap.count(JF_Contents)
  Float IndvRemoveAmount = afRemoveAmount / NumOfItems
  Float AmountRemoved
  Bool Break
  Form ItemKey = JFormMap.nextKey(JF_Contents)
  While AmountRemoved < afRemoveAmount && !Break
    If !ItemKey ;If we reach the end, start back at the beginning
      JF_eraseKeys(JF_Contents, JA_Remove)
      ItemKey = JFormMap.nextKey(JF_Contents)
      If !ItemKey ;If there truly is nothing left, stop.
        Break = True
      EndIf
    EndIf
    If ItemKey as ObjectReference
      Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
      If ItemKey as SCLBundle
        Float RemoveAmount = IndvRemoveAmount
        Bool Done ;If we finish off the item
        Float Indv = JMap.getFlt(JM_ItemEntry, "IndvWeightValue")
        Float Active = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue")
        Int ItemNum = (ItemKey as SCLBundle).NumItems
        While RemoveAmount > 0 && !Done
          If Active > RemoveAmount ; Remove amount less that Active, ending loop
            Active -= RemoveAmount
            AmountRemoved += RemoveAmount
            RemoveAmount = 0
            JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Active)
            (ItemKey as SCLBundle).NumItems = ItemNum
            Float DValue = Active + (Indv * (ItemNum - 1))
            JMap.setFlt(JM_ItemEntry, "WeightValue", DValue)
          Else
            RemoveAmount -= Active
            If ItemNum > 1
              ItemNum -= 1
              Active = Indv
            Else
              Done = True
              AmountRemoved += Active
              JArray.addForm(JA_Remove, ItemKey)
            EndIf
            Active = 0
          EndIf
        EndWhile
      Else
        Float Active = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue")
        If Active > IndvRemoveAmount
          Active -= IndvRemoveAmount
          AmountRemoved += IndvRemoveAmount
          JMap.setFlt(JM_ItemEntry, "WeightValue", Active)
          JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Active)
        Else
          AmountRemoved += Active ;Only add what was taken, not what was supposed to be taken
          JArray.addForm(JA_Remove, ItemKey)
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndIf
  EndWhile
  JF_eraseKeys(JF_Contents, JA_Remove)
  JA_Remove = JValue.release(JA_Remove)

  ;Randomly remove stored items
  If abRemoveStored && aiStoredRemoveChance != 0
    JA_Remove = JValue.retain(JArray.object())
    Int JF_StoredContents = getContents(akTarget, 4)
    ItemKey = JFormMap.nextKey(JF_StoredContents)
    While ItemKey
      Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
      Int Stored = JMap.getInt(JM_ItemEntry, "StoredItemType")
      If ItemTypes.find(Stored) != -1
        If ItemKey as ObjectReference
          Int Chance = Utility.RandomInt()
          If Chance <= aiStoredRemoveChance
            If ItemKey as Actor
              extractActor(akTarget, ItemKey as Actor, 4, WasteContainer)
            ElseIf ItemKey as SCLBundle
              WasteContainer.AddItem((ItemKey as SCLBundle).ItemForm, (ItemKey as SCLBundle).NumItems, False)
              (ItemKey as ObjectReference).Delete()
            Else
              WasteContainer.AddItem(ItemKey as ObjectReference, 1, False)
            EndIf
            JArray.addForm(JA_Remove, ItemKey)
          EndIf
        EndIf
      ItemKey = JFormMap.nextKey(JF_StoredContents, ItemKey)
    EndWhile
    JF_eraseKeys(JF_StoredContents, JA_Remove)
    JA_Remove = JValue.release(JA_Remove)
  EndIf

  ;Randomly remove other items
  If abRemoveOtherItems && aiOtherRemoveChance != 0
    Int i = StoredItemType.length
    While i
      i -= 1
      If i != 3 && i != 4
          Int JF_ContentsMap = getContents(akTarget, i)
          ItemKey = JFormMap.nextKey(JF_ContentsMap)
          JA_Remove = JValue.retain(JArray.object())
          While ItemKey
            Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
            Int Stored = JMap.getInt(JM_ItemEntry, "StoredItemType")
            If ItemTypes.find(Stored) != -1
              If ItemKey as ObjectReference
                Int Chance = Utility.RandomInt()
                If Chance <= aiOtherRemoveChance
                  If ItemKey as Actor
                    extractActor(akTarget, ItemKey as Actor, StoredItemType[i], WasteContainer)
                  ElseIf ItemKey as SCLBundle
                    WasteContainer.AddItem((ItemKey as SCLBundle).ItemForm, (ItemKey as SCLBundle).NumItems, False)
                    (ItemKey as ObjectReference).Delete()
                  Else
                    WasteContainer.AddItem(ItemKey as ObjectReference, 1, False)
                  EndIf
                  JArray.addForm(JA_Remove, ItemKey)
                EndIf
              EndIf
            ItemKey = JFormMap.nextKey(JF_ContentsMap, ItemKey)
          EndWhile
          JF_eraseKeys(JF_ContentsMap, JA_Remove)
          JA_Remove = JValue.release(JA_Remove)
        EndIf
      EndIf
    EndWhile
  EndIf
  sendDefecateEvent(akTarget, 2, False)
  Notice("defecateAmount completed for " + nameGet(aktarget))
EndFunction

Function removeSpecificActorItems(Actor akTarget, Int aiItemType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyDigestItems = True)
  {Finds given reference/baseitem and removes it from the give itemtype array.
  If itemtype is not a member of the archetype, then it searches the given itemtype array for the stored type.}
  Notice("defecateSpecificItem beginning for " + nameGet(akTarget))
  If !akReference && !akBaseObject
    Return
  EndIf
  If ItemTypes.find(aiItemType) != -1
    Int JF_Contents = getContents(akTarget, aiItemType)
    If akReference
      If JFormMap.hasKey(JF_Contents, akReference)
        ObjectReference WasteContainer = performRemove(akTarget, False)
        If akReference as Actor
          extractActor(akTarget, akReference as Actor, aiItemType, WasteContainer)
        ElseIf akReference as SCLBundle
          If !abDestroyDigestItems || aiItemType != 1
            WasteContainer.addItem((akReference as SCLBundle).ItemForm, (akReference as SCLBundle).NumItems, False)
          EndIf
          akReference.Delete()
        Else
          If !abDestroyDigestItems || aiItemType != 1
            WasteContainer.AddItem(akReference as ObjectReference, 1, False)
          EndIf
        EndIf
        sendDefecateEvent(akTarget, 3, False, akReference)
        JFormMap.removeKey(JF_ContentsMap, akReference)
      EndIf
    Else
      SCLBundle Bundle = ItemNum(JF_ContentsMap, akBaseObject)
      If Bundle
        ObjectReference WasteContainer = performRemove(akTarget, False)
        Bool bEmpty = False
        Int AddItems = Bundle.NumItems
        Bundle.NumItems -= aiItemCount
        If Bundle.NumItems > 0
          AddItems = aiItemCount
          bEmpty = True
        EndIf
        If !abDestroyDigestItems || aiItemType != 1
          WasteContainer.addItem(Bundle.ItemForm, AddItems, False)
        EndIf
        If bEmpty
          JFormMap.removeKey(JF_ContentsMap, Bundle)
          Bundle.Delete()
        Else
          Int JM_ItemEntry = JFormMap.getObj(JF_ContentsMap, Bundle)
          JMap.setFlt(JM_ItemEntry, "WeightValue", JMap.getFlt(JM_ItemEntry, "ActiveWeightValue") + (JMap.getFlt(JM_ItemEntry, "IndvWeightValue") * Bundle.NumItems))
        EndIf
        sendDefecateEvent(akTarget, 3, False, Bundle)
      EndIf
    EndIf
  Else
    Int JF_Contents = getContents(akTarget, aiItemType)
    Form ItemKey = JFormMap.nextKey(JF_Contents)
    While ItemKey
      Form BundleForm = (ItemKey as SCLBundle).ItemForm
      If akReference == ItemKey || akBaseObject == BundleForm || (akReference.GetBaseObject()) == BundleForm
        Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
        Int Stored = JMap.getInt(JM_ItemEntry, "StoredItemType")
        If ItemTypes.find(Stored) != -1
          ObjectReference WasteContainer = performRemove(akTarget, False)
          If ItemKey as Actor
            extractActor(akTarget, akReference as Actor, aiItemType, WasteContainer)
          ElseIf ItemKey as SCLBundle
            WasteContainer.addItem((ItemKey as SCLBundle).ItemForm, (ItemKey as SCLBundle).NumItems, False)
            akReference.Delete()
          Else
            WasteContainer.addItem(ItemKey, 1, False)
          EndIf
          sendDefecateEvent(akTarget, 3, False, ItemKey)
          JFormMap.removeKey(JF_ContentsMap, ItemKey)
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndWhile
  EndIf
EndFunction
