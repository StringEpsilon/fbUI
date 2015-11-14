#include once "../common/window.bas"
#include once "../controls/listbox.bas"

using fbUI

declare sub ListBoxCallback (payload as uiControl ptr)
dim shared as uiLabel ptr label1
dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiListbox ptr listbox = new uiListbox( 5, 5, 80,180)

label1 = new uiLabel(5,100, "Selection: ",20)
for i as integer = 0 to 10
	listbox->AddElement("Item "& i)
next

listbox->Callback = @ListBoxCallback
fbGUI->AddElement(listbox)
fbGUI->AddElement(label1)
fbGUI->CreateWindow(120,200)

fbGUI->Main()
delete(listbox)

sub ListBoxCallback (payload as uiControl ptr)
	if (payload <> 0 ) then
		label1->Text =  "Selection: " & cast(uiListBox ptr, payload)->Selection
	end if
end sub
