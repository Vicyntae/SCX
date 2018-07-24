ScriptName SCX_Bundle Extends ObjectReference
{This now works simply as a container. Just access the items via GetNthForm()}
Actor Property Owner Auto
Int Property ItemEntry Auto

Form Property ItemForm
  Form Function get()
    Return GetNthForm(0)
  EndFunction
EndProperty

Int Property ItemNum
  Int Function get()
    Return GetItemCount(GetNthForm(0))
  EndFunction
  Function set(Int aiVal)
    Int CurrentNum = ItemNum
    If aiVal > ItemNum
      AddItem(ItemForm, aiVal - ItemNum, True)
    ElseIf aiVal < ItemNum
      RemoveItem(ItemForm, ItemNum - aiVal, True)
    EndIf
  EndFunction
EndProperty

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
