' uiEvents.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiEvent.bi"
#include once "fbthread.bi"
#INCLUDE once "fbgfx.bi"

#ifndef bool
enum bool
	false = 0
	true = not false
end enum
#endif

dim shared shutdownEventListener as bool = false

declare sub uiEventListener( callback as any ptr  )

sub uiEventListener( callback as any ptr  )
	dim as uiMouseEvent oldMouse 
	dim as uiEvent ptr newEvent
	dim event as fb.event
	'Thanks to Muttonhead, for the inspiration and the event-code prior to the screenevent version.
	do
		if ( SCREENEVENT(@event)  )THEN
			if (newEvent <> 0) then
				delete newEvent
			end if
			newEvent = new uiEvent()
			newEvent->Mouse = oldMouse
			
			select case event.type
				case FB.EVENT_KEY_PRESS
					if ( event.ascii > 0 ) then
						newEvent->keyPress.key = chr(event.ascii)
						newEvent->keyPress.keycode = event.ascii
					else
						newEvent->keyPress.Extended = true
						newEvent->keyPress.keycode = event.scancode
					end if
					newEvent->eventType += keyPress
				case FB.EVENT_MOUSE_MOVE
					newEvent->eventType += mouseMove
					with newEvent->Mouse
						.x = event.x
						.y = event.y
						.LMB = iif( .LMB >= hit,HOLD, 0 )
						.RMB = iif( .RMB >= hit,HOLD, 0 )
						.MMB = iif( .MMB >= hit,HOLD, 0 )
					end with
				case FB.EVENT_MOUSE_BUTTON_PRESS
					IF event.button = FB.BUTTON_LEFT  THEN
						newEvent->mouse.lmb = HIT
					ELSEIF event.button = FB.BUTTON_RIGHT THEN
						newEvent->mouse.RMB = HIT
					ELSEIF event.button = FB.BUTTON_MIDDLE THEN
						newEvent->mouse.MMB = HIT
					END IF
					newEvent->eventType = mouseClick
				case FB.EVENT_MOUSE_BUTTON_RELEASE
					IF event.button = FB.BUTTON_LEFT  THEN
						newEvent->mouse.lmb = released
					ELSEIF event.button = FB.BUTTON_RIGHT THEN
						newEvent->mouse.RMB = released
					ELSEIF event.button = FB.BUTTON_MIDDLE THEN
						newEvent->mouse.MMB = released
					END IF
					newEvent->eventType = mouseClick
			end select
			if ( newEvent->eventType <> 0  ) then
				threaddetach( threadcreate (cast(any ptr, callback), newEvent ))
			end if
			oldMouse = newEvent->Mouse
		end if
		sleep 1,1		
	loop until shutdownEventListener
end sub
