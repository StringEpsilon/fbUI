#include once "../common/uiWindow.bas"
#include once "../elements/uiToggleButton.bas"
#include once "../elements/uiSpinner.bas"

declare sub btnCallback (payload as uiElement ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiToggleButton ptr toggleButton
dim shared as uiSpinner ptr spinner 

'Create the elements and add them to the UI:
spinner = new uiSpinner(88, 45, 24 )  
toggleButton = new uiToggleButton(50,5, "Disabled") 
toggleButton->callback = @btnCallback

fbGUI->AddElement(spinner)
fbGUI->AddElement(toggleButton)
fbGUI->CreateWindow(100,200)
' Start the event loop and the main UI thread:
fbGUI->Main()
' You can exit the UI with ctrl+q

' Destroy the uiElements:
delete(toggleButton)
delete(spinner)
'delete(fbGUI)

end

sub btnCallback (payload as uiElement ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim button as uiToggleButton ptr = cast(uiToggleButton ptr, payload)
		
		spinner->State = button->State
	end if
end sub     
