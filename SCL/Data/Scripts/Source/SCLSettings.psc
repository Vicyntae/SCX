ScriptName SCLSettings Extends Quest
{Holds settings and properties}
;Item Process Settings ---------------------------------------------------------
GlobalVariable Property SCL_SET_GlobalDigestMulti Auto ;Default = 1.0
Float Property GlobalDigestMulti
  Float Function Get()
    Return SCL_SET_GlobalDigestMulti.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      SCL_SET_GlobalDigestMulti.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property  SCL_SET_AdjBaseMulti Auto  ;Default 1.0
Float Property AdjBaseMulti
  Float Function Get()
    Return SCL_SET_AdjBaseMulti.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val > 0
      SCL_SET_AdjBaseMulti.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

;Expansion Settings ------------------------------------------------------------
GlobalVariable Property SCL_SET_DefaultExpandTimer Auto ;Default 2
Float Property DefaultExpandTimer
  Float Function Get()
    Return SCL_SET_DefaultExpandTimer.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val >= 0
      SCL_SET_DefaultExpandTimer.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCL_SET_DefaultExpandBonus Auto ;Default 0.5
Float Property DefaultExpandBonus
  Float Function Get()
    Return SCL_SET_DefaultExpandBonus.GetValue()
  EndFunction
  Function Set(Float a_val)
    SCL_SET_DefaultExpandBonus.SetValue(a_val)
  EndFunction
EndProperty

;Dummy Items -------------------------------------------------------------------
;Marked as "Not Food"
Potion Property SCL_DummyNotFoodSmall Auto
Potion Property SCL_DummyNotFoodMedium Auto
Potion Property SCL_DummyNotFoodLarge Auto

;Vomit Properties
Container Property SCL_VomitBase Auto
Container Property SCL_VomitLeveledBase Auto
Spell Property SCL_VomitDamageSpell Auto
MagicEffect Property SCL_VomitDamageEffect Auto

;Cell References
ObjectReference Property SCL_HoldingCell
  ObjectReference Function Get()
    If SCX_Library.isModInstalled("Skyrim.esm")
      Return Game.GetFormFromFile(0x00032AFB, "Skyrim.esm") as ObjectReference
    EndIf
  EndFunction
EndProperty

Spell[] Property SCL_OverfullSpellArray Auto

;Spell[] Property SCL_HeavySpeedArray Auto

Spell[] Property SCL_StoredDamageArray Auto

Int Property JM_SmallItemAnimList
  Int Function Get()
    Int ArchList = JDB.solveObj(".SCX_ExtraData.JM_SmallItemAnimList")
    If !JValue.isExists(ArchList) || !JValue.isMap(ArchList)
      ArchList = JMap.object()
      JDB.solveObjSetter(".SCX_ExtraData.JM_SmallItemAnimList", ArchList, True)
      Int Handle = ModEvent.Create("SCV_BuildSCLSmallAnimList")
      ModEvent.Send(Handle)
    EndIf
    Return ArchList
  EndFunction
EndProperty
