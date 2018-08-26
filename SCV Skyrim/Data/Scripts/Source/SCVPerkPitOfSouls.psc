ScriptName SCVPerkPitOfSouls Extends SCX_BasePerk
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
Perk Property SoulSqueezer Auto
SCX_BasePerk Property SCV_SpiritSwallower Auto
SCX_BaseItemArchetypes Property Stomach Auto
Quest Property MGRArniel04 Auto
Quest Property MGRitual03 Auto
MiscObject Property SCV_DragonGem Auto
MiscObject Property SCV_SplendidSoulGem Auto
Soulgem Property SoulGemBlack Auto
Soulgem Property SoulGemBlackFilled Auto
Soulgem Property SoulGemGrand Auto
Soulgem Property SoulGemGrandFilled Auto
Soulgem Property SoulGemGreater Auto
Soulgem Property SoulGemGreaterFilled Auto
Soulgem Property SoulGemCommon Auto
Soulgem Property SoulGemCommonFilled Auto
Soulgem Property SoulGemLesser Auto
Soulgem Property SoulGemLesserFilled Auto
Soulgem Property SoulGemPetty Auto
Soulgem Property SoulGemPettyFilled Auto
MiscObject Property SoulGemPiece001 Auto
MiscObject Property SoulGemPiece002 Auto
MiscObject Property SoulGemPiece003 Auto
MiscObject Property SoulGemPiece004 Auto
MiscObject Property SoulGemPiece005 Auto
Function Setup()
  ;/Name = "Pit of Souls"
  Description = New String[4]
  Description[0] = "Enables one to capture enemy souls."
  Description[1] = "Enables one to capture enemy souls by storing soul gems in their stomach."
  Description[2] = "Soul gems can now capture souls one size bigger."
  Description[3] = "Soul gems can now capture souls two sizes bigger."

  Requirements = New String[4]
  Requirements[0] = "No Requirements."
  Requirements[1] = "Have at least 30 Enchanting, have at least Spirit Swallower Lv. 1, be at level 15, and have the perk 'Soul Squeezer'."
  Requirements[2] = "Have at least 55 Enchanting, have at least Spirit Swallower Lv. 2, be at level 30, capture at least 30 souls by devouring them, and assist a wizard in his studies into the Dwemer disappearance."
  Requirements[3] = "Have at least 90 Enchanting, be at level 50, capture at least 70 souls by devouring them, and become a master Conjurer."/;
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Int Enchant = PlayerRef.GetActorValue("Enchanting") as Int
  Int SpiritLevel = SCV_SpiritSwallower.getPerkLevel(akTarget)
  Int Level = akTarget.GetLevel()
  Int NumSoulsCaptured = JMap.getInt(aiTargetData, "SCV_SoulsCaptured")
  If aiPerkLevel == 1 && Enchant >= 30 && SpiritLevel >= 1 && Level >= 15 && PlayerRef.hasPerk(SoulSqueezer)
    Return True
  ElseIf aiPerkLevel == 2 && Enchant >= 55 && SpiritLevel >= 2 && Level >= 30 && NumSoulsCaptured >= 30 && MGRArniel04.IsCompleted() ;Complete Arniel's Endeavor
    Return True
  ElseIf aiPerkLevel == 3 && Enchant >= 90 && Level >= 50 && NumSoulsCaptured >= 70 && MGRitual03.IsCompleted()  ;Complete Conjuration Ritual Spell
    Return True
  EndIf
EndFunction

Bool Function isKnown(Actor akTarget)
  If SCVLib.isOVPred(PlayerRef)
    Return True
  Else
    Return False
  EndIf
EndFunction

Int Function genSoulSize(Actor akTarget)
  Race TargetRace = akTarget.GetRace()
  If TargetRace.HasKeyword(SCVSet.ActorTypeDwarven)
    Return 0
  EndIf
  Int Level = akTarget.GetLevel()
  If TargetRace.HasKeyword(SCVSet.ActorTypeDragon)
    Return 8
  ElseIf SCVLib.isBossActor(akTarget)
    Return 7
  ElseIf TargetRace.HasKeyword(SCVSet.ActorTypeNPC)
    Return 6
  ElseIf Level >= 38
    Return 5
  ElseIf Level >= 28
    Return 4
  ElseIf Level >= 16
    Return 3
  ElseIf Level >= 4
    Return 2
  ElseIf Level >= 1
    Return 1
  EndIf
EndFunction

