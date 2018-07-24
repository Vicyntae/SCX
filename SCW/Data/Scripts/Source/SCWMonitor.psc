ScriptName SCWMonitor Extends SCX_BaseMonitor

Function runUpdate(SCX_Monitor akAlias, Actor akTarget, Int aiTargetData, Float afTimePassed, Float afCurrentUpdateTime, Bool abDailyUpdate)
  If SCLSet.WF_NeedsActive
    Float SolidAmount = SCLib.WF_getTotalSolidFullness(MyActor, ActorData)
    Float SolidTimePast = ((afCurrentUpdateTime - (JMap.getFlt(ActorData, "WF_SolidTimePast")))*24) ;In hours
    Float SolidBase = SCLib.WF_getAdjSolidBase(MyActor, ActorData)
    If !MyActor.HasSpell(SCLSet.WF_SolidDebuffSpell)
      If SolidAmount > SolidBase || SolidTimePast > 8
        MyActor.AddSpell(SCLSet.WF_SolidDebuffSpell, False)
      EndIf
    Else
      If SolidAmount < SolidBase && SolidTimePast > 8
        MyActor.RemoveSpell(SCLSet.WF_SolidDebuffSpell)
      EndIf
    EndIf
    JMap.setFlt(ActorData, "WF_SolidTotalFullness", SolidAmount)
    Float LiquidAmount = JMap.getFlt(ActorData, "WF_CurrentLiquidAmount")
    Float LiquidTimePast = ((afCurrentUpdateTime - (JMap.getFlt(ActorData, "WF_LiquidTimePast")))*24) ;In hours
    Float LiquidBase = SCLib.WF_getAdjLiquidBase(MyActor, ActorData)
    If !MyActor.HasSpell(SCLSet.WF_LiquidDebuffSpell)
      If LiquidAmount > LiquidBase || LiquidTimePast > 8
        MyActor.AddSpell(SCLSet.WF_LiquidDebuffSpell, False)
      EndIf
    Else
      If LiquidAmount < LiquidBase && LiquidTimePast > 8
        MyActor.RemoveSpell(SCLSet.WF_LiquidDebuffSpell)
      EndIf
    EndIf
    ;/If SCLSet.WF_GasActive
    EndIf/;
  EndIf
EndFunction
