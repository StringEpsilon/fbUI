#INCLUDE once "fbgfx.bi"



#include once "../common/uiWindow.bas"
#include once "../elements/uiScrollbar.bas"

#include once "../elements/uiLabel.bas"

declare sub ElementCallback (payload as uiElement ptr)
declare sub ElementCallback2 (payload as uiElement ptr)
declare sub ElementCallback3 (payload as uiElement ptr)

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiScrollBar ptr vscrollbar = new uiScrollBar (  5, 16, 80,10,0,1)
dim as uiScrollBar ptr vscrollbar2 = new uiScrollBar( 20, 16, 80,20,0,5)
dim as uiScrollBar ptr vscrollbar3 = new uiScrollBar( 35, 86, 80,10,0,3, horizontal)
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


sub ElementCallback (payload as uiElement ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, element)
		label1->Text =  "Range 1: " & vscrollbar->Value
	end if
end sub
sub ElementCallback2 (payload as uiElement ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, element)
		label2->Text =  "Range 2: " & vscrollbar->Value
	end if
end sub     
sub ElementCallback3 (payload as uiElement ptr)
	if (payload <> 0 ) then
		' The payload should be always a pointer of the calling element
		dim element as uiElement ptr = cast(uiElement ptr, payload)
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, element)
		label3->Text =  "Range 3:  " & vscrollbar->Value
	end if
end sub     