Int Function fillGem(Actor akPred, Actor akPrey, Int aiTargetData = 0)
  {Searchs for a gem to fill and does so. Returns what kind of gem was filled.
  Returns -1 if a new gem was created, -2 if no gem was filled.}
  Int TargetData = getData(akPred, aiTargetData)
  Int PerkLevel = getPerkLevel(akPred) - 1 ;We subtract one because the first level enables the function, the others increase gem size
  If PerkLevel < 0
    Return 0
  EndIf
  Notice("Bonus Level = " + PerkLevel)
  Int SoulSize = genSoulSize(akPrey)
  If SoulSize == 0  ;Has no soul to begin with
    Return -2
  EndIf
  Notice("Soul Size = " + SoulSize)
  Int[] Gems = getGemList(akPred, aiTargetData = TargetData)
  Int i = SoulSize
  i -= PerkLevel
  If i <= -1  ;Inserts SoulGem fragment if they have the lv 2 perk
    Notice("Soul fill size is less than 0! Inserting new gem...")
    ;addItem(akPred, akBaseObject = getGemTypes(0)[Utility.RandomInt(0, 4)], aiItemType = 2)
    Return -1
  EndIf
  Int Num = Gems.length - 1
  Bool Done
  While i < Num && !Done
    If Gems[i] > 0  ;If there is a gem with size equal to or greater than the soul size
      Notice("Found fillable gem! Soul Size = " + SoulSize + ", Gem size = " + i)
      Float GemChance = JMap.getFlt(TargetData, "SCVGemBonusChance")
      Int AddGem = 1
      If GemChance > 0
        Bool Failed
        While !Failed && AddGem < 11  ;Max 10 addition gems
          Float Success = Utility.RandomInt()
          If Success < GemChance
            AddGem += 1
          Else
            Failed = True
          EndIf
        EndWhile
      EndIf
      replaceGem(akPred, i, SoulSize, aiNum = AddGem, aiTargetData = TargetData) ;input the original size and the new size
      Done = True
    Else
      i += 1
    EndIf
  EndWhile
  JMap.setInt(TargetData, "SCV_SoulsCaptured", JMap.getINt(TargetData, "SCV_SoulsCaptured") + 1)
  Return i
EndFunction

