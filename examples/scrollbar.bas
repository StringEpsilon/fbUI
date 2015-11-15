#INCLUDE once "fbgfx.bi"

#include once "../common/window.bas"
#include once "../controls/scrollbar.bas"

#include once "../controls/label.bas"
using fbUI

declare sub ElementCallback (payload as uiControl ptr)
declare sub ElementCallback2 (payload as uiControl ptr)
declare sub ElementCallback3 (payload as uiControl ptr)

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


fbGUI->AddControl(vscrollbar)
fbGUI->AddControl(vscrollbar2)
fbGUI->AddControl(vscrollbar3)
fbGUI->AddControl(label1)
fbGUI->AddControl(label2)
fbGUI->AddControl(label3)
fbGUI->CreateWindow(100,200)

' Start the event loop and the main UI thread:
fbGUI->Main()


sub ElementCallback (payload as uiControl ptr)
	if (payload <> 0 ) then
		' Payload is a pointer to the calling element. Thus, casting should be safe:
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, payload)
		label1->Text =  "Range 1: " & vscrollbar->Value
	end if
end sub
sub ElementCallback2 (payload as uiControl ptr)
	if (payload <> 0 ) then
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, payload)
		label2->Text =  "Range 2: " & vscrollbar->Value
	end if
end sub     
sub ElementCallback3 (payload as uiControl ptr)
	if (payload <> 0 ) then
		dim vscrollbar as uiScrollBar ptr = cast(uiScrollBar ptr, payload)
		label3->Text =  "Range 3:  " & vscrollbar->Value
	end if
end sub     
