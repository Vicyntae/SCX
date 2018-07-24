ScriptName SCLItemType02 Extends SCX_BaseItemType

SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, Int aiStoredItemType = 0, Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
  Int JF_Contents = getContents(akTarget, ItemTypeID)
  Int JM_ItemEntry
  If akReference as SCX_Bundle
    Form BundleItem = (akReference as SCX_Bundle).ItemForm
    JM_ItemEntry = findBundleEntry(JF_Contents, BundleItem)
    If !JM_ItemEntry
      JM_ItemEntry = JMap.object()
      Float Weight = SCXLib.genWeightValue(BundleItem)
      JMap.setFlt(JM_ItemEntry, "WeightValue", Weight * (akReference as SCX_Bundle).ItemNum)
      JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
      JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
      JMap.setForm(JM_ItemEntry, "ItemReference", akReference) ;Redundancy, just in case you only have the ItemEntry
      JMap.setInt(JM_ItemEntry, "ItemType", ItemTypeID) ;again, redundancy
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
    JMap.setInt(JM_ItemEntry, "ItemType", ItemTypeID) ;again, redundancy
    JMap.setForm(JM_ItemEntry, "ItemOwner", akTarget)
    JMap.setInt(JM_ItemEntry, "StoredItemType", aiStoredItemType)

    JFormMap.setObj(JF_Contents, akReference, JM_ItemEntry)
    If abMoveNow
      akReference.MoveTo(SCLSet.SCL_HoldingCell)
    EndIf
  Else
    JM_ItemEntry = findBundleEntry(JF_Contents, akBaseObject)
    If !JM_ItemEntry
      JM_ItemEntry = JMap.object()
      SCX_Bundle ItemBundle = SCLSet.SCL_HoldingCell.PlaceAtMe(SCXSet.SCX_BundleBase) as SCX_Bundle

      Float Weight = SCXLib.genWeightValue(akBaseObject)
      JMap.setFlt(JM_ItemEntry, "WeightValue", Weight * aiItemCount)
      JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
      JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
      JMap.setForm(JM_ItemEntry, "ItemReference", ItemBundle) ;Redundancy, just in case you only have the ItemEntry
      JMap.setInt(JM_ItemEntry, "ItemType", ItemTypeID) ;again, redundancy
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
