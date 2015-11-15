#INCLUDE once "fbgfx.bi"

#include once "../common/window.bas"
#include once "../controls/textbox.bas"
#include once "../controls/label.bas"

using fbUI

declare sub ElementCallback (payload as uiControl ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim shared label as uiLabel ptr
label = new uiLabel(5,5,"",25)
dim as uiTextbox ptr textbox = new uiTextbox( 5, 25, 190)

textbox->callback = @ElementCallback

fbGUI->AddControl(new uiLabel(5,40,"Type & press Enter",25))
fbGUI->AddControl(label)
fbGUI->AddControl(textbox)
fbGUI->CreateWindow(100,200)

fbGUI->Main()

delete(textbox)

sub ElementCallback (payload as uiControl ptr)
	if (payload <> 0 ) then
		label->Text = cast(uiTextbox ptr, payload)->Value
	end if
end sub     
