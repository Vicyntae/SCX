ScriptName SCVStrugglingArchetype Extends SCX_BaseItemArchetypes

SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto

Function removeAllActorItems(Actor akTarget, Bool ReturnItems = False);Rewrite of VomitAll function
  Int TargetData = getTargetData(akTarget)
  SCX_BaseItemArchetypes Arch
  String LastDevoured = JMap.getStr(TargetData, "LastDevouredArchetype")
  If LastDevoured
    Arch = getSCX_BaseAlias(JM_BaseArchetypes, LastDevoured) as SCX_BaseItemArchetypes
  ElseIf SCVSet.SCL_Installed
    Arch = getSCX_BaseAlias(JM_BaseArchetypes, "Stomach") as SCX_BaseItemArchetypes
  ElseIf SCVSet.SCW_Installed
    Arch = getSCX_BaseAlias(JM_BaseArchetypes, "Colon") as SCX_BaseItemArchetypes
  EndIf
  ObjectReference TargetPoint
  If Arch
    TargetPoint = Arch.performRemove(akTarget, False)
  Else
    ;Play animation here
    TargetPoint = akTarget.PlaceAtMe(XMarker, 1, False, False)
    Vomit.MoveTo(akTarget, 64 * Math.Sin(akTarget.GetAngleZ()), 64 * Math.Cos(akTarget.GetAngleZ()), 0, False)
    Vomit.SetAngle(0, 0, 0)
  EndIf
  Int JF_Contents = getContents(akTarget, sKey, ItemTypes[0], TargetData)
  Form ItemKey = JFormMap.nextKey(JF_Contents)
  While ItemKey
    If ItemKey as Actor
      SCXLib.extractActor(akTarget, ItemKey as Actor, sKey, ItemTypes[0], TargetPoint)
    EndIf
    ItemKey = JFormMap.nextKey(JF_Contents, ItemKey)
  EndWhile
  JValue.clear(JF_Contents)
  updateArchetype(akTarget)
  Int Handle = ModEvent.Create(SCVRemoveAllActorItemsEvent)
  ModEvent.PushForm(Handle, akTarget)
  ModEvent.PushString(Handle, Arch._getStrKey)
  ModEvent.PushForm(Handle, TargetPoint)
  ModEvent.Send(Handle)
EndFunction

Int Function getPreyCounts(Actor akTarget, Int aiTargetData = 0)
  {Return JMap of preycounts under archetype names.}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
EndFunction

