ScriptName SCX_BaseAggValues Extends SCX_BaseRefAlias Hidden

String Property KeyName Auto
String[] Property SumKeys Auto

Float Function updateAggregateValue(Actor akTarget, Bool abEX, Int aiTargetData = 0)
  If !aiTargetData
    aiTargetData = SCXLib.getTargetData(akTarget)
  EndIf
  Int i = SumKeys.Length
  Float Aggregate
  While i
    i -= 1
    Aggregate += JMap.getFlt(aiTargetData, SumKeys[i])
  EndWhile
  JMap.setFlt(aiTargetData, KeyName, Aggregate)
EndFunction
