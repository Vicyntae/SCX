ScriptName SCLStomachArchetype Extends SCX_BaseItemArchetypes
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
Container Property SCL_VomitBase Auto

Function Setup()
  RegisterForModEvent("SCLProcessEvent", "OnDigestCall")
EndFunction

Function reloadMaintenence()
  RegisterForModEvent("SCLProcessEvent", "OnDigestCall")
EndFunction

Function removeAllActorItems(Actor akTarget, Bool ReturnItems = False);Rewrite of VomitAll function
  ObjectReference VomitContainer = performRemove(akTarget, False)

  Int i = ItemTypes.Length
  While i
    i -= 1
    Int JF_Contents = getContents(akTarget, ItemTypes[i])
    Form ItemKey = JFormMap.nextKey(JF_Contents)
    While ItemKey
      If ItemKey as Actor ;Always return actors
        SCXLib.extractActor(akTarget, ItemKey as Actor, ItemTypes[i], VomitContainer)
      ElseIf ItemKey as ObjectReference && ((ReturnItems && ItemTypes[i] == 1) || ItemTypes[i] == 2 )
        If ItemKey as SCX_Bundle ;Do we need to delete the SCL Bundle? or can we just move it into the container and erase it after it adds its contents?
           ;VomitContainer.AddItem(ItemKey as SCX_Bundle, 1, False)
          VomitContainer.AddItem((ItemKey as SCX_Bundle).ItemForm, (ItemKey as SCX_Bundle).ItemNum, False)
          (ItemKey as ObjectReference).Delete()
        Else
          VomitContainer.AddItem(ItemKey as ObjectReference, 1, False)
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
          SCXLib.extractActor(akTarget, ItemKey as Actor, ItemStoredTypes[i], VomitContainer)
        ElseIf ItemKey as ObjectReference  ;since we don't know what these are, always return them
          If ItemKey as SCX_Bundle ;Do we need to delete the SCL Bundle? or can we just move it into the container and erase it after it adds its contents?
            ;VomitContainer.AddItem(ItemKey as SCX_Bundle, 1, False)
            VomitContainer.AddItem((ItemKey as SCX_Bundle).ItemForm, (ItemKey as SCX_Bundle).ItemNum, False)
            (ItemKey as ObjectReference).Delete()
          Else
            VomitContainer.AddItem(ItemKey as ObjectReference, 1, False)
          EndIf
        EndIf
        JArray.addForm(JA_Remove, ItemKey)
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndWhile
    JF_eraseKeys(JF_Contents, JA_Remove)
  EndWhile
  JValue.release(JA_Remove)
  updateArchetype(akTarget)
  sendVomitEvent(akTarget, 1, False)
EndFunction

Function sendVomitEvent(Actor akTarget, Int aiVomitType, Bool bLeveledRemains, Form akSpecificItem = None)
  Int E = ModEvent.Create("SCLVomitEvent")
  ModEvent.PushForm(E, akTarget)
  ModEvent.PushInt(E, aiVomitType)
  ModEvent.PushBool(E, bLeveledRemains)
  ModEvent.PushForm(E, akSpecificItem)
  ModEvent.Send(E)
EndFunction

