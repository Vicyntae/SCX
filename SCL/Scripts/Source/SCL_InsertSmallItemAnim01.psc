ScriptName SCL_InsertSmallItemAnim01 Extends SCX_BaseAnimation
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto

Int Function _getSCX_JC_List()
	Return SCLSet.JM_SmallItemAnimList
EndFunction

Function prepAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
  Note("Preping animation...")
  ActorUtil.AddPackageOverride(akActors[0], SCX_ActorHoldPackage)
  akActors[0].EvaluatePackage()
  If akActors[0] == PlayerRef
    If Game.GetCameraState() == 0
      Game.ForceThirdPerson()
    EndIf
    Game.SetPlayerAIDriven(True)
  Else
    akActors[0].SetRestrained(True)
    akActors[0].SetDontMove(True)
  EndIf
EndFunction


Function runAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
  Debug.SendAnimationEvent(akActors[0], "SCL_InsertSmallItemEvent01")
  Utility.Wait(5)
  ActorUtil.RemovePackageOverride(akActors[0], SCX_ActorHoldPackage)
  If akActors[0] == PlayerRef
    Game.SetPlayerAIDriven(False)
  Else
    akActors[0].SetRestrained(False)
    akActors[0].SetDontMove(False)
  EndIf
  Debug.SendAnimationEvent(akActors[0], "IdleForceDefaultState")
  akActors[0].EvaluatePackage()
EndFunction
