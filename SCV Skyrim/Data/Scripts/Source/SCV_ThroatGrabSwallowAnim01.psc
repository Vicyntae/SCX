ScriptName SCV_ThroatGrabSwallowAnim01 Extends SCV_BaseAnimation

Function Setup()
	Int JA_MasterAnimList = JDB.solveObj(".SCX_ExtraData.SCVAnimations.Oral")
	If JArray.findStr(JA_MasterAnimList, _getStrKey()) == -1
		JArray.addStr(JA_MasterAnimList, _getStrKey())
	EndIf
EndFunction

Bool Function checkActors(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
  If akActors.length >= MinActors && akActors.length <= MaxActors
    If RacesActor00.find(akActors[0].GetRace()) != -1
      Bool Dead = JMap.getInt(JM_ActorInfo[1], "Incapacitated")
      If !Dead
        String PreyRace = JMap.getStr(JM_ActorInfo[1], "RaceString")
        If RacesActor01.find(akActors[1].GetRace()) != -1
          Float ScaleRatio = JMap.getFlt(JM_ActorInfo[1], "SizeRatio")
          If ScaleRatio > ScaleMin && ScaleRatio < ScaleMax
            Float Distance = JMap.getFlt(JM_ActorInfo[1], "Distance")
            If Distance > DistanceMin && Distance < DistanceMax
              Return True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
EndFunction

Function prepAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList)
  Int i = akActors.length
  While i
    i -= 1
    If i == 0
      akActors[i].MoveTo(akActors[1], 100 * Math.sin(akActors[1].GetAngleZ()), 0 * Math.cos(akActors[1].GetAngleZ()), 0)
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


Function runAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList)
  Bool PredGender = akActors[0].GetLeveledActorBase().GetSex() as Bool
  Bool PreyGender = akActors[1].GetLeveledActorBase().GetSex() as Bool
  Debug.SendAnimationEvent(akActors[0], "SCV_ThroatGrabSwallow01aEvent")
  Debug.SendAnimationEvent(akActors[1], "SCV_ThroatGrabSwallow01bEvent")
  Utility.Wait(1.5)

  OpenMouth(akActors[0])
  Utility.Wait(0.3333)

  NiOverride.AddNodeTransformScale(akActors[1], False, PreyGender, "NPC Neck [Neck]", "SCVAnim", 0.1)
  NiOverride.UpdateAllReferenceTransforms(akActors[1])
  Utility.Wait(0.3333)

  NiOverride.AddNodeTransformScale(akActors[1], False, PreyGender, "NPC Spine2 [Spn2]", "SCVAnim", 0.1)
  NiOverride.UpdateAllReferenceTransforms(akActors[1])
  Utility.Wait(0.5)

  NiOverride.AddNodeTransformScale(akActors[1], False, PreyGender, "NPC COM [COM]", "SCVAnim", 0.1)
  NiOverride.UpdateAllReferenceTransforms(akActors[1])
  Utility.Wait(0.3333)

  akActors[1].SetAlpha(0, True)
  NiOverride.RemoveNodeTransformScale(akActors[1], False, PreyGender, "NPC Neck [Neck]", "SCVAnim")
  NiOverride.RemoveNodeTransformScale(akActors[1], False, PreyGender, "NPC Spine2 [Spn2]", "SCVAnim")
  NiOverride.RemoveNodeTransformScale(akActors[1], False, PreyGender, "NPC COM [COM]", "SCVAnim")

  String Type
  Int JM_PreyInfo = JM_ActorInfo[1]
  If JMap.getStr(JM_PreyInfo, "Lethal") != 0
    Type = "Stored"
  Else
    Type = "Breakdown"
  EndIf
  Struggling.addToContents(akActors[0], akActors[1], None, "Breakdown", "Stomach." + Type)
EndFunction
