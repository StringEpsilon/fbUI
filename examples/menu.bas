#INCLUDE once "fbgfx.bi"

#include once "../common/window.bas"
#include once "../controls/menu.bas"
using fbUI

dim as string list(2) 
for i as integer = 0 to 2
	list(i) = "Item "& i
next

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
dim as uiMenu ptr menu = new uiMenu( 16,200, list())

fbGUI->AddElement(menu)
fbGUI->CreateWindow(100,200)

fbGUI->Main()
