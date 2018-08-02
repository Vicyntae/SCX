ScriptName SCX_SkyrimSet Extends SCX_BaseQuest

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
