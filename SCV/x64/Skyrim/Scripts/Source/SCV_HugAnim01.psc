ScriptName SCV_HugAnim01 Extends SCV_BaseAnimation
Idle Property pa_HugA Auto

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
    If RacesActor00.find(getRaceString(akActors[0])) != -1
      Bool Dead = JMap.getInt(JM_ActorInfo[1], "Incapacitated")
      If !Dead
        String PreyRace = JMap.getStr(JM_ActorInfo[1], "RaceString")
        If RacesActor01.find(getRaceString(akActors[1])) != -1
          Float ScaleRatio = JMap.getFlt(JM_ActorInfo[1], "SizeRatio")
          If ScaleRatio > ScaleMin && ScaleRatio < ScaleMax
            Float Distance = JMap.getFlt(JM_ActorInfo[1], "Distance")
            If Distance > DistanceMin && Distance < DistanceMax
							Note("Actors passed! Prep for animation!")
              Return True
						Else
							Note("Wrong distance: Min=" + DistanceMin + ",Max=" + DistanceMax + ", Actual=" + Distance)
            EndIf
					Else
						Note("Wrong scale: Min=" + ScaleMin + ",Max=" + ScaleMax + ", Actual=" + ScaleRatio)
          EndIf
				Else
					Note("Actor 1 is wrong race!")
        EndIf
			Else
				Note("Actor 1 is dead!")
      EndIf
		Else
			Note("Actor 0 is wrong race!")
    EndIf
	Else
		Note("Wrong number of actors: Min=" + MinNumActors + ",Max=" + MaxNumActors + ", Actual=" + akActors.length)
  EndIf
	Return False
EndFunction

Function prepAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
  Int i = akActors.length
  While i
    i -= 1
    If i == 0
			;seems absolute, may need to remove False and add in more checkes...
      akActors[i].MoveTo(akActors[1], 100 * Math.sin(akActors[1].GetAngleZ()), 100 * Math.cos(akActors[1].GetAngleZ()), 0)
			Float zOffset = akActors[i].GetHeadingAngle(akActors[1])
			akActors[i].SetAngle(akActors[i].GetAngleX(), akActors[i].GetAngleY(), akActors[i].GetAngleZ() + zOffset)
    EndIf
    ActorUtil.AddPackageOverride(akActors[i], SCX_ActorHoldPackage)
    akActors[i].EvaluatePackage()
    If akActors[i] == PlayerRef
      If Game.GetCameraState() == 0
        Game.ForceThirdPerson()
      EndIf
      Game.SetPlayerAIDriven(True)
    Else
      akActors[i].SetRestrained(True)
      akActors[i].SetDontMove(True)
    EndIf
  EndWhile
EndFunction

Function runAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)

  akActors[0].PlayIdleWithTarget(pa_HugA, akActors[1])

  String Type
  Int JM_PreyInfo = JM_ActorInfo[1]
  If JMap.getStr(JM_PreyInfo, "Lethal") != 0
		Type = "Breakdown"
  Else
		Type = "Stored"
  EndIf

	Int i = akActors.length
	While i
		i -= 1
		ActorUtil.RemovePackageOverride(akActors[i], SCX_ActorHoldPackage)
		If akActors[i] == PlayerRef
			Game.SetPlayerAIDriven(False)
		Else
			akActors[i].SetRestrained(False)
			akActors[i].SetDontMove(False)
		EndIf
		Debug.SendAnimationEvent(akActors[i], "IdleForceDefaultState")
		akActors[i].EvaluatePackage()
	EndWhile
  Struggling.addToContents(akActors[0], akActors[1], None, "Breakdown", "Stomach." + Type)
	SCVLib.checkPredSpells(akActors[1])
	SCVLib.checkPredSpells(akActors[0])
EndFunction
