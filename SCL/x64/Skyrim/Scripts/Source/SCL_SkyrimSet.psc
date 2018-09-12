ScriptName SCL_SkyrimSet Extends SCX_BaseQuest
{Adds data reliant to Skyrim.esm}
;/Increase stomach Stretch
  Some kind of stomach relaxer?
  Done: Chamomile, so some kind of white flower, possibly retexture existing ingredients
  Peppermint
  Ginger
  Lemon Tea

Decrease stomach Stretch
  Likely add as a side effect to another item

Increase stomach base
  Maybe keep this effect off specifically, and focus on expand effects

Decrease stomach base
  A temporary negative effect

Increase stretch bonus

Increase digest rate
  Some kind of acidic ingredient, maybe citrus(at least for low levels or temp effects)
  Orange 1
  Lemon
  Pineapple
  Vinegar
  Cleaning fluid  ;Also poisons you
  Dwarven Polish

Decrease digest rate
Increase storage capacity
  Resiliant stomach, so like a muscle toner?
  Maybe decrease stretch as well
  Maybe include as like an activity instead of an item

Increase heavy tier
  Requires ability to hold items, so maybe tie to carry capacity/stamina
  Backbrace enchantment?
  Muscle builder (increases heavy tier, stamina, and carry weight)

Frenzy Item
  Basic Frenzy Item, and one that gives additional buff
/;
SCLibrary Property SCLib Auto
SCLSettings Property SCLSet Auto

SCX_BaseBodyEdit Property Belly Auto
SCX_BaseEquipment Property SCL_Skyrim_BellyEquip01 Auto
LeveledItem Property LItemApothecaryIngredientsCommon75 Auto
LeveledItem Property LItemApothecaryIngredienstUncommon75 Auto
LeveledItem Property LItemIngredientsCommon Auto
LeveledItem Property LItemIngredientsUncommon Auto
LeveledItem Property LItemBarrelFoodSame70 Auto
LeveledItem Property LItemBarrelFoodSame75 Auto
LeveledItem Property LItemMiscVendorMiscItems75 Auto
LeveledItem Property LItemFoodInnCommon Auto

LeveledItem Property SCL_LItemPotionFortifyStomachSkills Auto ;DONE
LeveledItem Property LItemPotionAllSkills Auto

LeveledItem Property SCL_LItemEnchRingSkillStomach Auto ;Add to below DONE
LeveledItem Property LItemEnchRingAll Auto
LeveledItem Property LItemEnchRingAll25 Auto
LeveledItem Property LItemEnchRingAll75 Auto


LeveledItem Property SCL_LItemEnchNecklaceGlutton Auto
LeveledItem Property SCL_LItemEnchNecklaceBaseCap Auto
LeveledItem Property SCL_LItemEnchNecklaceDigestRate Auto
LeveledItem Property LItemEnchNecklaceAll Auto  ;Add above to this DONE
LeveledItem Property LItemEnchNecklaceAll25 Auto ; And this

Ingredient Property SCL_MountainFlower01White Auto
Ingredient Property SCL_Lemon Auto
Ingredient Property SCL_Orange Auto
Potion Property SCL_WhiteMountainFlowerTea Auto

LeveledItem Property SublistEnchArmorBandedIronCuirass01 Auto ;Put these two together DONE
Armor Property SCL_EnchArmorIronBandedCuirassHeavyBurden01 Auto

LeveledItem Property SublistEnchArmorOrcishBoots04 Auto
Armor Property SCL_EnchArmorOrcishBootsHeavyBurden04 Auto

LeveledItem Property SublistEnchArmorGlassCuirass03 Auto
Armor Property SCL_EnchArmorGlassCuirassHeavyBurden03 Auto

LeveledItem Property SublistEnchArmorDwarvenBoots02 Auto
Armor Property SCL_EnchArmorDwarvenBootsHeavyBurden02 Auto

LeveledItem Property SublistEnchArmorDragonplateBoots06 Auto
Armor Property SCL_EnchArmorDragonplateCuirassHeavyBurden06 Auto

LeveledItem Property SublistEnchArmorDragonplateBoots05 Auto
Armor Property SCL_EnchArmorDragonplateBootsHeavyBurden05 Auto

LeveledItem Property SublistEnchArmorDaedricCuirass05 Auto
Armor Property SCL_EnchArmorDaedricCuirassHeavyBurden05 Auto

