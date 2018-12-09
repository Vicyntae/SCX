ScriptName SCLOverfullEffects Extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
  MyActor = akTarget
  If akTarget == PlayerRef
    ObjectUtil.SetReplaceAnimation(akTarget, IdlePlayer, SCL_IdleSTHurtPlayer)
  EndIf
  RegisterForSingleUpdate(15)
EndEvent

Event OnUpdate()
  If Utility.RandomFloat() < 0.25
    MyActor.Say(SCL_TopicGroan)
  EndIf
  RegisterForSingleUpdate(15)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  ObjectUtil.ClearReplaceAnimation(MyActor)
EndEvent

;/
IdlePlayerRoot
  IdlePlayer

BaseIdleRoot
  idle_A_shouldersVar1
  idle_A_sigh_var1Trans
  idle_A_left_longTrans
  idle_A_leg_shift
  idle_A_shakeout
  idle_A_soft_right_trans
  idle_A_sway_fastTrans
  idle_A_shoulders
  idle_A_sigh_var2Trans
  idle_A_scratch_back
  idle_A_pull_pants
  idle_A_swatflies

AnimtationDrivenIdleRoot
  MotionDrivenStyle
  IdleHHRight
  IdleHDRight
  IdleHDRightAngry
  IdleHHLeft
  IdleHDLeft
  IdleHDLeftAngry
  IdleHDFailAll

SittingIdleRoot
  SittingChairVar2
  SittingChairArmsCrossedVar1
  SittingChairLookDown
  SittingChairArmsCrossedVar2
  SittingChairShoulderFlex
  SittingChairVar1
