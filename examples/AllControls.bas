#include once "../common/window.bas"
#include once "../controls/toggleButton.bas"
#include once "../controls/spinner.bas"
#include once "../controls/listbox.bas"
#include once "../controls/radiobutton.bas"
#include once "../controls/textbox.bas"

using fbUI

declare sub btnCallback (payload as uiControl ptr)
declare sub listboxSelection (payload as uiControl ptr)
declare sub ScrollbarChanged (payload as uiControl ptr)
declare sub ScrollbarChanged2 (payload as uiControl ptr)

dim as uiTextbox ptr textbox = new uiTextbox(5,180, 110, "Hello World")
dim as uiRadiobutton ptr radio1 = new uiRadiobutton(305,5, "Option1")
dim as uiRadiobutton ptr radio2 = new uiRadiobutton(305,25, "Option2", radio1)
dim as uiRadiobutton ptr radio3 = new uiRadiobutton(305,45, "Option3", radio1)
dim as uiScrollBar ptr vscrollbar = new uiScrollBar( 5, 90, 80,20,0,5)
dim as uiScrollBar ptr hscrollbar = new uiScrollBar( 20,90, 80,10,0,3, horizontal)
dim as uiListbox ptr listbox = new uiListbox( 100, 5, 80,100)
dim as uiToggleButton ptr toggleButton = new uiToggleButton(5,5, "Disabled") 


dim shared as uiLabel ptr vscrollbarLabel, hscrollbarLabel
vscrollbarLabel = new uiLabel(20, 100, "V Scrollbar: 0",16)
hscrollbarLabel = new uiLabel(20, 120, "H Scrollbar: 0",16)
vscrollbar->callback = @ScrollbarChanged
hscrollbar->callback = @ScrollbarChanged2

dim shared as uiLabel ptr listboxLabel
listboxLabel = new uiLabel( 205, 5, "Select!")

dim shared as uiSpinner ptr spinner
spinner = new uiSpinner(5, 25, 24 )

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()

for i as integer = 0 to 10
	listbox->AddElement("Item "& i)
next

toggleButton->callback = @btnCallback
listbox->callback = @listboxSelection

fbGUI->AddControl(spinner)
fbGUI->AddControl(textbox)
fbGUI->AddControl(toggleButton)
fbGUI->AddControl(listbox)
fbGUI->AddControl(listboxLabel)
fbGUI->AddControl(vscrollbar)
fbGUI->AddControl(hscrollbar)
fbGUI->AddControl(vscrollbarLabel)
fbGUI->AddControl(hscrollbarLabel)
fbGUI->AddControl(listboxLabel)
fbGUI->AddControl(radio1)
fbGUI->AddControl(radio2)
fbGUI->AddControl(radio3)
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
		spinner->State = cast(uiToggleButton ptr, payload)->Value
	end if
end sub     

sub ScrollbarChanged (payload as uiControl ptr)
	if (payload <> 0 ) then
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, payload)
		vscrollbarLabel->Text =  "V Scrollbar: " & vscrollbar->Value
	end if
end sub    

sub ScrollbarChanged2 (payload as uiControl ptr)
	if (payload <> 0 ) then
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, payload)
		hscrollbarLabel->Text =  "H Scrollbar: " & vscrollbar->Value
	end if
end sub
