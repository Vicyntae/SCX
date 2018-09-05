ScriptName SCN_Monitor Extends ActiveMagicEffect
SCX_Library Property SCXLib Auto
SCNLibrary Property SCNLib Auto
SCNSettings Property SCNSet Auto
SCX_Settings Property SCXSet Auto
Actor Property PlayerRef Auto
Int ActorData
Actor _myactor
Actor Property MyActor
  Actor Function Get()
    Return _myactor
  EndFunction
  Function Set(Actor akValue)
    _myactor = akValue
    ActorData = SCXSet.getTargetData(akValue)
  EndFunction
EndProperty

Float MinMealValue = 2.0

String Property DebugName
  String Function Get()
    If MyActor
      Return "[SCNCalorieUse " + MyActor.GetLeveledActorBase().GetName() + "] "
    Else
      Return "[SCNCalorieUse] "
    EndIf
  EndFunction
EndProperty
Bool EnableDebugMessages

Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  RegisterForSingleUpdate(30)
  LastUpdateTime = Utility.GetCurrentGameTime()
  RegisterForModEvent("SCLDigestFinishEvent", "OnSCLDigestFinish")
  If MyActor == PlayerRef
    RegisterForSleep()
  EndIf
EndEvent

Event OnSCLDigestFinish(Form akEater, Float afDigestedAmount, Float afSolidDigest, Float afLiquidDigest, Float afEnergyDigest)
  If afEnergyDigest
    SCNLib.addCalories(MyActor, afEnergyDigest)
  EndIf
EndEvent

Float PlayerSleepStartTime = -1.0
Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
  PlayerSleepStartTime = afSleepStartTime
EndEvent

Event OnSleepStop(bool abInterrupted)
  Float CurrentUpdateTime = Utility.GetCurrentGameTime()
  If PlayerSleepStartTime > 0
    Float TimePassed = ((CurrentUpdateTime - PlayerSleepStartTime)*24) ;In hours
    JMap.setFlt(ActorData, "SCNTimeSlept", JMap.getFlt(ActorData, "SCNTimeSlept") + TimePassed)
  EndIf
  PlayerSleepStartTime = -1
EndEvent

Float Property LastUpdateTime
  Float Function Get()
    If ActorData
      Return JMap.getFlt(ActorData, "SCNMonitorLastUpdateTime")
    Else
      Return -1
    EndIf
  EndFunction
  Function Set(Float afValue)
    If ActorData
      Return JMap.setFlt(ActorData, "SCNMonitorLastUpdateTime", afValue)
    EndIf
  EndFunction
EndProperty

Float Property LastWellnessUpdateTime
  Float Function Get()
    If ActorData
      Return JMap.getFlt(ActorData, "SCNMonitorLastWellnessUpdateTime")
    Else
      Return -1
    EndIf
  EndFunction
  Function Set(Float afValue)
    If ActorData
      Return JMap.setFlt(ActorData, "SCNMonitorLastWellnessUpdateTime", afValue)
    EndIf
  EndFunction
EndProperty

Float Property LastMealUpdateTime
  Float Function Get()
    If ActorData
      Return JMap.getFlt(ActorData, "SCNMonitorLastMealUpdateTime")
    Else
      Return -1
    EndIf
  EndFunction
  Function Set(Float afValue)
    If ActorData
      Return JMap.setFlt(ActorData, "SCNMonitorLastMealUpdateTime", afValue)
    EndIf
  EndFunction
EndProperty

Event OnUpdate()
  RegisterForSingleUpdate(30)
  Float CurrentUpdateTime = Utility.GetCurrentGameTime()
  Float TimePassed = ((CurrentUpdateTime - LastUpdateTime)*24) ;In hours
  LastUpdateTime = CurrentUpdateTime
  Float Calories = JMap.getInt(ActorData, "SCNWeightValue") * 17 * TimePassed
  SCNLib.expendCalories(MyActor, Calories)

  Float MealTimePassed = ((CurrentUpdateTime - LastMealUpdateTime)*24) ;In hours
  If MealTimePassed >= 6
    Float MealValue = JMap.getFlt(ActorData, "SCNMealCalores")
    If MealValue < MinMealValue
      SCNLib.addHungerDamage(MyActor, ActorData)
    Else
      JMap.setInt(ActorData, "SCNMealCount", JMap.getInt(ActorData, "SCNMealCount") + 1)
      SCNLib.removeHungerDamage(MyActor, ActorData)
    EndIf
    LastMealUpdateTime = CurrentUpdateTime
  EndIf

  Float FullTimePassed = ((CurrentUpdateTime - LastWellnessUpdateTime)*24) ;In hours
  If FullTimePassed >= 24
    LastWellnessUpdateTime = CurrentUpdateTime
    SCNLib.updateWellness(MyActor, ActorData)
    If JMap.getInt(ActorData, "SCNMealCount") >= 3
      (SCNSet.SCN_WellFeedBuffList.GetAt(1) as Spell).Cast(MyActor)
    EndIf
    JMap.setInt(ActorData, "SCNMealCount", 0)
  EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  OnUpdate()
  If akBaseObject as Potion || akBaseObject as Ingredient
    Int JM_Entry = SCNLib.getItemDatabaseEntry(akBaseObject)
    If JMap.getInt(JM_Entry, "STIsNotFood") == 0 || (akBaseObject as Potion).IsPoison()
      Float CalorieRatio = JMap.getFlt(JM_Entry, "EnergyRatio", 0.2)
      If CalorieRatio
        Float Calories = SCXLib.genWeightValue(akBaseObject) * CalorieRatio
        If Calories
          SCNLib.addCalories(MyActor, Calories)
          Float MealValue = JMap.getFlt(ActorData, "SCNMealCalores")
          If MealValue >= MinMealValue
            If MyActor == Game.GetPlayer()
              Debug.Notification("Meal Requirements met.")
            EndIf
          EndIf
          JMap.setFlt(ActorData, "SCNMealCalores", MealValue + Calories)
        EndIf
      EndIf
    EndIf
  EndIf
  updateWeightRating(MyActor)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
  OnUpdate()
  updateWeightRating(MyActor)
