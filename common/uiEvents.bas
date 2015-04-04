' uiEvents.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiEvent.bi"
#include once "fbthread.bi"

#ifndef bool
enum bool
	false = 0
	true = not false
end enum
#endif

dim shared shutdownEventListener as bool = false

declare sub uiEventListener( callback as any ptr  )

sub uiEventListener( callback as any ptr  )
	dim key as string
	dim as uiEvent oldEvent

	'Thanks to Muttonhead. Most of this logic is copied from sGUI and refactored to my needs.
	do
		dim as uiEventType eventType = none
		dim as uiMouseEvent oldMouse 
		dim as uiEvent newEvent
			
		newEvent =  uiEvent
		oldMouse = oldEvent.Mouse
		
		
		with newEvent.mouse
			mutexlock(GFXMUTEX)
			getmouse(.x, .y, .wheel, .button)
			mutexunlock(GFXMUTEX)
			if .x < 0 or .y < 0 then 
				'wenn die Maus ausserhalb des Screens ist
				'falls eine Maustaste gedrückt aus den Screen geschoben wird, wird sie über
				'RELEASE in den RELEASED Zustand versetzt
				'"kostet" also 2 Loops als Ereignis im Eventloop
				.LMB = iif( .LMB > RELEASE, RELEASE,RELEASED )
				.MMB = iif( .MMB > RELEASE, RELEASE,RELEASED )
				.RMB = iif( .RMB > RELEASE, RELEASE,RELEASED )

				'.wheelvalue=oldwheelvalue
			else
				'LMB 4 Schaltzustände simulieren
				if ( .button and 1 ) then
					.LMB = iif( .LMB < HIT ,HIT, HOLD )
				else 
					.LMB = iif( .LMB > RELEASE, RELEASE, RELEASED )
				end if
				'MMB 4 Schaltzustände simulieren
				if ( .button and 4 ) then
				  .MMB=iif(.MMB<HIT,HIT,HOLD)
				else
				  .MMB=iif(.MMB>RELEASE,RELEASE,RELEASED)
				end if
				'RMB 4 Schaltzustände simulieren
				if ( .button and 2 ) then
				  .RMB=iif(.RMB<HIT,HIT,HOLD)
				else
				  .RMB=iif(.RMB>RELEASE,RELEASE,RELEASED)
				end if
			end if
		
			if ( .X <> oldMouse.X or .Y <> oldMouse.Y ) then 
				eventType = eventType OR mouseMove
			end if
			'Event LMB
			if ( .LMB <> oldMouse.LMB ) then 
				eventType = eventType OR mouseClick
			end if
			'Event MMB
			if ( .MMB <> oldMouse.MMB ) then 
				eventType = eventType OR mouseClick
			end if
			'Event RMB
			if ( .RMB <> oldMouse.RMB ) then
				eventType = eventType OR mouseClick
			end if
			
		end with
		
		with newEvent.keyPress
			mutexlock(GFXMUTEX)
			.key = inkey
			mutexunlock(GFXMUTEX)
			if ( .key <> "" ) then
				if ( len(.key) = 2 ) then
				  .extended=asc(left(.key,1))
				  .key=right(.key,1)
				end if
				.keycode = asc(.key)
				eventType = eventType OR keyPress
			end if
		end with
		
		if ( eventType <> none  ) then
			newEvent.eventType = eventType
			threaddetach( threadcreate (cast(any ptr, callback), @newEvent ))
			oldEvent = newEvent
		end if
		
		sleep 50,1
	loop until shutdownEventListener
end sub
