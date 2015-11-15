#include once "../common/window.bas"
#include once "../controls/toggleButton.bas"
#include once "../controls/spinner.bas"

using fbUI

declare sub btnCallback (payload as uiControl ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiToggleButton ptr toggleButton
dim shared as uiSpinner ptr spinner 

'Create the elements and add them to the UI:
spinner = new uiSpinner(88, 45, 24 )  
toggleButton = new uiToggleButton(50,5, "Disabled") 
toggleButton->callback = @btnCallback

fbGUI->AddControl(spinner)
fbGUI->AddControl(toggleButton)
fbGUI->CreateWindow(100,200)

threadcreate(@StartSpinnerAnimation,spinner)

fbGUI->Main()

delete(toggleButton)
delete(spinner)

end

sub btnCallback (payload as uiControl ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim button as uiToggleButton ptr = cast(uiToggleButton ptr, payload)
		
		spinner->State = button->Value
	end if
end sub     
