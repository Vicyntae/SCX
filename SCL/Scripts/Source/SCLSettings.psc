ScriptName SCLSettings Extends SCX_BaseSettings
{Holds settings and properties}
;Item Process Settings ---------------------------------------------------------
GlobalVariable Property SCL_SET_GlobalDigestMulti Auto ;Default = 1.0
Float Property GlobalDigestMulti
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "GlobalDigestMulti")
      JMap.setFlt(JM_Settings, "GlobalDigestMulti", 1)
      SCL_SET_GlobalDigestMulti.SetValue(1)
    EndIf
    Float GloVar = SCL_SET_GlobalDigestMulti.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "GlobalDigestMulti")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "GlobalDigestMulti", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val > 0
      JMap.setFlt(JM_Settings, "GlobalDigestMulti", a_val)
      SCL_SET_GlobalDigestMulti.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property  SCL_SET_AdjBaseMulti Auto  ;Default 1.0
Float Property AdjBaseMulti
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "AdjBaseMulti")
      JMap.setFlt(JM_Settings, "AdjBaseMulti", 1)
      SCL_SET_AdjBaseMulti.SetValue(1)
    EndIf
    Float GloVar = SCL_SET_AdjBaseMulti.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "AdjBaseMulti")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "AdjBaseMulti", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val > 0
      JMap.setFlt(JM_Settings, "AdjBaseMulti", a_val)
      SCL_SET_AdjBaseMulti.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

;Expansion Settings ------------------------------------------------------------
GlobalVariable Property SCL_SET_DefaultExpandTimer Auto ;Default 2
Float Property DefaultExpandTimer
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "DefaultExpandTimer")
      JMap.setFlt(JM_Settings, "DefaultExpandTimer", 2)
      SCL_SET_DefaultExpandTimer.SetValue(0.5)
    EndIf
    Float GloVar = SCL_SET_DefaultExpandTimer.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "DefaultExpandTimer")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "DefaultExpandTimer", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val > 0
      JMap.setFlt(JM_Settings, "DefaultExpandTimer", a_val)
      SCL_SET_DefaultExpandTimer.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property SCL_SET_DefaultExpandBonus Auto ;Default 0.5
Float Property DefaultExpandBonus
  Float Function Get()
    If !JMap.hasKey(JM_Settings, "DefaultExpandBonus")
      JMap.setFlt(JM_Settings, "DefaultExpandBonus", 0.5)
      SCL_SET_DefaultExpandBonus.SetValue(0.5)
    EndIf
    Float GloVar = SCL_SET_DefaultExpandBonus.GetValue()
    Float MapVar = JMap.getFlt(JM_Settings, "DefaultExpandBonus")
    If GloVar != MapVar
      MapVar = GloVar
      JMap.setFlt(JM_Settings, "DefaultExpandBonus", MapVar)
    EndIf
    Return MapVar
  EndFunction

  Function Set(Float a_val)
    If a_val > 0
      JMap.setFlt(JM_Settings, "DefaultExpandBonus", a_val)
      SCL_SET_DefaultExpandBonus.SetValue(a_val)
    EndIf
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
