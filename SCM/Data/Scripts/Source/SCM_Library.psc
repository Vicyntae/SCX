ScriptName SCM_Library Extends SCX_BaseLibrary

SCM_Settings Property SCMSet Auto
Function Setup()
  SCX_BaseLibrary SCNLib = JMap.getForm(SCXSet.JM_BaseLibraryList, "SCN_Library") as SCX_BaseLibrary
  If SCNLib
    SCMSet.SCN_Installed = True
  EndIf
EndFunction
SCX_BaseBodyEdit Property Muscle Auto
SCX_BaseBodyEdit Property Fat Auto
SCX_BaseBodyEdit Property Height Auto
SCX_BaseBodyEdit Property Weight Auto

;*******************************************************************************
;Library Functions
;*******************************************************************************

;/What are we doing here?

Muscle morphs
Fat morphs
Height morphs/;

;MCM Functions *****************************************************************

;Monitors **********************************************************************
Function monitorUpdate(SCX_Monitor akMonitor, Actor akTarget, Int aiTargetData, Float afTimePassed, Float afCurrentUpdateTime, Bool abDailyUpdate)
  Muscle.updateBodyPart(akTarget)
  Fat.updateBodyPart(akTarget)
  Weight.updateBodyPart(akTarget)
  Height.updateBodyPart(akTarget)
EndFunction

;*******************************************************************************
;Functions
;*******************************************************************************



;/
Float Function calculateWeightRating(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Float WeightRating
  Int JM_Weight = SCMSet.JM_WeightActorValueRatings
  String i = JMap.nextKey(JM_Weight)
  While i
    WeightRating += akTarget.GetBaseActorValue(i) * JMap.getFlt(JM_Weight, i)
    i = JMap.nextKey(JM_Weight, i)
  EndWhile

  If SCMSet.WeightHealthRating != 0
    WeightRating += akTarget.GetBaseActorValue("Health") * SCMSet.WeightHealthRating  ;Use this for LE
    ;WeightRating += akTarget.GetActorValueMax("Health") * SCMSet.WeightHealthRating  ;Use this for SSE
  EndIf

  If SCMSet.WeightStaminaRating != 0
    WeightRating += akTarget.GetBaseActorValue("Health") * SCMSet.WeightStaminaRating  ;Use this for LE
    ;WeightRating += akTarget.GetActorValueMax("Health") * SCMSet.WeightStaminaRating  ;Use this for SSE
  EndIf

  If SCMSet.WeightMagickaRating != 0
    WeightRating += akTarget.GetBaseActorValue("Health") * SCMSet.WeightMagickaRating  ;Use this for LE
    ;WeightRating += akTarget.GetActorValueMax("Health") * SCMSet.WeightMagickaRating  ;Use this for SSE
  EndIf
  WeightRating += JMap.getFlt(akTarget, "SCMStatWeightRating")
  WeightRating = PapyrusUtil.ClampFloat(WeightRating, SCMSet.WeightMin, SCMSet.WeightMax)
  Return WeightRating
EndFunction

Float Function calculateHeightRating(Actor akTarget, Int aiTargetData = 0)
  If !JValue.isMap(aiTargetData)
    aiTargetData = getTargetData(akTarget)
  EndIf
  Float HeightRating
  Int JM_Height = SCMSet.JM_HeightActorValueRatings
  String i = JMap.nextKey(JM_Height)
  While i
    HeightRating += akTarget.GetBaseActorValue(i) * JMap.getFlt(JM_Height, i)
    i = JMap.nextKey(JM_Height, i)
  EndWhile

  If SCMSet.HeightHealthRating != 0
    HeightRating += akTarget.GetBaseActorValue("Health") * SCMSet.HeightHealthRating  ;Use this for LE
    ;HeightRating += akTarget.GetActorValueMax("Health") * SCMSet.HeightHealthRating  ;Use this for SSE
  EndIf

  If SCMSet.HeightStaminaRating != 0
    HeightRating += akTarget.GetBaseActorValue("Health") * SCMSet.HeightStaminaRating  ;Use this for LE
    ;HeightRating += akTarget.GetActorValueMax("Health") * SCMSet.HeightStaminaRating  ;Use this for SSE
  EndIf

  If SCMSet.HeightMagickaRating != 0
    HeightRating += akTarget.GetBaseActorValue("Health") * SCMSet.HeightMagickaRating  ;Use this for LE
    ;HeightRating += akTarget.GetActorValueMax("Health") * SCMSet.HeightMagickaRating  ;Use this for SSE
  EndIf
  HeightRating += JMap.getFlt(akTarget, "SCMStatHeightRating")
  HeightRating = PapyrusUtil.ClampFloat(HeightRating, SCMSet.HeightMin, SCMSet.HeightMax)
  Return HeightRating
EndFunction/;