Int Function getPreyList(Actor akTarget, String asArchetypeOverride, Int aiTargetData = 0)
  {Return JFormMap of all prey.}
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
EndFunction

Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, String asType, String asStoredArchPlusType = "", Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
  Note("Prey insertion commencing. Pred = " + nameGet(Pred) + ", Prey = " + nameGet(Prey) + ", Item Type = " + asType)
  Actor Pred = akTarget
  String sKey = _getStrKey()
  Actor Prey = akReference as Actor
  If !Pred || !Prey
    Return 0
  EndIf
  Int JM_ItemEntry
  Int PredData = getTargetData(Pred)
  Int PreyData = getTargetData(Prey)
  String[] StoredInfo = StringUtil.Split(asStoredArchPlusType, ".")
  If Prey.isDead() || Prey.IsUnconscious()
    If StoredInfo[0] == "Stomach"
      If SCVSet.SCL_Installed
        SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, "Stomach") as SCX_BaseItemArchetypes
        If Arch
          JM_ItemEntry = Arch.addToContents(Pred, Prey, None, StoredInfo[1], abMoveNow = Prey == PlayerRef)
        EndIf
      Else
        ;Delete actor? and add exp?
      EndIf
    ElseIf StoredInfo[0] == "Colon"
      If SCVSet.SCW_Installed
        SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, "Colon") as SCX_BaseItemArchetypes
        If Arch
          JM_ItemEntry = Arch.addToContents(Pred, Prey, None, StoredInfo[1], abMoveNow = Prey == PlayerRef)
        EndIf
      EndIf
    ;ElseIf
    EndIf
  Else
    Int JF_Contents = getContents(akTarget, sKey, "Breakdown")
    Float PreyStamina = Prey.GetActorValue("Stamina")
    Float PreyMagicka = Prey.GetActorValue("Magicka")
    Float PreyHealth = Prey.GetActorValue("Health")

    Float PreyStaminaBase = Prey.GetBaseActorValue("Stamina")
    Float PreyMagickaBase = Prey.GetBaseActorValue("Magicka")
    Float PreyHealthBase = Prey.GetBaseActorValue("Health")

    Float PredStamina = Pred.GetActorValue("Stamina")
    Float PredMagicka = Pred.GetActorValue("Magicka")
    Float PredHealth = Pred.GetActorValue("Health")

    Float PredStaminaBase = Pred.GetBaseActorValue("Stamina")
    Float PredMagickaBase = Pred.GetBaseActorValue("Magicka")
    Float PredHealthBase = Pred.GetBaseActorValue("Health")

    SCVLib.setProxy(Pred, "Stamina", PredStamina, PredData)
    SCVLib.setProxy(Pred, "Magicka", PredMagicka, PredData)
    SCVLib.setProxy(Pred, "Health", PredHealth, PredData)

    SCVLib.setProxyBase(Pred, "Stamina", PredStaminaBase, PredData)
    SCVLib.setProxyBase(Pred, "Magicka", PredMagickaBase, PredData)
    SCVLib.setProxyBase(Pred, "Health", PredHealthBase, PredData)

    SCVLib.setProxy(Prey, "Stamina", PreyStamina, PreyData)
    SCVLib.setProxy(Prey, "Magicka", PreyMagicka, PreyData)
    SCVLib.setProxy(Prey, "Health", PreyHealth, PreyData)

    SCVLib.setProxyBase(Prey, "Stamina", PreyStaminaBase, PreyData)
    SCVLib.setProxyBase(Prey, "Magicka", PreyMagickaBase, PreyData)
    SCVLib.setProxyBase(Prey, "Health", PreyHealthBase, PreyData)

    Float Weight
    If afWeightValueOverride < 0
      Weight = SCXLib.genWeightValue(akReference.GetBaseObject())
    Else
      Weight = afWeightValueOverride
    EndIf
    JM_ItemEntry = JMap.object()
    JMap.setFlt(JM_ItemEntry, "WeightValue", Weight * (akReference as SCX_Bundle).ItemNum)
    JMap.setFlt(JM_ItemEntry, "ActiveWeightValue", Weight)
    JMap.setFlt(JM_ItemEntry, "IndvWeightValue", Weight)
    JMap.setForm(JM_ItemEntry, "ItemReference", akReference) ;Redundancy, just in case you only have the ItemEntry
    JMap.setStr(JM_ItemEntry, "ItemType", sKey + "." + "Breakdown") ;again, redundancy
    JMap.setForm(JM_ItemEntry, "ItemOwner", akTarget)
    JMap.setStr(JM_ItemEntry, "StoredItemType", asStoredArchPlusType)
    JFormMap.setObj(JF_Contents, akReference, JM_ItemEntry)

    Int InsertEvent = ModEvent.Create("SCV_InsertEvent")
    ModEvent.PushForm(InsertEvent, Pred)
    ModEvent.PushForm(InsertEvent, Pred)
    ModEvent.PushString(InsertEvent, sKey + "." + "Breakdown")
    ModEvent.Send(InsertEvent)

    If abMoveNow
      SCVLib.addToFollow(Prey)
    EndIf

    SCVSet.SCV_InVoreActionList.RemoveAddedForm(Pred)
    SCVSet.SCV_InVoreActionList.RemoveAddedForm(Prey)

    SCVLib.ResumeFollowPred()

  EndIf
  updateArchetype(Pred)
  SCX_BaseItemArchetypes Arch = getSCX_BaseAlias(SCXSet.JM_BaseArchetypes, StoredInfo[0]) as SCX_BaseItemArchetypes
  If Arch
    JMap.setStr(PredData, "LastDevouredArchetype", StoredInfo[0])
  EndIf
  Return JM_ItemEntry
EndFunction
