# fbUI

UI toolkit written in FreeBASIC.

### Design-Goals

I wanted to create an object oriented, multithreading capable UI-toolkit. All events will spawn a new thread of uiWindow.HandleEvent() (see todo.txt), while uiWindow.Main() handles drawing-requests from it's children. 

I doubt this project will ever reach the quality of existing toolkits, but I saw sGUI from MuttonHead and wanted to make something similar myself. 

So far, it's been a great learning experience for object oriented FreeBASIC and the use of Pango and Cairo. Note that I removed both Pango and Cairo since then.

### Thanks to:

Muttonhead, for the inspiration to do this and the code I borrowed in the early stages. Check out his project 'sGUI'!

DKL, for the fast work on the little problems I had with FreeBASIC, the RTlib and GFXlib.

And both the german and international irc-channels for FreeBASIC.
