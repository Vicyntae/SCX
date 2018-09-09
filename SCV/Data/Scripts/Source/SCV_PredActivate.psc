ScriptName SCV_PredActivate Extends ObjectReference

Actor Property PlayerRef Auto
SCVLibrary Property SCVLib Auto
SCVSettings Property SCVSet Auto
SCX_Library Property SCXLib Auto
SCX_Settings Property SCXSet Auto
String Property Setting_PredType Auto
Event OnActivate(ObjectReference akActionRef)
  If akActionRef == PlayerRef
    Int PlayerData = SCVLib.getTargetData(PlayerRef)
    If Setting_PredType == "Oral"
      If !SCVLib.isOVPred(PlayerRef, PlayerData)
        SCVLib.setOVPred(PlayerRef, True)
        Debug.MessageBox("You feel the power of the serpent flow through you, along with a sudden hunger...")
      EndIf
    ElseIf Setting_PredType == "Anal"
      SCVLib.setAVPred(PlayerRef, True)
    ElseIf Setting_PredType == "Unbirth"
      SCVLib.setUVPred(PlayerRef, True)
    ElseIf Setting_PredType == "Cock"
      SCVLib.setCVPred(PlayerRef, True)
    EndIf
  EndIf
EndEvent