EndEvent

Function updateWeightRating(Actor akTarget)
  ;Check armor weight: Max +12
  Int Weight
  Armor EquippedArmor = akTarget.GetWornForm(0x00000001) as Armor ;Head
  If EquippedArmor
    Int WeightClass = EquippedArmor.GetWeightClass()
    If WeightClass == 0
      Weight += 1
    ElseIf WeightClass == 1
      Weight += 2
    EndIf
  EndIf

  EquippedArmor = akTarget.GetWornForm(0x00000004) as Armor ;Body
  If EquippedArmor
    Int WeightClass = EquippedArmor.GetWeightClass()
    If WeightClass == 0
      Weight += 1
    ElseIf WeightClass == 1
      Weight += 2
    EndIf
  EndIf

  EquippedArmor = akTarget.GetWornForm(0x00000008) as Armor ;Hands
  If EquippedArmor
    Int WeightClass = EquippedArmor.GetWeightClass()
    If WeightClass == 0
      Weight += 1
    ElseIf WeightClass == 1
      Weight += 2
    EndIf
  EndIf

  EquippedArmor = akTarget.GetWornForm(0x00000080) as Armor ;Feet
  If EquippedArmor
    Int WeightClass = EquippedArmor.GetWeightClass()
    If WeightClass == 0
      Weight += 1
    ElseIf WeightClass == 1
      Weight += 2
    EndIf
  EndIf

  EquippedArmor = akTarget.GetWornForm(0x00000200) as Armor ;Shield
  If EquippedArmor
    Int WeightClass = EquippedArmor.GetWeightClass()
    If WeightClass == 0
      Weight += 1
    ElseIf WeightClass == 1
      Weight += 2
    EndIf
  EndIf

  ;Check body weight: Max +10
  Weight += Math.Ceiling(MyActor.GetLeveledActorBase().GetWeight() / 10)

  ;Check SAM weight: Max +20

  ;Check inventory weight: 300 -> +3, 1000 -> +10
  Float ItemWeight = MyActor.GetTotalItemWeight()
  Weight += Math.Floor(ItemWeight / 100)

  ;Check SCX weight
  Float SCXWeight = SCXLib.getActorTotalWeightContained(akTarget, ActorData)

  Weight += Math.Floor(SCXWeight / 100)

  ;/Reasonable Maximum == 52

  Reasonable minimum (no heavy armor, body weight 50, Item weight below 100) == 5
  Should be around 2000 Calories/day, 84 calories/hr
  Calories burned/Weight rating = 17

  Resonable average (Light armor set, body weight 100, SAM + 5, 300 Item weight) == 24

  Absolute minimum(naked/clothing set, body weight 0, no items) == 0, all calorie usage from actions
  /;

  JMap.setInt(ActorData, "SCNWeightValue", Weight)
EndFunction


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Debug Functions
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function Popup(String sMessage)
  {Shows MessageBox, then waits for menu to be closed before continuing}
  Debug.MessageBox(DebugName + sMessage)
  Halt()
EndFunction

Function Halt()
  {Wait for menu to be closed before continuing}
  While Utility.IsInMenuMode()
    Utility.Wait(0.5)
  EndWhile
EndFunction

Function Note(String sMessage)
  Debug.Notification(DebugName + sMessage)
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Notice(String sMessage)
  {Displays message in notifications and logs if globals are active}
  If EnableDebugMessages
    Debug.Notification(DebugName + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage)
EndFunction

Function Issue(String sMessage, Int iSeverity = 0, Bool bOverride = False)
  {Displays a serious message in notifications and logs if globals are active
  Use bOverride to ignore globals}
  If bOverride || EnableDebugMessages
    String Level
    If iSeverity == 0
      Level = "Info"
    ElseIf iSeverity == 1
      Level = "Warning"
    ElseIf iSeverity == 2
      Level = "Error"
    EndIf
    Debug.Notification(DebugName + Level + " " + sMessage)
  EndIf
  Debug.Trace(DebugName + sMessage, iSeverity)
EndFunction
