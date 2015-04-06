# fbUI

UI toolkit written in FreeBASIC with the help of Cairo.

More a proof of concept than anything useful right now. Parts of the code are still a mess and the multithreading is poorly optimized. Unfortunately, I can't get rid of the GFXMUTEX completly, due to some internal mutexing issues in the GFXlib. If you insist that it's threadsafe, remove the locks and spam click and move events ;) I don't have enough information to file a bug report on it.

Refer to the todo.txt for future plans.
