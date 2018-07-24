ScriptName SCNMonitor Extends SCX_BaseMonitor
;/If Actor hasn't eaten in >8 hours, eat
Actor eats more based on desire and fullness (will eat to certain fullness + x%)
Will eat after fighting > 5 min
Will eat after entering inn/tavern
If fullness < desire Threshold, will eat
-4 = uncontrollable drink
-3 = heavy drink
-2 = medium drink
-1 = light drink
0 = potions
1 = light snack
2 = light meal
3 = Full meal
4 = uncontrollable eat
/;
Function runUpdate(SCX_Monitor akAlias, Actor akTarget, Int aiTargetData, Float afTimePassed, Float afCurrentUpdateTime, Bool abDailyUpdate)
  If SCLSet.AutoEatActive
    If MyActor != PlayerRef
      Float EatTimePassed = ((afCurrentUpdateTime - (JMap.getFlt(ActorData, "LastEatTime")))*24) ;In hours
      Float Glut = SCLib.getGlutMin(akTarget = MyActor, aiTargetData = ActorData)
      Float GlutTime = SCLib.getGlutTime(akTarget = MyActor, aiTargetData = ActorData)
      Int Gluttony = SCLib.getGlutValue(MyActor, ActorData)
      Float Eaten
      If EatTimePassed >= 8
        Notice("Meal not eaten in over 8 hours. Eating...")
        Eaten = SCLib.actorEat(MyActor, 3, 2, True)
        If Eaten
          JMap.setFlt(ActorData, "LastEatTime", afCurrentUpdateTime)
        EndIf
      ElseIf EatTimePassed >= 4
        Location CurrentLoc = MyActor.GetCurrentLocation()
        If CurrentLoc.HasKeyword(SCLSet.LocTypeInn) || CurrentLoc.HasKeyword(SCLSet.LocTypeHabitationHasInn)
          Notice("Meal not eaten in over 4 hours and actor is in tavern. Eating...")
          SCLib.actorEat(MyActor, -2, 60, True)
          Eaten = SClib.actorEat(MyActor, 2, 1, True)
          If Eaten
            JMap.setFlt(ActorData, "LastEatTime", afCurrentUpdateTime)
          EndIf
        EndIf
      ElseIf Gluttony > 50 && EatTimePassed >= GlutTime && afFullness < Glut
        Notice("Meal not eaten in over " + GlutTime + " hours and fullness below + " + Glut + ". Eating...")
        Eaten = SCLib.actorEat(MyActor, 1, 2, True)
      EndIf
      If Eaten == 0 && EatTimePassed >= 24
        If !PlayerThoughtDB(MyActor, "SCLStarvingMessage")
          SCLSet.SCL_AIFindFoodSpell01a.Cast(MyActor)
        EndIf
      EndIf
    EndIf
  EndIf
EndFunction
