ScriptName SCV_BlankAnim Extends SCV_BaseAnimation
{Animation file that accepts any prey}

Bool Function checkActors(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList = 0)
  Return True
EndFunction

Function runAnimation(Actor[] akActors, Int[] JM_ActorInfo, Int JA_TagList)
  Note("running blank animation: Actor = " + akActors[0].GetLeveledActorBase().GetName() + ", " + akActors[1].GetLeveledActorBase().GetName())
  String Type
  Int JM_PreyInfo = JM_ActorInfo[1]
  String ArchType = Struggling.getArchFromVoreType(JMap.getStr(JM_PreyInfo, "VoreType"))
  If JMap.getStr(JM_PreyInfo, "Lethal") != 0
    Type = "Breakdown"
  Else
    Type = "Stored"
  EndIf
  Int i = 1
  Int NumActors = akActors.length
  Note("ArchType=" + ArchType)
  While i < NumActors
    Struggling.addToContents(akActors[0], akActors[i], None, "Breakdown", ArchType + "." + Type)
    SCVLib.checkPredSpells(akActors[i])
    i += 1
  EndWhile
  SCVLib.checkPredSpells(akActors[0])
EndFunction