LeveledItem Property SublistEnchArmorDaedricBoots04 Auto
Armor Property SCL_EnchArmorDaedricBootsHeavyBurden04 Auto

Potion Property SCL_DummyNotFoodLarge Auto
Potion Property SCL_DummyNotFoodMedium Auto
Potion Property SCL_DummyNotFoodSmall Auto

Int ScriptVersion = 1
Int Function checkVersion(Int aiStoredVersion)
  {Return the new version and the script will update the stored version}
  If ScriptVersion >= 1 && aiStoredVersion < 1
    Utility.Wait(1)
    Int JI_BellyEquipList = JIntMap.object()
    JValue.addToPool(JI_BellyEquipList, "SCX_BodyEditBellyEquipmentPool")
    JIntMap.setForm(JI_BellyEquipList, 1, SCL_Skyrim_BellyEquip01)
    If Belly.EquipmentList.length == 0
      Belly.EquipmentList = Utility.CreateIntArray(1, 0)
      Belly.EquipmentList[0] = JI_BellyEquipList
    Else
      Belly.EquipmentList = PapyrusUtil.PushInt(Belly.EquipmentList, JI_BellyEquipList)
    EndIf
    LItemApothecaryIngredientsCommon75.addForm(SCL_MountainFlower01White, 1, 1)
    LItemIngredientsCommon.addForm(SCL_MountainFlower01White, 1, 1)

    LItemBarrelFoodSame70.addForm(SCL_Lemon, 15, 2)
    LItemBarrelFoodSame75.addForm(SCL_Lemon, 15, 2)
    LItemMiscVendorMiscItems75.addForm(SCL_Lemon, 15, 5)

    LItemBarrelFoodSame70.addForm(SCL_Orange, 5, 2)
    LItemBarrelFoodSame75.addForm(SCL_Orange, 5, 2)
    LItemMiscVendorMiscItems75.addForm(SCL_Orange, 5, 5)

    LItemFoodInnCommon.addForm(SCL_WhiteMountainFlowerTea, 7, 2)

    SublistEnchArmorBandedIronCuirass01.AddForm(SCL_EnchArmorIronBandedCuirassHeavyBurden01, 1, 1)

    SublistEnchArmorOrcishBoots04.AddForm(SCL_EnchArmorOrcishBootsHeavyBurden04, 1, 1)

    SublistEnchArmorGlassCuirass03.AddForm(SCL_EnchArmorGlassCuirassHeavyBurden03, 1, 1)

    SublistEnchArmorDwarvenBoots02.AddForm(SCL_EnchArmorDwarvenBootsHeavyBurden02, 1, 1)

    SublistEnchArmorDragonplateBoots06.AddForm(SCL_EnchArmorDragonplateCuirassHeavyBurden06, 1, 1)

    SublistEnchArmorDragonplateBoots05.AddForm(SCL_EnchArmorDragonplateBootsHeavyBurden05, 1, 1)

    SublistEnchArmorDaedricCuirass05.AddForm(SCL_EnchArmorDaedricCuirassHeavyBurden05, 1, 1)

    SublistEnchArmorDaedricBoots04.AddForm(SCL_EnchArmorDaedricBootsHeavyBurden04, 1, 1)

    LItemPotionAllSkills.AddForm(SCL_LItemPotionFortifyStomachSkills, 1, 1)

    LItemEnchRingAll.addForm(SCL_LItemEnchRingSkillStomach, 1, 1)
    LItemEnchRingAll25.addForm(SCL_LItemEnchRingSkillStomach, 1, 1)
    LItemEnchRingAll75.addForm(SCL_LItemEnchRingSkillStomach, 1, 1)

    LItemEnchNecklaceAll.addForm(SCL_LItemEnchNecklaceGlutton, 1, 1)
    LItemEnchNecklaceAll.addForm(SCL_LItemEnchNecklaceBaseCap, 1, 1)
    LItemEnchNecklaceAll.addForm(SCL_LItemEnchNecklaceDigestRate, 1, 1)

    LItemEnchNecklaceAll25.addForm(SCL_LItemEnchNecklaceGlutton, 1, 1)
    LItemEnchNecklaceAll25.addForm(SCL_LItemEnchNecklaceBaseCap, 1, 1)
    LItemEnchNecklaceAll25.addForm(SCL_LItemEnchNecklaceDigestRate, 1, 1)
  EndIf
  Return ScriptVersion
EndFunction
