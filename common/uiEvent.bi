' uiEvent.bi - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#ifndef bool
enum bool
	false = 0
	true = not false
end enum
#endif

enum uiEventType
	none = 			&b00000000
	uiKeyPress = 	&b00000001
	uiMouseuiClick = 	&b00000010
	uiDoubleuiClick = &b00000100
	uiMouseMove = 	&b00001000
	uiMouseWheel =  &b00010000
	uiShutDown =	&b10000000
end enum

enum uiMouseButtonState
	uiReleased = 0
	uiClick = 1
	uiHold = 2
end enum

type uiMouseEvent
	x as integer
	y as integer
	
	lmb as uiMouseButtonState = -1
	mmb as uiMouseButtonState = -1
	rmb as uiMouseButtonState = -1
	
	wheel as integer
end type

type uiKeyEvent
	extended as bool = false
	
	keycode as integer = -1
	key as string
	
end type

type uiEvent
	eventType as uiEventType  = none
	mouse as uiMouseEvent
	keypress as uiKeyEvent
end type






