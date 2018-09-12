ScriptName SCX_TrashObject Extends ObjectReference
{Item that will automatically delete itself after 2 in-game hours and drop any items.
Will also delete itself if examined and empty.}
Event OnInit()
  RegisterForSingleUpdateGameTime(2)
EndEvent

Event OnUpdateGameTime()
  Int i = GetNumItems()
  While i
    i -= 1
    Form kForm = GetNthForm(i)
    Int Num = GetItemCount(kForm)
    DropObject(kForm, Num)
  EndWhile
  Disable(True)
  DeleteWhenAble()
EndEvent

Event OnActivate(ObjectReference akActionRef)
  If akActionRef == Game.GetPlayer()
    RegisterForMenu("ContainerMenu")
  EndIf
EndEvent

Event OnMenuClose(string menuName)
  If GetNumItems() == 0
    Disable(True)
    DeleteWhenAble()
  EndIf
  UnregisterForMenu("ContainerMenu")
EndEvent