Function removeAmountActorItems(Actor akTarget, Float afRemoveAmount, Float afStoredRemoveChance = 0.0, Float afOtherRemoveChance = 0.0)
  {Might not remove exactly the right amount
  Stored items removed will not count towards this}
  Notice("vomitAmount beginning for " + nameGet(akTarget))
  ObjectReference VomitContainer = performRemove(akTarget, False)

  ;Remove part of afRemoveAmount from each entry
  Int JF_DigestContents = getContents(akTarget, 1)
  Int JA_Remove = JValue.retain(JArray.object())
  Int NumOfItems = JFormMap.count(JF_DigestContents)
  Float IndvRemoveAmount = afRemoveAmount / NumOfItems
  Float AmountRemoved
  Bool Break
  Form ItemKey = JFormMap.nextKey(JF_DigestContents)
  While AmountRemoved < afRemoveAmount && !Break
    If !ItemKey ;If we reach the end, start back at the beginning
      JF_eraseKeys(JF_DigestContents, JA_Remove)
      ItemKey = JFormMap.nextKey(JF_DigestContents)
      If !ItemKey
        Break = True
      EndIf
    EndIf
    If ItemKey as ObjectReference
      Int JM_ItemEntry = JFormMap.getObj(JF_DigestContents, ItemKey)
      If ItemKey as SCX_Bundle
        Float RemoveAmount = IndvRemoveAmount
        Bool Done ;If we finish off the item
        Float Indv = JMap.getFlt(JM_ItemEntry, "IndvWeightValue")
        Float Active = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue")
        Int ItemNum = (ItemKey as SCX_Bundle).ItemNum
        While RemoveAmount > 0 && !Done
          If Active > RemoveAmount ; Remove amount less that Active, ending loop
            Active -= RemoveAmount
            AmountRemoved += RemoveAmount
            RemoveAmount = 0
            JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Active)
            (ItemKey as SCX_Bundle).ItemNum = ItemNum
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
      ItemKey = JFormMap.nextKey(JF_DigestContents, ItemKey)
    EndIf
  EndWhile
  JF_eraseKeys(JF_DigestContents, JA_Remove)
  JA_Remove = JValue.release(JA_Remove)

  ;Randomly remove stored items
  If afStoredRemoveChance > 0
    JA_Remove = JValue.retain(JArray.object())
    Int JF_StoredContents = getContents(akTarget, 2)
    ItemKey = JFormMap.nextKey(JF_StoredContents)
    While ItemKey
      Int JM_ItemEntry = JFormMap.getObj(JF_StoredContents, ItemKey)
      Int Stored = JMap.getInt(JM_ItemEntry, "StoredItemType")
      If ItemTypes.find(Stored) != -1
        If ItemKey as ObjectReference
          Float FloatChance = Utility.RandomFloat()
          If FloatChance <= afStoredRemoveChance
            If ItemKey as Actor
              SCXLib.extractActor(akTarget, ItemKey as Actor, 2, VomitContainer)
            ElseIf ItemKey as SCX_Bundle
              ;VomitContainer.AddItem(ItemKey as SCX_Bundle, 1, False)
              VomitContainer.AddItem((ItemKey as SCX_Bundle).ItemForm, (ItemKey as SCX_Bundle).ItemNum, False)
              (ItemKey as ObjectReference).Delete()
            Else
              VomitContainer.AddItem(ItemKey as ObjectReference, 1, False)
            EndIf
            JArray.addForm(JA_Remove, ItemKey)
          EndIf
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_StoredContents, ItemKey)
    EndWhile
    JF_eraseKeys(JF_StoredContents, JA_Remove)
    JA_Remove = JValue.release(JA_Remove)
  EndIf

  ;Randomly remove other items
  If afOtherRemoveChance > 0
    Int i = ItemStoredTypes.length
    While i
      i -= 1
      Int JF_ContentsMap = getContents(akTarget, ItemStoredTypes[i])
      ItemKey = JFormMap.nextKey(JF_ContentsMap)
      JA_Remove = JValue.retain(JArray.object())
      While ItemKey
        If ItemKey as ObjectReference
          Float Chance = Utility.RandomFloat()
          If Chance <= afOtherRemoveChance
            If ItemKey as Actor
              SCXLib.extractActor(akTarget, ItemKey as Actor, ItemStoredTypes[i], VomitContainer)
            ElseIf ItemKey as SCX_Bundle
              ;VomitContainer.AddItem(ItemKey as SCX_Bundle, 1, False)
              VomitContainer.AddItem((ItemKey as SCX_Bundle).ItemForm, (ItemKey as SCX_Bundle).ItemNum, False)
              (ItemKey as ObjectReference).Delete()
            Else
              VomitContainer.AddItem(ItemKey as ObjectReference, 1, False)
            EndIf
            JArray.addForm(JA_Remove, ItemKey)
          EndIf
        EndIf
        ItemKey = JFormMap.nextKey(JF_ContentsMap, ItemKey)
      EndWhile
      JF_eraseKeys(JF_ContentsMap, JA_Remove)
      JA_Remove = JValue.release(JA_Remove)
    EndWhile
  EndIf
  sendVomitEvent(akTarget, 2, False)
  Notice("vomitAmount completed for " + nameGet(aktarget))
