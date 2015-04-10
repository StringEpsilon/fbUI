' uiEvent.bi - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

dim shared GFXMUTEX as any ptr 
GFXMUTEX = mutexcreate

#ifndef bool
enum bool
	false = 0
	true = not false
end enum
#endif

enum uiEventType
	none = 			&b00000000
	mouseClick = 	&b00000001
	mouseMove = 	&b00000010
	keyPress = 		&b00000100
	shutdownUI =	&b10000000
end enum

enum uiMouseButtoSstate
	released = 0
	hit = 1
	hold = 2
end enum

type uiMouseEvent
	x as integer
	y as integer
	
	lmb as uiMouseButtoSstate = -1
	mmb as uiMouseButtoSstate = -1
	rmb as uiMouseButtoSstate = -1
	
	wheel as integer
	button as integer
	
	doubleclick as bool = false
end type

type uiKeyEvent
	shift as bool = false
	ctrl as bool = false
	mod4 as bool = false
	alt as bool = false
	extended as bool = false
	
	keycode as integer = -1
	key as string
	
end type

type uiEvent
	eventType as uiEventType  = none
	mouse as uiMouseEvent
	keypress as uiKeyEvent
end type






