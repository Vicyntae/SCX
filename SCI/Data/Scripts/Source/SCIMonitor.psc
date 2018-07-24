ScriptName SCIMonitor Extends SCX_BaseMonitor

Function runUpdate()
  Float IllnessFlt = JMap.getFlt(ActorData, "IllnessBuildUp")
  Float Boundary = JMap.getFlt(ActorData, "IllnessThreshold", 1)
  If IllnessFlt > Boundary
    JMap.setFlt(ActorData, "IllnessBuildUp", 0)
    Int IllnessLevel = JMap.getInt(ActorData, "IllnessLevel") + 1
    SCLib.WF_addSolidIllnessEffect(MyActor, IllnessLevel, ActorData)
  Else
    JMap.setFlt(ActorData, "IllnessBuildUp", JMap.getFlt(ActorData, "IllnessBuildUp") - (SCLSet.IllnessBuildUpDecrease * afTimePassed))
  EndIf
EndFunction