EndFunction

Function removeSpecificActorItems(Actor akTarget, Int aiItemType, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemCount = 1, Bool abDestroyDigestItems = True)
  {Finds given reference/baseitem and removes it from the give itemtype array.
  If itemtype is not a member of the archetype, then it searches the given itemtype array for the stored type.}
  Notice("vomitSpecificItem beginning for " + nameGet(akTarget))
  If !akReference && !akBaseObject
    Return
  EndIf
  If ItemTypes.find(aiItemType) != -1
    Int JF_Contents = getContents(akTarget, aiItemType)
    If akReference
      If JFormMap.hasKey(JF_Contents, akReference)
        ObjectReference VomitContainer = performRemove(akTarget, False)
        If akReference as Actor
          SCXLib.extractActor(akTarget, akReference as Actor, aiItemType, VomitContainer)
        ElseIf akReference as SCX_Bundle
          If !abDestroyDigestItems || aiItemType != 1
            VomitContainer.addItem((akReference as SCX_Bundle).ItemForm, (akReference as SCX_Bundle).ItemNum, False)
          EndIf
          akReference.Delete()
        Else
          If !abDestroyDigestItems || aiItemType != 1
            VomitContainer.AddItem(akReference as ObjectReference, 1, False)
          EndIf
          ;akReference.Delete()
        EndIf
        sendVomitEvent(akTarget, 3, False, akReference)
        JFormMap.removeKey(JF_Contents, akReference)
      EndIf
    Else
      SCX_Bundle Bundle = findBundle(JF_Contents, akBaseObject)
      If Bundle
        ObjectReference VomitContainer = performRemove(akTarget, False)
        Bool bEmpty = False
        Int AddItems = Bundle.ItemNum
        Bundle.ItemNum -= aiItemCount
        If Bundle.ItemNum > 0
          AddItems = aiItemCount
          bEmpty = True
        EndIf
        If !abDestroyDigestItems || aiItemType != 1
          VomitContainer.addItem(Bundle.ItemForm, AddItems, False)
        EndIf
        If bEmpty
          JFormMap.removeKey(JF_Contents, Bundle)
          Bundle.Delete()
        Else
          Int JM_ItemEntry = JFormMap.getObj(JF_Contents, Bundle)
          JMap.setFlt(JM_ItemEntry, "WeightValue", JMap.getFlt(JM_ItemEntry, "ActiveWeightValue") + (JMap.getFlt(JM_ItemEntry, "IndvWeightValue") * Bundle.ItemNum))
        EndIf
        sendVomitEvent(akTarget, 3, False, Bundle)
      EndIf
    EndIf
  Else
    Int JF_Contents = getContents(akTarget, aiItemType)
    Form ItemKey = JFormMap.nextKey(JF_Contents)
    While ItemKey
      Form BundleForm = (ItemKey as SCX_Bundle).ItemForm
      If akReference == ItemKey || akBaseObject == BundleForm || (akReference.GetBaseObject()) == BundleForm
        Int JM_ItemEntry = JFormMap.getObj(JF_Contents, ItemKey)
        Int Stored = JMap.getInt(JM_ItemEntry, "StoredItemType")
        If ItemTypes.find(Stored) != -1
          ObjectReference VomitContainer = performRemove(akTarget, False)
          If ItemKey as Actor
            SCXLib.extractActor(akTarget, akReference as Actor, aiItemType, VomitContainer)
          ElseIf ItemKey as SCX_Bundle
            VomitContainer.addItem((ItemKey as SCX_Bundle).ItemForm, (ItemKey as SCX_Bundle).ItemNum, False)
            akReference.Delete()
          Else
            VomitContainer.addITem(ItemKey, 1, False)
          EndIf
          sendVomitEvent(akTarget, 3, False, ItemKey)
          JFormMap.removeKey(JF_Contents, ItemKey)
        EndIf
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndWhile
  EndIf
