ScriptName SCVStrugglingArchetype Extends SCX_BaseItemArchetypes

SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Form Property XMarker Auto
Spell Property SCV_HasStrugglePrey Auto
SCX_BaseBodyEdit Property Belly Auto

Float Function updateArchetype(Actor akTarget, Int aiTargetData = 0)
  SCVLib.checkPredSpells(akTarget)
  Return Parent.updateArchetype(akTarget, aiTargetData)

  ;/If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Float Total
  String sKey = _getStrKey()
  Int j = ItemTypes.Length
  Int JM_Weights = JValue.retain(JMap.object())
  While j
    j -= 1
    Int JF_Contents = getContents(akTarget, sKey, ItemTypes[j], aiTargetData)
    Form i = JFormMap.nextKey(JF_Contents)
    While i
      Int JM_ItemEntry = JFormMap.getObj(JF_Contents, i)
      String[] ArchPair = StringUtil.Split(JMap.getStr(JM_ItemEntry, "StoredItemType"), ".")
      Note("Updating Struggling: ArchPair0=" + ArchPair[0])
      Float WeightValue = JMap.getFlt(JM_ItemEntry, "WeightValue")
      JMap.setFlt(JM_Weights, ArchPair[0], JMap.getFlt(JM_Weights, ArchPair[0]) + WeightValue)
      Total += WeightValue
      i = JFormMap.nextKey(JF_Contents, i)
    EndWhile
  EndWhile
  If !JValue.empty(JM_Weights)
    String k = JMap.nextKey(JM_Weights)
    While k
      JMap.setFlt(aiTargetData, "SCVStruggleWeight" + k, JMap.getFlt(JM_Weights, k))
      k = JMap.nextKey(JM_Weights, k)
    EndWhile
  EndIf
  JM_Weights = JValue.release(JM_Weights)
  JMap.setFlt(aiTargetData, TotalWeightKey, Total)
  Belly.updateBodyPart(akTarget)
  Return Total/;
EndFunction

Function removeAllActorItems(Actor akTarget, Bool ReturnItems = False);Rewrite of VomitAll function
  Int TargetData = getTargetData(akTarget)
  SCX_BaseItemArchetypes Arch
  String sKey = _getStrKey()
  String LastDevoured = JMap.getStr(TargetData, "LastDevouredArchetype")
  If LastDevoured
    Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, LastDevoured) as SCX_BaseItemArchetypes
  ElseIf SCVSet.SCL_Installed
    Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, "Stomach") as SCX_BaseItemArchetypes
  ElseIf SCVSet.SCW_Installed
    Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, "Colon") as SCX_BaseItemArchetypes
  EndIf
  ObjectReference TargetPoint
  If Arch
    TargetPoint = Arch.performRemove(akTarget, False)
  Else
    ;Play animation here
    TargetPoint = akTarget.PlaceAtMe(XMarker, 1, False, False)
    TargetPoint.MoveTo(akTarget, 64 * Math.Sin(akTarget.GetAngleZ()), 64 * Math.Cos(akTarget.GetAngleZ()), 0, False)
    TargetPoint.SetAngle(0, 0, 0)
  EndIf
  Int i = ItemTypes.Length
  Int JA_ArchList = JValue.retain(JArray.object())
  While i
    i -= 1
    Int JF_Contents = getContents(akTarget, sKey, ItemTypes[i], TargetData)
    Form ItemKey = JFormMap.nextKey(JF_Contents)
    While ItemKey
      If ItemKey as Actor
        Int JM_Entry = JFormMap.getObj(JF_Contents, ItemKey)
        String[] ArchPair = StringUtil.Split(JMap.getStr(JM_Entry, "StoredItemType"), ".")
        Int JF_OtherContents = getContents(akTarget, ArchPair[0], "Struggle", TargetData)
        If JF_OtherContents
          JFormMap.removeKey(JF_OtherContents, ItemKey)
          If JArray.findStr(JA_ArchList, ArchPair[0]) == -1
            JArray.addStr(JA_ArchList, ArchPair[0])
          EndIf
        EndIf
        SCXLib.extractActor(akTarget, ItemKey as Actor, sKey, ItemTypes[i], TargetPoint)
      EndIf
      ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
    EndWhile
    JValue.clear(JF_Contents)
  EndWhile
  updateArchetype(akTarget)
  Int k = JArray.count(JA_ArchList)
  While k
    k -= 1
    SCX_BaseItemArchetypes UpdateArch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, JArray.getStr(JA_ArchList, k)) as SCX_BaseItemArchetypes
    If UpdateArch
      UpdateArch.updateArchetype(akTarget)
    EndIf
  EndWhile
  Int Handle = ModEvent.Create("SCVRemoveAllActorItemsEvent")
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushString(Handle, Arch._getStrKey())
  ModEvent.PushForm(Handle, TargetPoint)
  ModEvent.Send(Handle)
EndFunction

Int Function getPreyCounts(Actor akTarget, Int aiTargetData = 0)
  {Return JMap of preycounts under archetype names.}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int JM_Return = JValue.retain(JMap.object())
  Int JF_Contents = getContents(akTarget, _getStrKey(), "Breakdown", aiTargetData)
  Form i = JFormMap.nextKey(JF_Contents)
  While i
    Int JM_ItemEntry = JFormMap.getObj(JF_Contents, i)
    String[] ArchKeys = StringUtil.Split(JMap.getStr(JM_ItemEntry, "StoredItemType"), ".")
    JMap.setInt(JM_Return, ArchKeys[0], JMap.getInt(JM_Return, ArchKeys[0]) + 1)
    i = JFormMap.nextKey(JM_Return, i)
  EndWhile
  JValue.release(JM_Return)
  Return JM_Return