Bool Function hasGems(Actor akTarget, Int aiItemType = 2, Int aiTargetData = 0)
  {Returns if actor has valid soul gems located in contents 2, or whatever override
  Excludes dragon gems, as they can't be filled again}
  Int TargetData = getData(akTarget, aiTargetData)
  Int Contents = getContents(akTarget, aiItemType, TargetData)
  If JValue.empty(Contents)
    Return False
  EndIf
  Form i = JFormMap.nextKey(Contents)
  While i
    Form BaseObject
    If i as SCX_Bundle
      BaseObject = (i as SCX_Bundle).ItemForm
    ElseIf i as ObjectReference
      BaseObject = (i as ObjectReference).GetBaseObject()
    EndIf
    If BaseObject
      If BaseObject == SCV_SplendidSoulGem
        Return True
      ElseIf BaseObject == SoulGemBlack || BaseObject == SoulGemBlackFilled
        Return True
      ElseIf BaseObject == SoulGemGrand || BaseObject == SoulGemGrandFilled
        Return True
      ElseIf BaseObject == SoulGemGreater || BaseObject == SoulGemGreaterFilled
        Return True
      ElseIf BaseObject == SoulGemCommon || BaseObject == SoulGemCommonFilled
        Return True
      ElseIf BaseObject == SoulGemLesser || BaseObject == SoulGemLesserFilled
        Return True
      ElseIf BaseObject == SoulGemPetty || BaseObject == SoulGemPettyFilled
        Return True
      ElseIf BaseObject == SoulGemPiece001  || BaseObject == SoulGemPiece002 || BaseObject == SoulGemPiece003 || BaseObject == SoulGemPiece004 || BaseObject == SoulGemPiece005
        Return True
      EndIf
    EndIf
    i = JFormMap.nextKey(Contents, i)
  EndWhile
  Return False
EndFunction


Int[] Function getGemList(Actor akTarget, Int aiItemType = 2, Int aiTargetData = 0)
  {Returns array of soul gems located in contents 2, or whatever override
  Excludes dragon gems, as they can't be filled again}
  Int TargetData = getData(akTarget, aiTargetData)
  Int[] ReturnArray = New Int[8]
  Int Contents = getContents(akTarget, aiItemType, TargetData)
  If JValue.empty(Contents)
    Return ReturnArray
  EndIf
  Form i = JFormMap.nextKey(Contents)
  While i
    Form BaseObject
    If i as SCX_Bundle
      BaseObject = (i as SCX_Bundle).ItemForm
    ElseIf i as ObjectReference
      BaseObject = (i as ObjectReference).GetBaseObject()
    EndIf
    If BaseObject
      If BaseObject == SCV_SplendidSoulGem
        ReturnArray[7] = ReturnArray[7] + 1
      ElseIf BaseObject == SoulGemBlack || BaseObject == SoulGemBlackFilled
        ReturnArray[6] = ReturnArray[6] + 1
      ElseIf BaseObject == SoulGemGrand || BaseObject == SoulGemGrandFilled
        ReturnArray[5] = ReturnArray[5] + 1
      ElseIf BaseObject == SoulGemGreater || BaseObject == SoulGemGreaterFilled
        ReturnArray[4] = ReturnArray[4] + 1
      ElseIf BaseObject == SoulGemCommon || BaseObject == SoulGemCommonFilled
        ReturnArray[3] = ReturnArray[3] + 1
      ElseIf BaseObject == SoulGemLesser || BaseObject == SoulGemLesserFilled
        ReturnArray[2] = ReturnArray[2] + 1
      ElseIf BaseObject == SoulGemPetty || BaseObject == SoulGemPettyFilled
        ReturnArray[1] = ReturnArray[1] + 1
      ElseIf BaseObject == SoulGemPiece001  || BaseObject == SoulGemPiece002 || BaseObject == SoulGemPiece003 || BaseObject == SoulGemPiece004 || BaseObject == SoulGemPiece005
        ReturnArray[0] = ReturnArray[0] + 1
      EndIf
    EndIf
    i = JFormMap.nextKey(Contents, i)
  EndWhile
  Return ReturnArray
EndFunction

Form[] Function getGemTypes(Int aiSize)
  {Filled gems put in first}
  Form[] ReturnArray = new Form[5]
  If aiSize == 0
    ReturnArray[0] = SoulGemPiece001
    ReturnArray[1] = SoulGemPiece002
    ReturnArray[2] = SoulGemPiece003
    ReturnArray[3] = SoulGemPiece004
    ReturnArray[4] = SoulGemPiece005
  ElseIf aiSize == 1
    ReturnArray[0] = SoulGemPettyFilled
    ReturnArray[1] = SoulGemPetty
  ElseIf aiSize == 2
    ReturnArray[0] = SoulGemLesserFilled
    ReturnArray[1] = SoulGemLesser
  ElseIf aiSize == 3
    ReturnArray[0] = SoulGemCommonFilled
    ReturnArray[1] = SoulGemCommon
  ElseIf aiSize == 4
    ReturnArray[0] = SoulGemGreaterFilled
    ReturnArray[1] = SoulGemGreater
  ElseIf aiSize == 5
    ReturnArray[0] = SoulGemGrandFilled
    ReturnArray[1] = SoulGemGrand
  ElseIf aiSize == 6
    ReturnArray[0] = SoulGemBlackFilled
    ReturnArray[1] = SoulGemBlack
  ElseIf aiSize == 7
    ReturnArray[0] = SCV_SplendidSoulGem
  ElseIf aiSize == 8
    ReturnArray[0] = SCV_DragonGem
  EndIf
  Return ReturnArray
EndFunction

Function replaceGem(Actor akTarget, Int aiOriginal, Int aiNew, Int aiNum = 1, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Form[] OriginalArray = getGemTypes(aiOriginal)
  Form[] NewArray = getGemTypes(aiNew)
  If aiOriginal == 0
    Form Fragment = findGemFragment(akTarget, "Stomach", "Stored", TargetData)
    If Fragment
      Stomach.removeFromContents(akTarget, akBaseObject = Fragment, asType = "Stored", abDelete = True, aiTargetData = TargetData)
    Else
      Return
    EndIf
  ElseIf !Stomach.removeFromContents(akTarget, akBaseObject = OriginalArray[1], asType = "Stored", abDelete = True, aiTargetData = TargetData)
    If !Stomach.removeFromContents(akTarget, akBaseObject = OriginalArray[0], asType = "Stored", abDelete = True, aiTargetData = TargetData)
      Return
    EndIf
  EndIf
  Notice("Default soul size for new gem = " + (OriginalArray[0] as SoulGem).GetSoulSize())
  Stomach.addToContents(akTarget, akBaseObject = NewArray[0], asType = "Stored", aiItemCount = aiNum)  ;Choose filled gem/;
EndFunction

Form Function findGemFragment(Actor akTarget, String asArchetype, String asType, Int aiTargetData = 0)
  Int TargetData = getData(akTarget, aiTargetData)
  Int Contents = getContents(akTarget, asArchetype, asType, TargetData)
  Form SearchForm = JFormMap.nextKey(Contents)
  While SearchForm
    If SearchForm as ObjectReference
      Form CurrentForm
      If SearchForm as SCX_Bundle
        CurrentForm = (SearchForm as SCX_Bundle).ItemForm
      Else
        CurrentForm = (SearchForm as ObjectReference).GetBaseObject()
      EndIf
      If CurrentForm == SoulGemPiece001
        Return SoulGemPiece001
      ElseIf CurrentForm == SoulGemPiece002
        Return SoulGemPiece002
      ElseIf CurrentForm == SoulGemPiece003
        Return SoulGemPiece003
      ElseIf CurrentForm == SoulGemPiece004
        Return SoulGemPiece004
      ElseIf CurrentForm == SoulGemPiece005
        Return SoulGemPiece005
      EndIf
    EndIf
    SearchForm = JFormMap.nextKey(Contents, SearchForm)
  EndWhile
  Return None
EndFunction