EndFunction

ObjectReference Function performRemove(Actor akTarget, Bool bLeveledRemains)
  {Just plays the vomit animation, optionally puts down a vomit pile with leveled items}
  If akTarget == PlayerRef
    Game.ForceThirdPerson()
    Game.DisablePlayerControls()
  EndIf
  If SCXSet.FNISInstalled
    Debug.SendAnimationEvent(akTarget, "SCL_VomitEvent01")
    Utility.Wait(2.5)
    Debug.SendAnimationEvent(akTarget, "IdleForceDefaultState")
  Else
    Debug.SendAnimationEvent(akTarget, "shoutStart")
    Utility.Wait(1)
    Debug.SendAnimationEvent(akTarget, "shoutStop")
  EndIf
  If akTarget == PlayerRef
    Game.EnablePlayerControls()
  EndIf
  Return placeVomit(akTarget, bLeveledRemains)
EndFunction

ObjectReference Function placeVomit(ObjectReference akPosition, Bool abLeveled = False)
  ObjectReference Vomit
  Vomit = akPosition.PlaceAtMe(SCL_VomitBase)
  Vomit.MoveTo(akPosition, 64 * Math.Sin(akPosition.GetAngleZ()), 64 * Math.Cos(akPosition.GetAngleZ()), 0, False)
  Vomit.SetAngle(0, 0, 0)
  Return Vomit
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
      Int ChildEntry1 = UIList.AddEntryItem("Vomit Item", CurrentEntry, CurrentEntry)
      JIntMap.setStr(JI_OptionList, ChildEntry1, ArchName + "." + ItemType + ".Extract")
      Int ChildEntry2 = UIList.AddEntryItem("Switch Item State", CurrentEntry, CurrentEntry)
      JIntMap.setStr(JI_OptionList, ChildEntry2, ArchName + "." + ItemType + ".SwitchState")
    EndIf
    ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
  EndWhile
EndFunction

Bool Function HandleUIEActorContents(Actor akTarget, Form akItem, Int aiItemType, String asAction, Int aiMode = 0)
  If asAction == "Extract"
    removeSpecificActorItems(akTarget, aiItemType, akItem as ObjectReference, akItem)
    Return True
  ElseIf asAction == "SwitchState"
    If aiItemType == 2
      If akItem as SCX_Bundle
        Form BundleForm = (akItem as SCX_Bundle).ItemForm
        Int i = (akItem as SCX_Bundle).ItemNum
        If (BundleForm as Potion || BundleForm as Ingredient) && !SCLib.isNotFood(BundleForm)
          While i
            i -= 1
            akTarget.EquipItem(BundleForm, False, False)
          EndWhile
          Int JF_Stored = getContents(akTarget, 2)
          JFormMap.removeKey(JF_Stored, akItem)
          (akItem as ObjectReference).Delete()
          Return True
        ElseIf akItem as Actor || getPerkLevelDB(akTarget, "SCLExtractionExpert") >= 1
          SCLib.addItem(akTarget, BundleForm as ObjectReference, BundleForm, 1, aiItemCount = i)
          Int JF_Stored = getContents(akTarget, 2)
          JFormMap.removeKey(JF_Stored, akItem)
          (akItem as ObjectReference).Delete()
          Return True
        Else
          Debug.Notification("Actor unable to digest item.")
          Return False
        EndIf
      Else
        Form Base
        If akItem as ObjectReference
          Base = (akItem as ObjectReference).GetBaseObject()
        Else
          Base = akItem
        EndIf
        If (Base as Potion || Base as Ingredient) && !SCLib.isNotFood(Base)
          akTarget.EquipItem(akItem)
          Int JF_Stored = getContents(akTarget, 2)
          JFormMap.removeKey(JF_Stored, akItem)
          Return True
        ElseIf akItem as Actor || getPerkLevelDB(akTarget, "SCLExtractionExpert") >= 1
          SCLib.addItem(akTarget, akItem as ObjectReference, akItem, 1)
          Int JF_Stored = getContents(akTarget, 2)
          JFormMap.removeKey(JF_Stored, akItem)
          Return True
        Else
          Debug.Notification("Actor unable to digest item.")
          Return False
        EndIf
      EndIf
    Else
      Debug.Notification("Item must be digesting.")
      Return False
    EndIf
  EndIf
  Return False