EndFunction

Int Function getPreyList(Actor akTarget, String asArchetypeOverride, Int aiTargetData = 0)
  {Return JFormMap of all prey.}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int JM_Return
  Int JF_Contents = getContents(akTarget, _getStrKey(), "Breakdown", aiTargetData)
  Form i = JFormMap.nextKey(JF_Contents)
  String ArchType = getArchFromVoreType(asArchetypeOverride)
  While i
    Int JM_Entry = JFormMap.getObj(JF_Contents, i)
    If asArchetypeOverride
      String[] ArchList = StringUtil.Split(JMap.getStr(JM_Entry, "StoredItemType"), ".")
      If ArchList[0] == ArchType
        JFormMap.setObj(JM_Return, i, JM_Entry)
      EndIf
    Else
      JFormMap.setObj(JM_Return, i, JM_Entry)
    EndIf
    i = JFormMap.nextKey(JF_Contents, i)
  EndWhile
  Return JM_Return
EndFunction

Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, String asType, String asStoredArchPlusType = "", Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
  Actor Pred = akTarget
  String sKey = _getStrKey()
  Actor Prey = akReference as Actor
  If !Pred || !Prey
    Return 0
  EndIf
  Int JM_ItemEntry
  Int PredData = getTargetData(Pred, True)
  Int PreyData = getTargetData(Prey, True)
  String[] StoredInfo = StringUtil.Split(asStoredArchPlusType, ".")
  SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, StoredInfo[0]) as SCX_BaseItemArchetypes
  If Arch
    Note("Found arch.")
    If Prey.IsDead() || Prey.IsUnconscious()
      Return Arch.addToContents(Pred, Prey, None, StoredInfo[1])
    Else
      Arch.addToContents(Pred, Prey, None, "Struggle", afWeightValueOverride = afWeightValueOverride, abMoveNow = False)
    EndIf
    Arch.updateArchetype(Pred)
  Else
    If Prey.IsDead() || Prey.IsUnconscious()
      Prey.Kill(Pred)
      Prey.SetAlpha(0, True)
      Prey.Delete()
      Return 0
    EndIf
  EndIf
  Float Weight
  If afWeightValueOverride < 0
    Weight = SCXLib.genWeightValue(akReference)
  Else
    Weight = afWeightValueOverride
  EndIf
  Int JF_Contents = getContents(akTarget, sKey, asType)

  JM_ItemEntry = JMap.object()
  JMap.setFlt(JM_ItemEntry, "WeightValue", Weight)
  JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
  JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
  JMap.setForm(JM_ItemEntry, "ItemReference", akReference) ;Redundancy, just in case you only have the ItemEntry
  JMap.setStr(JM_ItemEntry, "ItemType", sKey + "." + asType) ;again, redundancy
  JMap.setForm(JM_ItemEntry, "ItemOwner", akTarget)
  JMap.setStr(JM_ItemEntry, "StoredItemType", asStoredArchPlusType)

  JFormMap.setObj(JF_Contents, akReference, JM_ItemEntry)
  JMap.setForm(PreyData, "SCV_Pred", Pred)
  Int InsertEvent = ModEvent.Create("SCV_InsertEvent")
  ModEvent.PushForm(InsertEvent, Pred)
  ModEvent.PushForm(InsertEvent, Pred)
  ModEvent.PushString(InsertEvent, sKey + "." + asType)
  ModEvent.Send(InsertEvent)
  If asType == "Breakdown"
    If !Pred.HasSpell(SCV_HasStrugglePrey)
      Pred.addspell(SCV_HasStrugglePrey, True)
    EndIf
  EndIf
  updateArchetype(Pred)
  If Arch
    JMap.setStr(PredData, "LastDevouredArchetype", StoredInfo[0])
  EndIf
  Return JM_ItemEntry
EndFunction

String Function getArchFromVoreType(String asVoreType)
  If asVoreType == "Oral"
    Return "Stomach"
  ElseIf asVoreType == "Anal"
    Return "Colon"
  ElseIf asVoreType == "Unbirth"
    Return "Uterus"
  ElseIf asVoreType == "Cock"
    Return "Scrotum"
  EndIf
EndFunction

String Function getVoretypeFromArch(String asArchetype)
  If asArchetype == "Stomach"
    Return "Oral"
  ElseIf asArchetype == "Colon"
    Return "Anal"
  ElseIf asArchetype == "Uterus"
    Return "Unbirth"
  ElseIf asArchetype == "Scrotum"
    Return "Cock"
  EndIf
EndFunction

String Function getItemListDesc(Form akItem, Int JM_ItemEntry)
  String Name = (akItem as Actor).GetLeveledActorBase().GetName()
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

  Float Energy = SCVLib.getPreyEnergy(akItem as Actor)
  Float WeightValue = JMap.getFlt(JM_ItemEntry, "WeightValue")
  String Finished = Name + ": " + Desc + ": " + Energy + ", " + WeightValue
  Return Finished
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
  addToContents(akTarget, akItemReference, akBaseItem, "Stored", aiItemCount)
EndFunction
