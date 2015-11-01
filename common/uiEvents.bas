' uiEvents.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiEvent.bi"
#include once "fbthread.bi"
#INCLUDE once "fbgfx.bi"

dim shared shutdownEventListener as boolean = false

declare sub uiEventListener( callback as any ptr  )

sub uiEventListener( callback as any ptr  )
	dim as uiMouseEvent oldMouse 
	dim as uiEvent ptr newEvent
	dim event as fb.event
	dim as double beforeEvent
	dim wheelValue as integer
	'Thanks to Muttonhead, for the inspiration and the event-code prior to the screenevent version.
	do
		if ( SCREENEVENT(@event)  )THEN
			if (newEvent <> 0) then
				delete newEvent
			end if
			newEvent = new uiEvent()
			newEvent->Mouse = oldMouse
			
			select case as const event.type
				case FB.EVENT_KEY_PRESS
					if ( event.ascii > 0 ) then
						newEvent->keyPress.key = chr(event.ascii)
						newEvent->keyPress.keycode = event.ascii
					else
						newEvent->keyPress.Extended = true
						newEvent->keyPress.keycode = event.scancode
					end if
					newEvent->eventType += uikeyPress
				case FB.EVENT_MOUSE_MOVE
					newEvent->eventType += uimouseMove
					with newEvent->Mouse
						.x = event.x
						.y = event.y
						.LMB = iif( .LMB >= uiClick,uiHold, 0 )
						.RMB = iif( .RMB >= uiClick,uiHold, 0 )
						.MMB = iif( .MMB >= uiClick,uiHold, 0 )
						.last = iif( .last >= uiClick,uiHold, 0 )
					end with
				case FB.EVENT_MOUSE_BUTTON_PRESS
					IF event.button = FB.BUTTON_LEFT  THEN
						newEvent->mouse.lmb = uiClick
					ELSEIF event.button = FB.BUTTON_RIGHT THEN
						newEvent->mouse.RMB = uiClick
					ELSEIF event.button = FB.BUTTON_MIDDLE THEN
						newEvent->mouse.MMB = uiClick
					END IF
					newEvent->mouse.last = uiClick
					newEvent->eventType = uiMouseClick
				case FB.EVENT_MOUSE_BUTTON_RELEASE
					IF event.button = FB.BUTTON_LEFT  THEN
						newEvent->mouse.lmb = uiReleased
					ELSEIF event.button = FB.BUTTON_RIGHT THEN
						newEvent->mouse.RMB = uiReleased
					ELSEIF event.button = FB.BUTTON_MIDDLE THEN
						newEvent->mouse.MMB = uiReleased
					END IF
					newEvent->mouse.last = uiReleased
					newEvent->eventType = uiMouseClick
				case FB.EVENT_MOUSE_WHEEL
					newEvent->mouse.Wheel = wheelValue - event.z
					wheelValue = event.z
					newEvent->eventType = uiMouseWheel
				case FB.EVENT_WINDOW_CLOSE
					newEvent->EventType = uiShutDown
			end select
			if ( newEvent->eventType <> 0  ) then
				
				threaddetach( threadcreate (cast(any ptr, callback), newEvent ))
			end if
			oldMouse = newEvent->Mouse
		end if
		sleep 1
	loop until shutdownEventListener
	delete newEvent
end sub
