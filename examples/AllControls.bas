#include once "../common/window.bas"
#include once "../controls/toggleButton.bas"
#include once "../controls/spinner.bas"
#include once "../controls/listbox.bas"


using fbUI

declare sub btnCallback (payload as uiControl ptr)
declare sub listboxSelection (payload as uiControl ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiToggleButton ptr toggleButton
dim shared as uiSpinner ptr spinner 
dim as uiListbox ptr listbox = new uiListbox( 100, 5, 80,100)
dim shared as uiLabel ptr listboxLabel
listboxLabel = new uiLabel( 205, 5, "Select!")

for i as integer = 0 to 10
	listbox->AddElement("Item "& i)
next

spinner = new uiSpinner(5, 25, 24 )  
toggleButton = new uiToggleButton(5,5, "Disabled") 
toggleButton->callback = @btnCallback
listbox->callback = @listboxSelection

fbGUI->AddElement(spinner)
fbGUI->AddElement(toggleButton)
fbGUI->AddElement(listbox)
fbGUI->AddElement(listboxLabel)
fbGUI->CreateWindow(200,400)

fbGUI->Main()

threadcreate(@StartSpinnerAnimation,spinner)

fbGUI->Main()

sub listboxSelection(payload as uiControl ptr)
	if (payload <> 0 ) then
		listboxLabel->Text = cast(uiListBox ptr, payload)->Selection
	end if
end sub


sub btnCallback (payload as uiControl ptr)
	if (payload <> 0 ) then
		spinner->State = cast(uiToggleButton ptr, payload)->State
	end if
end sub     
