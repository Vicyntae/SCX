ScriptName SCX_BaseItemType Extends SCX_BaseRefAlias Hidden

Int Property ItemTypeID Auto

String Property ShortDescription Auto
String Property FullDescription Auto

String Property ContentsKey Auto

Int Function addToContents(Actor akTarget, ObjectReference akReference = None, Form akBaseObject = None, Int aiStoredItemType = 0, Float afWeightValueOverride = -1.0, Int aiItemCount = 1, Bool abMoveNow = True)
EndFunction

Int Function _getSCX_JC_List()
  Return SCXSet.JI_BaseItemTypes
EndFunction

Int Function _getIntKey()
  Return ItemTypeID
EndFunction

String Function _getStrKey()
  Return "SCX_ItemType" + ItemTypeID
EndFunction

String Function getItemListDesc(Form akItem, Int JM_ItemEntry)
  String Name
  If akItem as SCX_Bundle
    Form BundleItem = (akItem as SCX_Bundle).ItemForm
    Int NumItems = (akItem as SCX_Bundle).ItemNum
    If BundleItem as Actor
      Name = (BundleItem as Actor).GetLeveledActorBase().GetName() + "x" + NumItems
    ElseIf BundleItem as ObjectReference
      Name = (BundleItem as ObjectReference).GetBaseObject().GetName() + "x" + NumItems
    Else
      Name = BundleItem.GetName() + "x" + NumItems
    EndIf
  ElseIf akItem as Actor
    Name = (akItem as Actor).GetLeveledActorBase().GetName()
  ElseIf akItem as ObjectReference
    Name = (akItem as ObjectReference).GetBaseObject().GetName()
  Else
    Name = akItem.GetName()
  EndIf
  Float WeightValue = JMap.getFlt(JM_ItemEntry, "WeightValue")
  String Finished = Name + ": " + ShortDescription + ": " + WeightValue
  Return Finished
EndFunction
