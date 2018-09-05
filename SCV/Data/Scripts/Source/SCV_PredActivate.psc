ScriptName SCV_PredActivate Extends ObjectReference

Actor Property PlayerRef Auto
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
String Property Setting_PredType Auto
Event OnActivate(ObjectReference akActionRef)
  If akActionRef == PlayerRef
    If Setting_PredType == "Oral"
      SCVLib.setOVPred(PlayerRef, True)
    ElseIf Setting_PredType == "Anal"
      SCVLib.setAVPred(PlayerRef, True)
    ElseIf Setting_PredType == "Unbirth"
      SCVLib.setUVPred(PlayerRef, True)
    ElseIf Setting_PredType == "Cock"
      SCVLib.setCVPred(PlayerRef, True)
    EndIf
  EndIf
EndEvent
