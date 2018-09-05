ScriptName SCNSettings Extends SCX_BaseQuest

Spell Property SCN_CalorieUseTracker Auto

GlobalVariable Property  SCN_SET_CalorieGainMulti Auto  ;Default 1.0
Float Property GlobalCalorieGainMulti
  Float Function Get()
    Return SCN_SET_CalorieGainMulti.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val > 0
      SCN_SET_CalorieGainMulti.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

GlobalVariable Property  SCN_SET_CalorieLossMulti Auto  ;Default 1.0
Float Property GlobalCalorieUseMulti
  Float Function Get()
    Return SCN_SET_CalorieLossMulti.GetValue()
  EndFunction
  Function Set(Float a_val)
    If a_val > 0
      SCN_SET_CalorieLossMulti.SetValue(a_val)
    EndIf
  EndFunction
EndProperty

Bool _SCL_Installed
Bool Property SCL_Installed
  Bool Function Get()
    Return _SCL_Installed
  EndFunction
  Function Set(Bool abValue)
    If abValue != _SCL_Installed
      If abValue == True
        ;Add stuff for SCL Here
      Else
        ;Remove stuff for SCL Here
      EndIf
      _SCL_Installed = abValue
    EndIf
  EndFunction
EndProperty

Formlist Property SCN_MalnourishSpellList Auto
Formlist Property SCN_HungerDamageList Auto
Formlist Property SCN_WellFeedBuffList Auto
FormList Property SCN_TiredSpellList Auto
