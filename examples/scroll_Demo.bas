#INCLUDE once "fbgfx.bi"

#include once "../common/uiWindow.bas"
#include once "../elements/uiVScrollbar.bas"
#include once "../elements/uiHScrollbar.bas"
#include once "../elements/uiLabel.bas"

declare sub ElementCallback (payload as any ptr)
declare sub ElementCallback2 (payload as any ptr)
declare sub ElementCallback3 (payload as any ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiVScrollbar ptr vscrollbar = new uiVScrollbar( 5, 16, 80,10,1)
dim as uiVScrollbar ptr vscrollbar2 = new uiVScrollbar( 20, 16, 80,10,1,2)
dim as uiVScrollbar ptr vscrollbar3 = new uiVScrollbar( 35, 16, 80,10,1,3)
dim shared as uiLabel ptr label1, label2, label3

label1 = new uiLabel(60, 16, "Range 1: 0",12)
label2 = new uiLabel(60, 32, "Range 2: 0",14)
label3 = new uiLabel(60, 48, "Range 3: 0",14)

vscrollbar->callback = @ElementCallback
vscrollbar2->callback = @ElementCallback2
vscrollbar3->callback = @ElementCallback3


fbGUI->AddElement(vscrollbar)
fbGUI->AddElement(vscrollbar2)
fbGUI->AddElement(vscrollbar3)
fbGUI->AddElement(label1)
fbGUI->AddElement(label2)
fbGUI->AddElement(label3)
fbGUI->CreateWindow(100,200)

' Start the event loop and the main UI thread:
fbGUI->Main()


sub ElementCallback (payload as any ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		dim vscrollbar as uiVScrollbar ptr = cast(uiVScrollbar ptr, element)
		label1->Text =  "Vertical: " & vscrollbar->Value
	end if
end sub
sub ElementCallback2 (payload as any ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		dim vscrollbar as uiVScrollbar ptr = cast(uiVScrollbar ptr, element)
		label2->Text =  "Vertical: " & vscrollbar->Value
	end if
end sub     
sub ElementCallback3 (payload as any ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		dim vscrollbar as uiVScrollbar ptr = cast(uiVScrollbar ptr, element)
		label3->Text =  "Vertical: " & vscrollbar->Value
	end if
end sub     