EndFunction

Bool Function checkTransferItem(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
  Float WeightValue = SCXLib.genWeightValue(akBaseItem)
  Float CurrentWeight = JMap.getFlt(getTargetData(akTarget), "SCLFullness")
  Float MaxWeight = SCLib.getMaxCap(akTarget)
  If MaxWeight >= CurrentWeight + (WeightValue * aiItemCount)
    Return True
  Else
    Return False
  EndIf
EndFunction

;/Function displayTransferItemAccept(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
EndFunction/;

Function displayTransferItemReject(Actor akTarget, ObjectReference akItem, Form akBaseItem, Int aiItemCount = 1)
  If !PlayerThought(akTarget, "I can't fit that!", "You can't fit that!", PlayerRef.GetLeveledActorBase().GetName() + " can't fit that!")
    Debug.Notification("I'm sorry, but I can't fit that.")
  EndIf
EndFunction

Function addTransferItem(Actor akTarget, ObjectReference akItemReference = None, Form akBaseItem = None, Int aiItemCount = 1)
  Form BaseItem
  If akItemReference
    If akItemReference as Actor
      BaseItem = (akItemReference as Actor).GetLeveledActorBase()
    Else
      BaseItem = akItemReference.GetBaseObject()
    EndIf
  Else
    BaseItem = akBaseItem
  EndIf
  If (BaseItem as Potion || BaseItem as Ingredient) && !SCLib.isNotFood(BaseItem)
    addToContents(akTarget, akItemReference, akBaseItem, 1, aiItemCount)
  Else
    addToContents(akTarget, akItemReference, akBaseItem, 2, aiItemCount)
  EndIf
EndFunction

Event OnDigestCall(Form akForm, Float afTimePassed)
  If akForm as Actor
    breakdownItems(akForm as Actor, afTimePassed, getTargetData(akForm as Actor))
  EndIf
EndEvent

Function breakdownItems(Actor akTarget, Float afTimePassed, Int aiTargetData = 0)
  Int TargetData
  If !JValue.isMap(aiTargetData)
    TargetData = getTargetData(akTarget)
  Else
    TargetData = aiTargetData
  EndIf
  Int ItemList = getContents(akTarget, 1, TargetData)
  If !JValue.empty(ItemList)
    ;Note("Starting digestion for " + MyActor.GetLeveledActorBase().GetName())
    Float DigestRate = JMap.getFlt(TargetData, "SCLDigestRate")
    If DigestRate <= 0
      Notice("Digest Rate is zero! Canceling digestion.")
      Return
    EndIf
    Int JA_Remove = JValue.retain(JArray.object())
    Int NumOfItems = JFormMap.count(ItemList)
    Float IndvRemoveAmount = (DigestRate * afTimePassed * SCLSet.GlobalDigestMulti) / NumOfItems
    ;Notice("# Items = " + NumOfItems + ", Remove Amount/Item = " + IndvRemoveAmount)
    Float Fullness
    Float TotalDigested
    Form ItemKey = JFormMap.nextKey(ItemList)
    While ItemKey
      If ItemKey as ObjectReference
        Int JM_ItemEntry = JFormMap.getObj(ItemList, ItemKey)
        Float D = JMap.getFlt(JM_ItemEntry, "WeightValue")
        If D > 0

          If ItemKey as SCX_Bundle
            Int JM_DataEntry = SCXLib.getItemDatabaseEntry((ItemKey as SCX_Bundle).ItemForm)
            Float RemoveAmount = IndvRemoveAmount * JMap.getFlt(JM_DataEntry, "Durablity", 1)
            ;Note("SCX_Bundle found! Remove Amount = " + RemoveAmount)
            Float DigestedAmount = RemoveAmount
            Bool Done ;If we finish off the item
            Float Indv = JMap.getFlt(JM_ItemEntry, "IndvWeightValue")
            Float Active = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue")
            Int ItemNum = (ItemKey as SCX_Bundle).ItemNum
            While RemoveAmount > 0 && !Done
              If Active > RemoveAmount
                Active -= RemoveAmount
                ;Note("Ran out of RemoveAmount! Resetting WeightValue")
                RemoveAmount = 0  ;didn't manage to finish the stack before we ran out
                JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Active)
                (ItemKey as SCX_Bundle).ItemNum = ItemNum
                Float DValue = Active + (Indv * (ItemNum - 1))
                JMap.setFlt(JM_ItemEntry, "WeightValue", DValue)

                ;Float DValue = SCLib.updateDValue(JM_ItemEntry)


                Fullness += DValue
              Else
                RemoveAmount -= Active
                ;Debug.notification("Remove Amount = " + RemoveAmount)
                sendDigestItemFinishEvent(akTarget, (ItemKey as SCX_Bundle).ItemForm, Indv)
                JMap.setInt(TargetData, "SCLNumItemsDigested", JMap.getInt(TargetData, "SCLNumItemsDigested") + 1)
                Active = 0
                If ItemNum > 1  ;If there's more than 1 item left
                  ;Debug.notification("Item Number = " + ItemNum + ", resetting Active value")
                  ItemNum -= 1 ;Remove 1
                  Active = Indv ;Reset the active amount
                  ;Debug.notification("Active = " + Active)
                  ;Notice("More items found! Resetting active amount")
                Else
                  ;Debug.notification("Items finished.")
                  Done = True ;That was the last item
                  JArray.addForm(JA_Remove, ItemKey)
                  ;Don't have to reset dvalues, we're going to delete this
                  ;Notice("No more items left!")
                EndIf
              EndIf
            EndWhile
            DigestedAmount -= RemoveAmount  ;If there's anything left of the remove amount, subtract it from the digested amount
            TotalDigested += DigestedAmount
          Else
            ;Note("Regular reference found!")
            Float Active = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue")
            Float DigestedAmount = Active ;If it finishes the item, then it adds the active amount
            Int JM_DataEntry = SCXLib.getItemDatabaseEntry((ItemKey as SCX_Bundle).ItemForm)
            Float RemoveAmount = IndvRemoveAmount * JMap.getFlt(JM_DataEntry, "Durablity", 1)
            If Active > RemoveAmount ;Failed to remove everything from item
              Active -= RemoveAmount
              RemoveAmount = 0
              Fullness += Active
              JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Active)
              JMap.setFlt(JM_ItemEntry, "WeightValue", Active)
              ;Notice("Active amount = " + Active + ", resetting digest value")
              DigestedAmount -= RemoveAmount  ;If there's anything left of the remove amount, subtract it from the digested amount
              If ItemKey as Actor
                (ItemKey as Actor).DamageActorValue("Health", RemoveAmount)
              EndIf
            Else
              RemoveAmount -= Active ;Removed everything from the item
              Active = 0
              ;Notice("Active amount = " + Active + ", removing item")
              JArray.addForm(JA_Remove, ItemKey)
              sendDigestItemFinishEvent(akTarget, ItemKey, JMap.getFlt(JM_ItemEntry, "IndvWeightValue"))
              JMap.setInt(TargetData, "SCLNumItemsDigested", JMap.getInt(TargetData, "SCLNumItemsDigested") + 1)
            EndIf
            TotalDigested += DigestedAmount
          EndIf
        EndIf
      Else
        JArray.addForm(JA_Remove, ItemKey)
      EndIf
      Utility.WaitMenuMode(0.5)
      ItemKey = JFormMap.nextKey(ItemList, ItemKey)
    EndWhile
    ;Notice("Done processing items, setting final stats:")
    ;Maybe just run updateFullnessEX after digestion.
    ;JMap.setFlt(TargetData, "ContentsFullness1", Fullness)
    JMap.setFlt(TargetData, "STTotalDigestedFood", JMap.getFlt(TargetData, "STTotalDigestedFood") + TotalDigested)
    JMap.setFlt(TargetData, "STLastDigestAmount", TotalDigested)
    JF_eraseKeys(ItemList, JA_Remove)
    JA_Remove = JValue.release(JA_Remove)
    sendDigestFinishEvent(akTarget, TotalDigested)
  Else
    JMap.setFlt(TargetData, "ContentsFullness1", 0)
    JMap.setFlt(TargetData, "STLastDigestAmount", 0)
    sendDigestFinishEvent(akTarget, 0)
  EndIf
  updateArchetype(akTarget, TargetData)
