#INCLUDE once "fbgfx.bi"

#include once "../common/uiWindow.bas"
#include once "../elements/uiListbox.bas"

dim as string list(10) 
for i as integer = 0 to 10
	list(i) = "Item "& i
next

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiListbox ptr listbox = new uiListbox( 5, 5, 80,150, list())
dim shared as uiLabel ptr labelV, labelH 

fbGUI->AddElement(listbox)
fbGUI->CreateWindow(100,200)

fbGUI->Main()
delete(listbox)
