ScriptName SCX_SkyrimSet Extends SCX_GameLibrary

ObjectReference Property QASmokeLocation Auto
Container Property SCX_TransferContainerBase Auto
Container Property SCX_TransferContainer2Base Auto

Int ScriptVersion = 1
Int Function checkVersion(Int aiStoredVersion)
  {Return the new version and the script will update the stored version}
  If ScriptVersion >= 1 && aiStoredVersion < 1
    SCXSet._TransferChest01 = QASmokeLocation.PlaceAtMe(SCX_TransferContainerBase, 1, True, False)
    SCXSet._TransferChest02 = QASmokeLocation.PlaceAtMe(SCX_TransferContainer2Base, 1, True, False)
  EndIf
  Return 1
EndFunction

String Function getRaceString(Actor akTarget)
  Race akRace = akTarget.GetRace()
  If akRace.HasKeyword(ActorTypeNPC)
    Return "Human"
  ElseIf akRace == WolfRace
    Return "Wolf"
  Else
    Return ""
  EndIf
EndFunction

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
