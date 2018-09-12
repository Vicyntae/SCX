ScriptName SCX_Bundle Extends ObjectReference
{This now works simply as a container. Just access the items via GetNthForm()}
Actor Property Owner Auto
Int Property ItemEntry Auto

Form Property ItemForm
  Form Function get()
    Return GetNthForm(0)
  EndFunction
EndProperty

Int Property ItemNum Auto

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
