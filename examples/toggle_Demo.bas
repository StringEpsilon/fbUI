#INCLUDE once "fbgfx.bi"

#include once "../common/uiWindow.bas"
#include once "../elements/uiToggleButton.bas"
#include once "../elements/uiLabel.bas"

declare sub btnCallback (payload as any ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiToggleButton ptr toggleButton
dim shared as uiLabel ptr label 

'Create the elements and add them to the UI:
label = new uiLabel(50, 50, "Hello World!")  
toggleButton = new uiToggleButton(50,5, "Disabled") 
toggleButton->callback = @btnCallback

fbGUI->AddElement(toggleButton)
fbGUI->CreateWindow(200,100)

' Start the event loop and the main UI thread:
fbGUI->Main()
' You can exit the UI with ctrl+q

' Destroy the uiElements:
delete(toggleButton)
delete(label)

sub btnCallback (payload as any ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim button as uiToggleButton ptr = cast(uiToggleButton ptr, payload)
		
		if (button->State = false) then
			button->Label = "Disabled"
			uiWindow.GetInstance()->RemoveElement(label) 
			' Adding an element only draws the added element. Removing an element redraws everything.
		else
			button->Label = "Enabled"
			' The label-property will queue a redraw for the button.
			uiWindow.GetInstance()->AddElement(label)
			' While removing should be safe, AddElement currently does not check for duplicates.
		end if
	end if
end sub     
