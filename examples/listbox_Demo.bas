#INCLUDE once "fbgfx.bi"

#include once "../common/uiWindow.bas"
#include once "../elements/uiListbox.bas"

declare sub ElementCallback (payload as any ptr)

dim as string list(10) 
for i as integer = 0 to 5
	list(i) = "Item #"&i
	shell "echo Added item "& i
next

dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
' (x as integer, y as integer,h as integer, w as integer, list() as string)
dim as uiListbox ptr listbox = new uiListbox( 5, 5, 80,150, list())
dim shared as uiLabel ptr labelV, labelH 




fbGUI->AddElement(listbox)
fbGUI->CreateWindow(200,100)

' Start the event loop and the main UI thread:
fbGUI->Main()
' You can exit the UI with ctrl+q

' Destroy the uiEl
delete(listbox)

' fbc "listbox_Demo.bas" -arch x86_64 (im Verzeichnis: /home/marc/Dateien/fbUI/fbUI/examples)
