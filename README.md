# fbUI

UI toolkit written in FreeBASIC with the help of Cairo.

### Design-Goals

I wanted to create an object oriented, multithreading capable UI-toolkit. All events will spawn a new thread of uiWindow.HandleEvent() (see todo.txt), while uiWindow.Main() handles drawing-requests from it's children. 

I doubt this project will ever reach the quality of existing toolkits, but I saw sGUI from MuttonHead and wanted to make something similar myself. So far, it's been a great learning experience and it helped me to find some bugs in the rtlib and gfxlib2 of FreeBasic (thanks DKL for fixing them so fast).

### Dependencies

* FreeBASIC 1.03 or higher
* cairo
