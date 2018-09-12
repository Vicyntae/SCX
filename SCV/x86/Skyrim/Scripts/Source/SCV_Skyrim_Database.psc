ScriptName SCV_Skyrim_Database Extends SCV_GameLibrary

Race Property ArgonianRace Auto
Race Property ArgonianRaceVampire Auto
Race Property BretonRaceVampire Auto
Race Property DarkElfRaceVampire Auto
Race Property ElderRaceVampire Auto
Race Property ImperialRaceVampire Auto
Race Property KhajiitRaceVampire Auto
Race Property NordRaceVampire Auto
Race Property OrcRaceVampire Auto
Race Property RedguardRaceVampire Auto
Race Property WoodElfRaceVampire Auto
Race Property BearBlackRace Auto
Race Property BearBrownRace Auto
Race Property BearSnowRace Auto
Race Property ChaurusRace Auto
Race Property ChaurusReaperRace Auto
Race Property ChickenRace Auto
Race Property CowRace Auto
Race Property DeerRace Auto
Race Property DogRace Auto
Race Property ElkRace Auto
Race Property FoxRace Auto
Race Property FrostbiteSpiderRace Auto
Race Property FrostbiteSpiderRaceGiant Auto
Race Property FrostbiteSpiderRaceLarge Auto
Race Property GiantRace Auto
Race Property GoatRace Auto
Race Property GoatDomesticsRace Auto
Race Property HagravenRace Auto
Race Property HareRace Auto
Race Property HorkerRace Auto
Race Property HorseRace Auto
Race Property IceWrathRace Auto
Race Property MagicAnomalyRace Auto
Race Property MammothRace Auto
Race Property MudcrabRace Auto
Race Property RigidSkeletonRace Auto
Race Property SabreCatRace Auto
Race Property SabreCatSnowyRace Auto
Race Property SkeeverRace Auto
Race Property SkeeverWhiteRace Auto
Race Property SkeletonNecroRace Auto
Race Property SkeletonRace Auto
Race Property SlaughterFishRace Auto
Race Property SprigganMatronRace Auto
Race Property SprigganRace Auto
Race Property SprigganSwarmRace Auto
Race Property SwarmRace Auto
Race Property TrollFrostRace Auto
Race Property TrollRace Auto
Race Property WerewolfBeastRace Auto
Race Property WhiteStagRace Auto
Race Property WispRace Auto
Race Property WolfRace Auto
Race Property AlduinRace Auto
Race Property DragonRace Auto
Race Property UndeadDragonRace Auto

MiscObject Property SCV_DragonGem Auto
MiscObject Property SCV_SplendidSoulGem Auto
Soulgem Property SoulGemBlack Auto
Soulgem Property SoulGemBlackFilled Auto
Soulgem Property SoulGemGrand Auto
Soulgem Property SoulGemGrandFilled Auto
Soulgem Property SoulGemGreater Auto
Soulgem Property SoulGemGreaterFilled Auto
Soulgem Property SoulGemCommon Auto
Soulgem Property SoulGemCommonFilled Auto
Soulgem Property SoulGemLesser Auto
Soulgem Property SoulGemLesserFilled Auto
Soulgem Property SoulGemPetty Auto
Soulgem Property SoulGemPettyFilled Auto
MiscObject Property SoulGemPiece001 Auto
MiscObject Property SoulGemPiece002 Auto
MiscObject Property SoulGemPiece003 Auto
MiscObject Property SoulGemPiece004 Auto
MiscObject Property SoulGemPiece005 Auto

Function Setup()
  SCVSet.GameLibrary = Self
EndFunction