EndFunction

Function sendDigestItemFinishEvent(Actor akEater, Form akFood, Float afWeightValue)
  If akFood as Actor
    (akFood as Actor).Kill(akEater)
    SCX_Library.eraseActorData(akFood as Actor)
  EndIf
  Int FinishEvent = ModEvent.Create("SCLDigestItemFinishEvent")
  ModEvent.PushForm(FinishEvent, akEater)
  ModEvent.PushForm(FinishEvent, akFood)
  ModEvent.PushFloat(FinishEvent, afWeightValue)
  ModEvent.Send(FinishEvent)
EndFunction

Function sendDigestFinishEvent(Actor akEater, Float afDigestedAmount)
  Int FinishEvent = ModEvent.Create("SCLDigestFinishEvent")
  ModEvent.PushForm(FinishEvent, akEater)
  ModEvent.PushFloat(FinishEvent, afDigestedAmount)
  ModEvent.Send(FinishEvent)
EndFunction

Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, Int aiItemType, Int aiStoredItemType = 0, Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
  Int JF_Contents = getContents(akTarget, aiItemType)
  Int JM_ItemEntry
  If akReference as SCX_Bundle
    Form BundleItem = (akReference as SCX_Bundle).ItemForm
    Note("Adding item " + nameGet(BundleItem) + " to actor " + nameGet(akTarget) + " as type 1")
    JM_ItemEntry = findBundleEntry(JF_Contents, BundleItem)
    If !JM_ItemEntry
      JM_ItemEntry = JMap.object()
      Float Weight = SCXLib.genWeightValue(BundleItem)
      JMap.setFlt(JM_ItemEntry, "WeightValue", Weight * (akReference as SCX_Bundle).ItemNum)
      JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
      JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
      JMap.setForm(JM_ItemEntry, "ItemReference", akReference) ;Redundancy, just in case you only have the ItemEntry
      JMap.setInt(JM_ItemEntry, "ItemType", aiItemType) ;again, redundancy
      JMap.setForm(JM_ItemEntry, "ItemOwner", akTarget)
      JMap.setInt(JM_ItemEntry, "StoredItemType", aiStoredItemType)

      JFormMap.setObj(JF_Contents, akReference, JM_ItemEntry)
      If abMoveNow
        akReference.MoveTo(SCLSet.SCL_HoldingCell)
      EndIf
    Else
      SCX_Bundle ItemBundle = JMap.getForm(JM_ItemEntry, "ItemReference") as SCX_Bundle
      ItemBundle.ItemNum += (akReference as SCX_Bundle).ItemNum
      Float Weight = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue") + (JMap.getFlt(JM_ItemEntry, "IndvWeightValue") * (ItemBundle.ItemNum - 1))
      JMap.setFlt(JM_ItemEntry, "WeightValue", Weight)
      akReference.Delete()
    EndIf
  ElseIf akReference
    Note("Adding item " + nameGet(akReference) + " to actor " + nameGet(akTarget) + " as type 1")
    Float Weight
    If afWeightValueOverride < 0
      Weight = SCXLib.genWeightValue(akReference.GetBaseObject())
    Else
      Weight = afWeightValueOverride
    EndIf
    JMap.setFlt(JM_ItemEntry, "WeightValue", Weight * (akReference as SCX_Bundle).ItemNum)
    JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
    JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
    JMap.setForm(JM_ItemEntry, "ItemReference", akReference) ;Redundancy, just in case you only have the ItemEntry
    JMap.setInt(JM_ItemEntry, "ItemType", aiItemType) ;again, redundancy
    JMap.setForm(JM_ItemEntry, "ItemOwner", akTarget)
    JMap.setInt(JM_ItemEntry, "StoredItemType", aiStoredItemType)

    JFormMap.setObj(JF_Contents, akReference, JM_ItemEntry)
    If abMoveNow
      akReference.MoveTo(SCLSet.SCL_HoldingCell)
    EndIf
  Else
    Note("Adding item " + nameGet(akBaseObject) + " to actor " + nameGet(akTarget) + " as type 1")
    JM_ItemEntry = findBundleEntry(JF_Contents, akBaseObject)
    If !JM_ItemEntry
      JM_ItemEntry = JMap.object()
      SCX_Bundle ItemBundle = SCLSet.SCL_HoldingCell.PlaceAtMe(SCXSet.SCX_BundleBase) as SCX_Bundle

      Float Weight = SCXLib.genWeightValue(akBaseObject)
      JMap.setFlt(JM_ItemEntry, "WeightValue", Weight * aiItemCount)
      JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
      JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
      JMap.setForm(JM_ItemEntry, "ItemReference", ItemBundle) ;Redundancy, just in case you only have the ItemEntry
      JMap.setInt(JM_ItemEntry, "ItemType", aiItemType) ;again, redundancy
      JMap.setForm(JM_ItemEntry, "ItemOwner", akTarget)
      JMap.setInt(JM_ItemEntry, "StoredItemType", aiStoredItemType)

      JFormMap.setObj(JF_Contents, ItemBundle, JM_ItemEntry)

      ItemBundle.AddItem(akBaseObject, 1, False)
      ItemBundle.ItemNum = aiItemCount
      ItemBundle.Owner = akTarget
      ItemBundle.ItemEntry = JM_ItemEntry
      JFormMap.setObj(JF_Contents, ItemBundle, JM_ItemEntry)
    Else
      SCX_Bundle ItemBundle = JMap.getForm(JM_ItemEntry, "ItemReference") as SCX_Bundle
      ItemBundle.ItemNum += aiItemCount
      Float Weight = JMap.getFlt(JM_ItemEntry, "ActiveWeightValue") + (JMap.getFlt(JM_ItemEntry, "IndvWeightValue") * (ItemBundle.ItemNum - 1))
      JMap.setFlt(JM_ItemEntry, "WeightValue", Weight)
    EndIf
  EndIf
  Return JM_ItemEntry
EndFunction
