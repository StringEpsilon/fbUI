#INCLUDE once "fbgfx.bi"

#include once "../common/uiWindow.bas"
#include once "../elements/uiVScrollbar.bas"
#include once "../elements/uiHScrollbar.bas"
#include once "../elements/uiLabel.bas"

declare sub ElementCallback (payload as any ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiVScrollbar ptr vscrollbar = new uiVScrollbar( 5, 15, 80,10,1)
dim as uiHScrollbar ptr hscrollbar = new uiHScrollbar( 5, 5, 180,10,1)
dim shared as uiLabel ptr labelV, labelH 

labelV = new uiLabel(50, 16, "Vertical: 0",12)
labelH = new uiLabel(50, 32, "Horizontal: 0",14)

vscrollbar->callback = @ElementCallback
hscrollbar->callback = @ElementCallback

fbGUI->AddElement(vscrollbar)
fbGUI->AddElement(hscrollbar)
fbGUI->AddElement(labelV)
fbGUI->AddElement(labelH)
fbGUI->CreateWindow(200,100)

' Start the event loop and the main UI thread:
fbGUI->Main()
' You can exit the UI with ctrl+q

' Destroy the uiEl
delete(vscrollbar)
delete(hscrollbar)
delete(labelV)
delete(labelH)

sub ElementCallback (payload as any ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		' Who needs seperate callbacks anyway?
		if (*element is uiVScrollbar) then
			dim vscrollbar as uiVScrollbar ptr = cast(uiVScrollbar ptr, element)
			labelV->Text =  "Vertical: " & vscrollbar->Value
		else
			dim hscrollbar as uiHScrollbar ptr = cast(uiHScrollbar ptr, element)
			labelH->Text =  "Horizontal: " & hscrollbar->Value
		end if
	end if
end sub     