Int ScriptVersion = 1
Int Function checkVersion(Int aiStoredVersion)
  {Return the new version and the script will update the stored version}
  If ScriptVersion >= 1 && aiStoredVersion < 1
    ;JFormDB.solveFltSetter(Game.GetFormFromFile(0x000f2011, "Skyrim.esm"), ".SCLItemDatabase.LiquidRatio", 0.1, True)

    JFormDB.solveIntSetter(SCVSet.SCV_DummyFoodItem, ".SCX_ItemDatabase.STIsNotFood", 1, True)


    ;RaceData
    ;ArgonianRace
    JFormDB.solveFltSetter(ArgonianRace, ".SCX_ItemDatabase.Durablity", 0.8, True)
    ;ArgonianRaceVampire
    JFormDB.solveFltSetter(ArgonianRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;BretonRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013741, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;BretonRaceVampire
    JFormDB.solveFltSetter(BretonRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;DarkElfRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013742, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;DarkElfRaceVampire
    JFormDB.solveFltSetter(DarkElfRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;ElderRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00067CD8, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;ElderRaceVampire
    JFormDB.solveFltSetter(ElderRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;ImperialRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013744, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;ImperialRaceVampire
    JFormDB.solveFltSetter(ImperialRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;KhajiitRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013745, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;KhajiitRaceVampire
    JFormDB.solveFltSetter(KhajiitRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;NordRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013746, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;NordRaceVampire
    JFormDB.solveFltSetter(NordRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;OrcRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013747, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;OrcRaceVampire
    JFormDB.solveFltSetter(OrcRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;RedguardRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013748, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;RedguardRaceVampire
    JFormDB.solveFltSetter(RedguardRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;WoodElfRace
    ;JFormDB.solveIntSetter(Game.GetFormFromFile(0x00013749, "Skyrim.esm") as Race, ".SCX_ItemDatabase.STValidRace", 1, True)
    ;WoodElfRaceVampire
    JFormDB.solveFltSetter(WoodElfRaceVampire, ".SCX_ItemDatabase.WeightModifier", 0.5, True)

    ;Animal Races ****************************************************************

    ;BearBlackRace
    JFormDB.solveFltSetter(BearBlackRace, ".SCX_ItemDatabase.WeightOverride", 300, True)

    ;BearBrownRace
    JFormDB.solveFltSetter(BearBrownRace, ".SCX_ItemDatabase.WeightOverride", 300, True)

    ;BearSnowRace
    JFormDB.solveFltSetter(BearSnowRace, ".SCX_ItemDatabase.WeightOverride", 300, True)

    ;ChaurusRace
    JFormDB.solveFltSetter(ChaurusRace, ".SCX_ItemDatabase.WeightOverride", 200, True)
    JFormDB.solveFltSetter(ChaurusRace, ".SCX_ItemDatabase.Durablity", 0.4, True)

    ;ChaurusReaperRace
    JFormDB.solveFltSetter(ChaurusReaperRace, ".SCX_ItemDatabase.WeightOverride", 250, True)
    JFormDB.solveFltSetter(ChaurusReaperRace, ".SCX_ItemDatabase.Durablity", 0.6, True)

    ;ChickenRace
    JFormDB.solveFltSetter(ChickenRace, ".SCX_ItemDatabase.WeightOverride", 3, True)

    ;CowRace
    JFormDB.solveFltSetter(CowRace, ".SCX_ItemDatabase.WeightOverride", 300, True)

    ;DeerRace
    JFormDB.solveFltSetter(DeerRace, ".SCX_ItemDatabase.WeightOverride", 150, True)

    ;DogRace
    JFormDB.solveFltSetter(DogRace, ".SCX_ItemDatabase.WeightOverride", 75, True)

    ;ElkRace
    JFormDB.solveFltSetter(ElkRace, ".SCX_ItemDatabase.WeightOverride", 250, True)

    ;FoxRace
    JFormDB.solveFltSetter(FoxRace, ".SCX_ItemDatabase.WeightOverride", 5, True)

    ;FrostbiteSpiderRace
    JFormDB.solveFltSetter(FrostbiteSpiderRace, ".SCX_ItemDatabase.WeightOverride", 75, True)
    JFormDB.solveFltSetter(FrostbiteSpiderRace, ".SCX_ItemDatabase.Durablity", 0.8, True)

    ;FrostbiteSpiderRaceGiant
    JFormDB.solveFltSetter(FrostbiteSpiderRaceGiant, ".SCX_ItemDatabase.WeightOverride", 400, True)
    JFormDB.solveFltSetter(FrostbiteSpiderRaceGiant, ".SCX_ItemDatabase.Durablity", 0.8, True)

    ;FrostbiteSpiderRaceLarge
    JFormDB.solveFltSetter(FrostbiteSpiderRaceLarge, ".SCX_ItemDatabase.WeightOverride", 200, True)
    JFormDB.solveFltSetter(FrostbiteSpiderRaceLarge, ".SCX_ItemDatabase.Durablity", 0.8, True)

    ;GiantRace
    JFormDB.solveFltSetter(GiantRace, ".SCX_ItemDatabase.WeightOverride", 600, True)

    ;GoatDomesticsRace
    JFormDB.solveFltSetter(GoatDomesticsRace, ".SCX_ItemDatabase.WeightOverride", 30, True)

    ;GoatRace
    JFormDB.solveFltSetter(GoatRace, ".SCX_ItemDatabase.WeightOverride", 30, True)

    ;HagravenRace
    JFormDB.solveFltSetter(HagravenRace, ".SCX_ItemDatabase.WeightOverride", 60, True)

    ;HareRace
    JFormDB.solveFltSetter(HareRace, ".SCX_ItemDatabase.WeightOverride", 3, True)

    ;HorkerRace
    JFormDB.solveFltSetter(HorkerRace, ".SCX_ItemDatabase.WeightOverride", 500, True)

    ;HorseRace
    JFormDB.solveFltSetter(HorseRace, ".SCX_ItemDatabase.WeightOverride", 550, True)

    ;IceWrathRace
    JFormDB.solveFltSetter(IceWrathRace, ".SCX_ItemDatabase.WeightOverride", 5, True)
    JFormDB.solveFltSetter(IceWrathRace, ".SCX_ItemDatabase.Durablity", 0.7, True)

    ;MagicAnomalyRace
    JFormDB.solveFltSetter(MagicAnomalyRace, ".SCX_ItemDatabase.WeightOverride", 1, True)

    ;MammothRace
    JFormDB.solveFltSetter(MammothRace, ".SCX_ItemDatabase.WeightOverride", 2000, True)

    ;MudcrabRace
    JFormDB.solveFltSetter(MudcrabRace, ".SCX_ItemDatabase.WeightOverride", 15, True)
    JFormDB.solveFltSetter(MudcrabRace, ".SCX_ItemDatabase.Durablity", 0.75, True)

    ;RigidSkeletonRace
    JFormDB.solveFltSetter(RigidSkeletonRace, ".SCX_ItemDatabase.WeightOverride", 40, True)
    JFormDB.solveFltSetter(RigidSkeletonRace, ".SCX_ItemDatabase.Durablity", 0.5, True)


    ;SabreCatRace
    JFormDB.solveFltSetter(SabreCatRace, ".SCX_ItemDatabase.WeightOverride", 200, True)

    ;SabreCatSnowyRace
    JFormDB.solveFltSetter(SabreCatSnowyRace, ".SCX_ItemDatabase.WeightOverride", 200, True)

    ;SkeeverRace
    JFormDB.solveFltSetter(SkeeverRace, ".SCX_ItemDatabase.WeightOverride", 5, True)

    ;SkeeverWhiteRace
    JFormDB.solveFltSetter(SkeeverWhiteRace, ".SCX_ItemDatabase.WeightOverride", 5, True)

    ;SkeletonNecroRace
    JFormDB.solveFltSetter(SkeletonNecroRace, ".SCX_ItemDatabase.WeightOverride", 40, True)
    JFormDB.solveFltSetter(SkeletonNecroRace, ".SCX_ItemDatabase.Durablity", 0.5, True)

    ;SkeletonRace
    JFormDB.solveFltSetter(SkeletonRace, ".SCX_ItemDatabase.WeightOverride", 40, True)
    JFormDB.solveFltSetter(SkeletonRace, ".SCX_ItemDatabase.Durablity", 0.5, True)

    ;SlaughterFishRace
    JFormDB.solveFltSetter(SlaughterFishRace, ".SCX_ItemDatabase.WeightOverride", 5, True)

    ;SprigganMatronRace
    JFormDB.solveFltSetter(SprigganMatronRace, ".SCX_ItemDatabase.WeightOverride", 120, True)
    JFormDB.solveFltSetter(SprigganMatronRace, ".SCX_ItemDatabase.Durablity", 0.7, True)

    ;SprigganRace
    JFormDB.solveFltSetter(SprigganRace, ".SCX_ItemDatabase.WeightOverride", 100, True)
    JFormDB.solveFltSetter(SprigganRace, ".SCX_ItemDatabase.Durablity", 0.8, True)

    ;SprigganSwarmRace
    JFormDB.solveIntSetter(SprigganSwarmRace, ".SCX_ItemDatabase.SCVPreyBlocked", 1, True)

    ;SwarmRace
    JFormDB.solveIntSetter(SwarmRace, ".SCX_ItemDatabase.SCVPreyBlocked", 1, True)

    ;TrollFrostRace
    JFormDB.solveFltSetter(TrollFrostRace, ".SCX_ItemDatabase.WeightOverride", 300, True)

    ;TrollRace
    JFormDB.solveFltSetter(TrollRace, ".SCX_ItemDatabase.WeightOverride", 300, True)

    ;WerewolfBeastRace
    JFormDB.solveFltSetter(WerewolfBeastRace, ".SCX_ItemDatabase.WeightOverride", 350, True)

    ;WhiteStagRace
    JFormDB.solveIntSetter(WhiteStagRace, ".SCX_ItemDatabase.SCVPreyBlocked", 1, True)

    ;WispRace
    JFormDB.solveFltSetter(WispRace, ".SCX_ItemDatabase.WeightOverride", 1, True)

    ;WolfRace
    JFormDB.solveFltSetter(WolfRace, ".SCX_ItemDatabase.WeightOverride", 80, True)

    ;Dragon Races ****************************************************************
    ;AlduinRace
    JFormDB.solveFltSetter(AlduinRace, ".SCX_ItemDatabase.WeightOverride", 3000, True)
    JFormDB.solveFltSetter(AlduinRace, ".SCX_ItemDatabase.Durablity", 0.2, True)

    ;DragonRace
    JFormDB.solveFltSetter(DragonRace, ".SCX_ItemDatabase.WeightOverride", 2500, True)
    JFormDB.solveFltSetter(DragonRace, ".SCX_ItemDatabase.Durablity", 0.4, True)

    ;UndeadDragonRace
    JFormDB.solveFltSetter(UndeadDragonRace, ".SCX_ItemDatabase.WeightOverride", 1500, True)
    JFormDB.solveFltSetter(UndeadDragonRace, ".SCX_ItemDatabase.Durablity", 0.3, True)

    ;Messages ******************************************************************
    SCX_Library.addMessage("SCVOVPredDevour1", "Hmm! Tasty!")
    SCX_Library.addMessage("SCVOVPredDevour1", "So nice to have you for dinner!")
    SCX_Library.addMessage("SCVOVPredDevour1", "Not bad.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Nice to EAT you! Maybe I should keep these things to myself.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Could use some seasoning, but it's acceptable.")
    SCX_Library.addMessage("SCVOVPredDevour1", "I've had better.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Mmm, HMM! *GULP*")
    SCX_Library.addMessage("SCVOVPredDevour1", "Yum!")
    SCX_Library.addMessage("SCVOVPredDevour1", "More, please!")
    SCX_Library.addMessage("SCVOVPredDevour1", "Into my belly you go!")
    SCX_Library.addMessage("SCVOVPredDevour1", "In my mouth. NOW.")
    SCX_Library.addMessage("SCVOVPredDevour1", "A meal fit for... well, not a king, but someone.")
    SCX_Library.addMessage("SCVOVPredDevour1", "No complaints.")
    SCX_Library.addMessage("SCVOVPredDevour1", "I should try to find more... appetizing, meals")
    SCX_Library.addMessage("SCVOVPredDevour1", "I should start carrying salt with me.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Down the hatch!")
    SCX_Library.addMessage("SCVOVPredDevour1", "Don't worry, my belly will take good care of you.")
    SCX_Library.addMessage("SCVOVPredDevour1", "I hope no one minds the bulge in my stomach.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Not the best.")
    SCX_Library.addMessage("SCVOVPredDevour1", "*BEEEELLLLCH!!!*... Excuse me.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Welcome to your new home.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Thank the gods, you tasted okay.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Feels nice having someone new in my belly.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Alright! Who's next!")
    SCX_Library.addMessage("SCVOVPredDevour1", "I wouldn't mind eating you again.")
    SCX_Library.addMessage("SCVOVPredDevour1", "Perhaps a nice sauce would improve this meal.")

    SCX_Library.addMessage("SCVOVPredCantEatFull1", "I can't eat that! I'm too full!")
    SCX_Library.addMessage("SCVOVPredCantEatFull1", "I would love to eat that, but I don't think it'll fit.")
    SCX_Library.addMessage("SCVOVPredCantEatFull1", "Tempting, but no. Too full.")
    SCX_Library.addMessage("SCVOVPredCantEatFull1", "Nope. Have to think about my figure.")
    SCX_Library.addMessage("SCVOVPredCantEatFull1", "I'd need a lot of muscle relaxers to be able to eat that.")
    SCX_Library.addMessage("SCVOVPredCantEatFull2", "You can't eat that. You're too full.")
    SCX_Library.addMessage("SCVOVPredCantEatFull2", "You would love to eat that, but you don't think it'll fit.")
    SCX_Library.addMessage("SCVOVPredCantEatFull2", "You find the meal very tempting, but worry it would be too much.")
    SCX_Library.addMessage("SCVOVPredCantEatFull2", "You would need to take a lot of muscle relaxers before you could eat that.")
    SCX_Library.addMessage("SCVOVPredCantEatFull3", "%p can't eat that; they're too full.")
    SCX_Library.addMessage("SCVOVPredCantEatFull3", "%p would love to eat that, but they don't think it'll fit.")
    SCX_Library.addMessage("SCVOVPredCantEatFull3", "%p thinks that it is very tempting, but fears that it would be too much.")
    SCX_Library.addMessage("SCVOVPredCantEatFull3", "%p would need to take a lot of muscle relaxers before they could eat that.")

    SCX_Library.addMessage("SCVOVPredDevourPositive1", "Oh GODS, let me eat you again!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "I'm tempted to vomit you up just so I can eat you again.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "*GASP* That's GOOD!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "If I never ate again after this, I could still die happy.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "Perfection.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "More! MORE!!!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "So delicious!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "How do you taste SO GOOD!?")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "Sorry I licked you on the way down, you just tasted so good.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "Let me savor this moment.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "I haven't eaten this good since that incident in the Reach!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "I can't think of anything to make this meal better.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "Going back for seconds! Maybe even thirds!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "There's just. So much FLAVOR!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "The finest chefs in all of Tamriel couldn't make a better meal.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "I feel so pampered!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "What did I do to deserve such a blessed meal!?")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "How do you make yourself so tasty?")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "If only you were fatter... More for me to eat!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "Finally, some good food.")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "It's a party in my mouth!")
    SCX_Library.addMessage("SCVOVPredDevourPositive1", "My compliments to the chef.")

    SCX_Library.addMessage("SCVOVPredDevourStealth1", "Sneaky sneaky, munchy munchy.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "Shhh. That's right, in you go.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "Quickly! Hide in my mouth!")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "Shush stomach, food's coming right now.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "*Rumble*... Nobody heard that, right?")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "*Burrp!*... Excuse me.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "It's going to be hard to sneak with you in my belly.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "You better not get me spotted.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "I'm going to need you to be quiet.")
    SCX_Library.addMessage("SCVOVPredDevourStealth1", "Keep quiet, and I may let you out.")

    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Yikes. You did NOT taste good.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Ugh, I think I liked you outside my belly than in.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "When was the last you bathed? Just foul.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "You taste like dirt and sadness.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "If I wanted to eat crap, I would've gone to eat at your mother's.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "You taste like something cooked by a falmer.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "The best spices in Cyrodiil couldn't save this meal.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Bleh, I'm going to need a strong ale to wash this down.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Send this back to the chef!")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Looks better than it tastes.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I don't want to finish this... Not worth the effort.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "What have I done to deserve this wretched meal?")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I can barely keep this down.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "PLAYER! Do NOT feed me that again!")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "With a decent sauce, this.. would still be terrible.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Must not puke. Must NOT puke.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I should puke you up on taste alone.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "My tongue feels violated.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I detect a hint of fetid cheese, and an aftertaste of orc ass.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "SOAP, people! Do you know what it is?")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I regret every decision that led up to me eating you.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I'm sure you're very pleasant to be around, but you leave a bad taste in my mouth.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "I feel there was more productive and flavor things that I could've done instead of eating you.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Why do you taste BITTER!?")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Is there a spell to make you taste better? Or at least numb my tongue?")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "Sometimes I regret becoming a predator.")
    SCX_Library.addMessage("SCVOVPredDevourNegative1", "This... this tastes like death.")

    SCX_Library.addMessage("SCVOVPredStruggle1", "Ohh, feisty!")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Stop moving already!")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Belly's bouncing!")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Yeah, keep fighting! See what happens!")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Are you done yet?")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Let's get you some light. *Yawn*")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Relax! It'll be over soon.")
    SCX_Library.addMessage("SCVOVPredStruggle1", "I have more important things to do than to wait for you to fall asleep.")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Your struggles only amuse me.")
    SCX_Library.addMessage("SCVOVPredStruggle1", "Hey, that tickles!")
    SCX_Library.addMessage("SCVOVPredStruggle1", "What's that? I can't hear you over my stomach rumbling.")
    ;SCX_Library.addMessage("SCVOVPredStruggle1", "")

    SCX_Library.addMessage("SCVAVPredStruggle1", "Ohh, feisty!")
    SCX_Library.addMessage("SCVAVPredStruggle1", "Stop moving already!")
    SCX_Library.addMessage("SCVAVPredStruggle1", "Yeah, keep fighting! See what happens!")
    SCX_Library.addMessage("SCVAVPredStruggle1", "Are you done yet?")
    SCX_Library.addMessage("SCVAVPredStruggle1", "Relax! It'll be over soon.")
    SCX_Library.addMessage("SCVAVPredStruggle1", "I have more important things to do than to wait for you to fall asleep.")
    SCX_Library.addMessage("SCVAVPredStruggle1", "Your struggles only amuse me.")
    SCX_Library.addMessage("SCVAVPredStruggle1", "Hey, that tickles!")

    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "Ow, hey!")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "That hurts!")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "My tummy hurts.")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "I don't have butterflys in my stomach, apparently I have BEES!")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "Oof!")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "Oh, gods. This hurts.")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "Feels like I ate a porcupine.")
    SCX_Library.addMessage("SCVOVPredStruggleDamage1", "What are you DOING in there!?")
    ;SCX_Library.addMessage("SCVOVPredStruggleDamage1", "")

    SCX_Library.addMessage("SCVAVPredStruggleDamage1", "Ow, hey!")
    SCX_Library.addMessage("SCVAVPredStruggleDamage1", "That hurts!")
    SCX_Library.addMessage("SCVAVPredStruggleDamage1", "Oof!")
    SCX_Library.addMessage("SCVAVPredStruggleDamage1", "Oh, gods. This hurts.")
    SCX_Library.addMessage("SCVAVPredStruggleDamage1", "What are you DOING in there!?")
    ;SCX_Library.addMessage("SCVAVPredStruggleDamage1", "")

    SCX_Library.addMessage("SCVOVPredStruggleTired1", "You can't go on forever...")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "Don't know if I can last much longer...")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "Can't go on...")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "Hope you finish soon...")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "I feel something crawling up my throat!")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "Dammit, stay down!")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "*Pant* *Pant* This better finish soon")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "I should drink a stamina potion.")
    SCX_Library.addMessage("SCVOVPredStruggleTired1", "You're wearing me out!")
    ;SCX_Library.addMessage("SCVOVPredStruggleTired1", "")

    SCX_Library.addMessage("SCVAVPredStruggleTired1", "You can't go on forever...")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "Don't know if I can last much longer...")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "Can't go on...")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "Hope you finish soon...")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "Dammit, stay down!")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "*Pant* *Pant* This better finish soon")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "I should drink a stamina potion.")
    SCX_Library.addMessage("SCVAVPredStruggleTired1", "You're wearing me out!")


    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "*Beeeelch!* Oh, that felt good!")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "Hey! You awake in there?")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "Another one bites the dust.")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "*Poke's belly* You OK?")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "Don't feel bad! You were eaten by the Dragonborn!")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "Oof. That was a rough meal.")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "Good! Less of a strain on my poor belly.")
    SCX_Library.addMessage("SCVOVPredStruggleFinished1", "Ugh, this is going to go straight to my thighs.")
    ;SCX_Library.addMessage("SCVOVPredStruggleFinished1", "")

    SCX_Library.addMessage("SCVAVPredStruggleFinished1", "Are you done in there? It hurts to sit when you're in my ass.")
    SCX_Library.addMessage("SCVAVPredStruggleFinished1", "Hey! You awake in there?")
    SCX_Library.addMessage("SCVAVPredStruggleFinished1", "Another one bites the dust.")
    ;SCX_Library.addMessage("SCVAVPredStruggleFinished1", "")


    SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "Finally! I need a belly rub.")
    SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "Hmm? Oh, all gone.")
    SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "Pity; it was starting to feel good.")
    SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "BUURRRRRRPPPP. Nice.")
    SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "Feeling pretty dead in there.")
    SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "*Jiggle* *Jiggle* Anybody awake in there?")
    ;SCX_Library.addMessage("SCVOVPredAllStruggleFinished1", "")

    SCX_Library.addMessage("SCVAVPredAllStruggleFinished1", "Finally! That was a pain in the rear.")
    SCX_Library.addMessage("SCVAVPredAllStruggleFinished1", "Pity; it was starting to feel good.")
    SCX_Library.addMessage("SCVAVPredAllStruggleFinished1", "Hmm? Oh, all gone.")

    SCX_Library.addMessage("SCVOVPredStartFrenzy1", "I suddenly feel very... hungry.")
    SCX_Library.addMessage("SCVOVPredStartFrenzy1", "I... I... I NEED FOOD!!!")
    SCX_Library.addMessage("SCVOVPredStartFrenzy1", "HUNGRY!")
    SCX_Library.addMessage("SCVOVPredStartFrenzy1", "I can't think... I can't think... Except... FOOOODDD!")
    SCX_Library.addMessage("SCVOVPredStartFrenzy1", "*RUMBLE* That can't be good.")
    ;SCX_Library.addMessage("SCVOVPredStartFrenzy1", "")

    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "Need to find food... Need to find food!")
    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "I'm wasting away!")
    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "It feels like my stomach is eating itself!")
    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "I need to find food NOW!")
    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "Gotta fill this belly!")
    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "Do I have anything in my pack to eat?")
    SCX_Library.addMessage("SCVOVPredFrenzyLow1", "Mmmmhh... Food...")

    SCX_Library.addMessage("SCVOVPredFrenzyFollowerLow1", "Maybe I should ask %t if they have any food.")
    SCX_Library.addMessage("SCVOVPredFrenzyFollowerLow1", "I wonder if %t have a snack?")
    SCX_Library.addMessage("SCVOVPredFrenzyFollowerLow1", "Did %t always smell so nice?")
    SCX_Library.addMessage("SCVOVPredFrenzyFollowerLow1", "Is %t withholding food from me? I smell something really good!")
    SCX_Library.addMessage("SCVOVPredFrenzyFollowerLow1", "Why do I drool when I look at %t?")
    SCX_Library.addMessage("SCVOVPredFrenzyFollowerLow1", "For some reason, %t is just... irresitable right now.")

    ;Check pFollowerAlias to see if we can't find who our teammate is.


    SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "I need to eat this NOW.")
    SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "I don't think this will help... but it can't hurt!")
    SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "Hope this helps!")
    SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "Ohhh... Tasty!")
    SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "Looks delicious!")
    SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "Hope no one minds if I take this.")
    ;SCX_Library.addMessage("SCVOVPredFrenzyFindFood1", "")

    SCX_Library.addMessage("SCVOVPredFrenzyFindPrey1", "Ohhh, you look tasty!")
    SCX_Library.addMessage("SCVOVPredFrenzyFindPrey1", "IN MY MOUTH. NOW.")
    ;SCX_Library.addMessage("SCVOVPredFrenzyFindPrey1", "")

    SCX_Library.addMessage("SCVOVPredFrenzySatisfyLow1", "Better!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyLow1", "Hooo... Needed that!")
    ;SCX_Library.addMessage("SCVOVPredFrenzySatisfyLow1", "")

    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "MORE!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "IT'S NOT ENOUGH!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "MORE! GIVE ME MORE!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "TOO SMALL! NEED SOMETHING BIGGER!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "I WILL CONSUME THE WORLD!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "ALDUIN HAS NOTHING ON ME!")
    SCX_Library.addMessage("SCVOVPredFrenzySatisfyHigh1", "ALL OF NIRN WILL FEAR MY APPETITE!")

    ;SCX_Library.addMessage("SCVPredFrenzyHigh1", "")

    SCX_Library.addMessage("SCVOVPreyDevoured1", "HEY! Let go!")
    SCX_Library.addMessage("SCVOVPreyDevoured1", "Why is it dark all of a sudden?")
    SCX_Library.addMessage("SCVOVPreyDevoured1", "Eww, your breath smells!")
    SCX_Library.addMessage("SCVOVPreyDevoured1", "How DARE you swallow me!?")
    SCX_Library.addMessage("SCVOVPreyDevoured1", "No! NO!")

    SCX_Library.addMessage("SCVAVPreyDevoured1", "NO! Not in there!")
    ;SCX_Library.addMessage("SCVAVPreyDevoured1", "")


    SCX_Library.addMessage("SCVOVPreyStruggle1", "I need to get out of here!")
    ;SCX_Library.addMessage("SCVOVPreyStruggle1", "")


    SCX_Library.addMessage("SCVOVPreyStruggleTired1", "I can't go on much longer...")
    ;SCX_Library.addMessage("SCVOVPreyStruggleTired1", "")

    SCX_Library.addMessage("SCVOVPreyStruggleDamage1", "Ouch!")
    ;SCX_Library.addMessage("SCVOVPreyStruggleDamage1", "")


    SCX_Library.addMessage("SCVOVPreyFinished1", "I'm finished...")
    SCX_Library.addMessage("SCVOVPreyFinished1", "I... can't go on...")
    SCX_Library.addMessage("SCVOVPreyFinished1", "No more...")
    SCX_Library.addMessage("SCVOVPreyFinished1", "Goodbye world...")
    ;SCX_Library.addMessage("SCVOVPreyFinished1", "")
  EndIf

  Return ScriptVersion
EndFunction
