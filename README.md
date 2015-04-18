# fbUI

UI toolkit written in FreeBASIC with the help of Cairo.

### Design-Goals

I wanted to create an object oriented, multithreading capable UI-toolkit. All events will spawn a new thread of uiWindow.HandleEvent() (see todo.txt), while uiWindow.Main() handles drawing-requests from it's children. 

I doubt this project will ever reach the quality of existing toolkits, but I saw sGUI from MuttonHead and wanted to make something similar myself. So far, it's been a great learning experience and it helped me to find some bugs in the rtlib and gfxlib2 of FreeBasic (thanks DKL for fixing them so fast).

### Known issues

I have a problem with a severe lag in handling user input using ScreenEvent() on one of my Linux machines. I am not sure if the problem is in the gfxlib or if it's caused by my setup. If you have a similar experience, please let me know. 

### Dependencies

* FreeBASIC 1.03 or higher
* cairo
