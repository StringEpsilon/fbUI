' #define fbJson_DEBUG

#include once "../fbUI.bas"

using fbUI

declare sub ElementCallback (payload as uiControl ptr)
dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim shared label as uiLabel ptr
label = new uiLabel(5,5,"",25)

dim as jsonItem json = jsonItem("{""dimensions"": { ""x"": 5, ""y"": 25, ""w"": 190 }, ""value"": ""Test""}")

dim as uiTextbox ptr textbox = new uiTextbox( json )

label->Text = textBox->value

textbox->callback = @ElementCallback

fbGUI->AddControl(new uiLabel(5,40,"Type & press Enter",25))
fbGUI->AddControl(label)
fbGUI->AddControl(textbox)
fbGUI->CreateWindow(100,200)

fbGUI->Main()

sub ElementCallback (payload as uiControl ptr)
	if (payload <> 0 ) then
		label->Text = cast(uiTextbox ptr, payload)->Value
	end if
end sub     
