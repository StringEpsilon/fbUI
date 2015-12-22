#include once "../fbUI.bas"

using fbUI

declare sub ToggleCallback (payload as uiControl ptr)
declare sub listboxSelection (payload as uiControl ptr)
declare sub ScrollbarChanged (payload as uiControl ptr)
declare sub ScrollbarChanged2 (payload as uiControl ptr)

loadUI("controls.json")

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()

fbGUI->GetControl("vscrollbar")->callback = @ScrollbarChanged
fbGUI->GetControl("hscrollbar")->callback = @ScrollbarChanged2
fbGUI->GetControl("spinnerToggle")->callback = @ToggleCallback
fbGUI->GetControl("listbox")->callback = @listboxSelection

threadcreate(@StartSpinnerAnimation,fbGUI->GetControl("spinner"))
fbGUI->Main()

sub listboxSelection(caller as uiControl ptr)
	if (caller <> 0 ) then
		cast(uiLabel ptr,uiWindow.GetInstance()->GetControl("listboxLabel"))->Text = cast(uiListBox ptr, caller)->Selection
	end if
end sub

sub ToggleCallback(caller as uiControl ptr)
	if (caller <> 0 ) then
		cast(uiSpinner ptr,uiWindow.GetInstance()->GetControl("spinner"))->State = cast(uiToggleButton ptr, caller)->Value
	end if
end sub

sub ScrollbarChanged (caller as uiControl ptr)
	if (caller <> 0 ) then
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, caller)
		cast(uiLabel ptr,uiWindow.GetInstance()->GetControl("vscrollbarLabel"))->Text =  "V Scrollbar: " & vscrollbar->Value
	end if
end sub

sub ScrollbarChanged2 (caller as uiControl ptr)
	if (caller <> 0 ) then
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, caller)
		cast(uiLabel ptr,uiWindow.GetInstance()->GetControl("hscrollbarLabel"))->Text =  "V Scrollbar: " & vscrollbar->Value
	end if
end sub
