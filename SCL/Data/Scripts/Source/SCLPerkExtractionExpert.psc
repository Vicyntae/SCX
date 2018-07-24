ScriptName SCLPerkExtractionExpert Extends SCX_BasePerk
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto
Function Setup()
  Name = "Extraction Expert"
  Description = New String[4]
  Description[0] = "Allows you to digest non-digestible items and obtain benefits."
  Description[1] = "Allows you to digest armor and gain a small boost to armor skills."
  Description[2] = "Allows you to digest weapons and gain a small boost to weapon skills."
  Description[3] = "Allows you to digest enchanted weapons and armor and gain a small boost to magic skills."

  Requirements = New String[4]
  Requirements[0] = "No Requirements."
  Requirements[1] = "Have at least 25 Smithing, 20 Light Armor, and 20 Heavy Armor."
  Requirements[2] = "Have at least 45 Smithing, 30 One-Handed, and 30 Two-Handed."
  Requirements[3] = "Have at least 60 Smithing, 40 Light Armor, 40 One-Handed, 40 Heavy Armor, 40 Two-Handed, and 50 Enchanting."
  RegisterForModEvent("SCLDigestItemFinishEvent", "OnItemDigestFinish")
EndFunction

Bool Function canTake(Actor akTarget, Int aiPerkLevel, Bool abOverride, Int aiTargetData = 0)
  If abOverride && aiPerkLevel >= 1 && aiPerkLevel <= 3
    Return True
  EndIf
  Int Smithing = akTarget.GetActorValue("Smithing") as Int
  Int LArmor = akTarget.GetActorValue("LightArmor") as Int
  Int HArmor = akTarget.GetActorValue("HeavyArmor") as Int
  Int OneHanded = akTarget.GetActorValue("OneHanded") as Int
  Int TwoHanded = akTarget.GetActorValue("TwoHanded") as Int
  Int Enchant = akTarget.GetActorValue("Enchanting") as Int
  If aiPerkLevel == 1 && Smithing >= 25 && LArmor >= 20 && HArmor >= 20
    Return True
  ElseIf aiPerkLevel == 2 && Smithing >= 45 && OneHanded >= 30 && TwoHanded >= 30
    Return True
  ElseIf aiPerkLevel == 3 && Smithing >= 60 && LArmor >= 40 && HArmor >= 40 && OneHanded >= 40 && TwoHanded >= 40 && Enchant >= 50
    Return True
  Else
    Return False
  EndIf
EndFunction

Event OnItemDigestFinish(Form akEater, Form akFood, Float afWeightValue)
  If akEater as Actor
    Actor Target = akEater as Actor
    Form BaseForm
    If akFood as Actor
      BaseForm = (akFood as Actor).GetLeveledActorBase()
    ElseIf akFood as ObjectReference
      BaseForm = (akFood as ObjectReference).GetBaseObject()
    Else
      BaseForm = akFood
    EndIf
    If BaseForm as Weapon || BaseForm as Armor
      Int PerkLevel = getPerkLevel(Target)
      Enchantment Ench
      If akFood as ObjectReference
        Ench = (akFood as ObjectReference).GetEnchantment()
      ElseIf BaseForm as Weapon
        Ench = (BaseForm as Weapon).GetEnchantment()
      ElseIf BaseForm as Armor
        Ench = (BaseForm as Armor).GetEnchantment()
      EndIf
      If Ench && PerkLevel >= 3
        Int EffectIndex = Ench.GetCostliestEffectIndex()
        Float AV
        Int i

        Float MAG = Ench.GetNthEffectMagnitude(EffectIndex)
        If MAG
          AV += MAG
          i += 1
        EndIf

        Int DUR = Ench.GetNthEffectDuration(EffectIndex)
        If DUR
          AV += DUR
          i += 1
        EndIf

        Int AREA = Ench.GetNthEffectArea(EffectIndex)
        If AREA
          AV += AREA
          i += 1
        EndIf
        AV /= i

        If AV > 0
          MagicEffect ME = Ench.GetNthEffectMagicEffect(EffectIndex)
          String Skill = ME.GetAssociatedSkill()
          If Target == PlayerRef
            Debug.Notification(Skill + " increased from digesting enchanted equipment!")
            Game.AdvanceSkill(Skill, AV)
          Else
            Target.ModActorValue(Skill, AV)
          EndIf
        EndIf
      EndIf

      If BaseForm as Armor && PerkLevel >= 1
        Int WeightClass = (BaseForm as Armor).GetWeightClass()
        String Skill
        If (BaseForm as Armor).IsShield()
          Skill = "Block"
        ElseIf WeightClass == 0
          Skill = "LightArmor"
        ElseIf WeightClass == 1
          Skill = "HeavyArmor"
        ElseIf WeightClass == 2
          If (BaseForm as Armor).IsJewelry()
            Skill == "Smithing"
          Else
            Skill == "Alteration"
          EndIf
        EndIf
        Float AR
        If WeightClass == 2
          AR = BaseForm.GetGoldValue() / 500
        Else
          AR = (BaseForm as Armor).GetArmorRating() / 200
        EndIf
        If AR
          If Target == PlayerRef
            String AltSkill = Skill
            If Skill == "LightArmor"
              AltSkill = "Light Armor"
            ElseIf Skill == "HeavyArmor"
              AltSkill = "Heavy Armor"
            EndIf
            Debug.Notification(AltSkill + " increased from digesting armor!")
            Game.AdvanceSkill(Skill, AR)
          Else
            Target.ModActorValue(Skill, AR)
          EndIf
        EndIf
      ElseIf BaseForm as Weapon && PerkLevel >= 2
        Int WeaponType = (BaseForm as Weapon).GetWeaponType()
        String Skill
        If WeaponType == 0
          Skill = "UnarmedDamage"
        ElseIf WeaponType == 1 || WeaponType == 3 || WeaponType == 4
          Skill = "OneHanded"
        ElseIf WeaponType == 2
          Skill = "Sneak"
        ElseIf WeaponType == 5 || WeaponType == 6
          Skill = "TwoHanded"
        ElseIf WeaponType == 7 || WeaponType == 9
          Skill = "Marksman"
        ElseIf WeaponType == 8
          Skill = "Enchanting"
        EndIf
        Float BD
        If WeaponType == 8
          BD = BaseForm.GetGoldValue() / 500
        Else
          BD = (BaseForm as Weapon).GetBaseDamage() / 200
        EndIf
        If BD
          String AltSkill = Skill
          If Skill == "UnarmedDamage"
            AltSkill = "Unarmed Damage"
          ElseIf Skill == "OneHanded"
            AltSkill = "One Handed"
          ElseIf Skill == "TwoHanded"
            AltSkill = "Two Handed"
          EndIf
          If Target == PlayerRef
            Debug.Notification(AltSkill + " increased from digesting weaponry!")
          EndIf
          If Target != PlayerRef || Skill == "UnarmedDamage"
            Target.ModActorValue("MeleeDamage", BD)
          Else
            Game.AdvanceSkill(Skill, BD)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
EndEvent

Function reloadMaintenence()
  Setup()
EndFunction
