ScriptName SCV_CannibalFeedAnim01 Extends SCV_BaseAnimation
Idle Property IdleCannibalFeedCrouching_Loose Auto
Idle Property IdleCannibalFeedStanding_Loose Auto

Function Setup()
	Int JA_MasterAnimList = JDB.solveObj(".SCX_ExtraData.SCVAnimations.Oral")
	If !JA_MasterAnimList
		JA_MasterAnimList = JArray.object()
		JDB.solveObjSetter(".SCX_ExtraData.SCVAnimations.Oral", JA_MasterAnimList, True)
	EndIf
	If JArray.findStr(JA_MasterAnimList, _getStrKey()) == -1
		JArray.addStr(JA_MasterAnimList, _getStrKey())
	EndIf
EndFunction

Bool Function checkActors(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
	Note("Checking Actors: " + nameGet(akActors[0]) + ", " + nameGet(akActors[1]))
  If akActors.length >= MinNumActors && akActors.length <= MaxNumActors
    If RacesActor00.find(SCVLib.getRaceString(akActors[0])) != -1
			If !akActors[1]
				Return True
			Else
				Bool Dead = JMap.getInt(JM_ActorInfo[1], "Incapacitated")
	      If Dead
	      	Return True
				Else
					Note("Prey not dead! returning false.")
				EndIf
			EndIf
    EndIf
  EndIf
	Return False
EndFunction

Function prepAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList)
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

Function runAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList)
  Debug.SendAnimationEvent(akActors[0], "IdleCannibalFeedCrouching")
	Utility.Wait(3)

	String Type
	Int JM_PreyInfo = JM_ActorInfo[1]
	If JMap.getStr(JM_PreyInfo, "Lethal") != 0
		Type = "Breakdown"
	Else
		Type = "Stored"
	EndIf
	Struggling.addToContents(akActors[0], akActors[1], None, "Breakdown", "Stomach." + Type)
	;Debug.SendAnimationEvent(akActors[0], "IdleCannibalFeedStanding")
	;akActors[0].PlayIdle(IdleCannibalFeedCrouching_Loose)
	;akActors[0].PlayIdle(IdleCannibalFeedStanding_Loose)


	ActorUtil.RemovePackageOverride(akActors[0], SCX_ActorHoldPackage)
	If akActors[0] == PlayerRef
		Game.SetPlayerAIDriven(False)
	Else
		akActors[0].SetRestrained(False)
		akActors[0].SetDontMove(False)
	EndIf
	resetAnimGraph(akActors[0])
	Debug.SendAnimationEvent(akActors[0], "IdleForceDefaultState")
	akActors[0].EvaluatePackage()
	SCVLib.checkPredSpells(akActors[0])
EndFunction
