#INCLUDE once "fbgfx.bi"

#include once "../common/uiWindow.bas"
#include once "../elements/uiTextbox.bas"
#include once "../elements/uiLabel.bas"

declare sub ElementCallback (payload as any ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim shared label as uiLabel ptr
label = new uiLabel(5,5,"",25)
dim as uiTextbox ptr textbox = new uiTextbox( 5, 25, 190)

textbox->callback = @ElementCallback

fbGUI->AddElement(label)
fbGUI->AddElement(textbox)
fbGUI->CreateWindow(100,200)

fbGUI->Main()

delete(textbox)

sub ElementCallback (payload as any ptr)
	if (payload <> 0 ) then
		label->Text = cast(uiTextbox ptr, payload)->Text
	end if
end sub     