' uiWindow.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015


#include once "fbthread.bi"
#include once "uiEvents.bas"
#include once "uiElement.bas"
#include once "buffer.bas"



declarebuffer(IRenderable ptr, RenderableBuffer)

type uiWindow extends IDrawing
	private:
		static _instance as uiWindow ptr ' Its a singleton!
		_mutex as any ptr
		_children as uiElementList ptr
		_focus as uiElement ptr
		_lastClick as uiElement ptr	
		_RenderBuffer as RenderableBuffer ptr	
		
		declare sub DrawAll()	
		declare Constructor()
	public:
		'IDrawing:
		declare virtual sub DrawElement( element as IRenderable ptr)
		
		declare static function GetInstance() as uiWindow ptr
		declare static sub DestroyInstance()
		shutdown as bool = false
		'declare sub ShutDown() 
		
		
		declare sub CreateWindow(h as integer, w as integer)
		declare sub HandleEvent(event as uiEvent)
		declare sub Main()
		declare sub AddGadget( uiElement as uiElement ptr)
		
		declare Destructor()
end type

dim uiWindow._instance as uiWindow ptr = 0

sub uiWindow.DestroyInstance()
	if (uiWindow._instance <> 0) then
		delete uiWindow._instance
	end if
end sub

sub uiWindowEventDispatcher(event as uiEvent ptr)
	uiWindow.GetInstance()->HandleEvent(*event)
end sub

Constructor uiWindow()
	this._mutex = mutexcreate
	this._children = new uiElementList()
	this._RenderBuffer = new RenderableBuffer(20)
end Constructor

Destructor uiWindow()
	delete this._children
	delete this._RenderBuffer
	mutexdestroy(this._mutex)
end destructor

function uiWindow.GetInstance() as uiWindow ptr
	if ( uiWindow._instance = 0 ) then
		_instance = new uiWindow()
	end if
	return _instance
end function

sub uiWindow.CreateWindow(h as integer, w as integer)
	screenres h, w, 32
	COLOR 0,BackGroundColor
	cls
			
	if( screenptr = 0 ) then 
		end 2
	end if
	cls
end sub

sub uiWindow.Main()
	this.DrawAll()
	dim eventThread as any ptr 
	dim element as IRenderable ptr
	eventThread = threadcreate(@uiEventListener, @uiWindowEventDispatcher) 
	do
		if (this._RenderBuffer->count > 0) then
			while this._RenderBuffer->count > 0
				mutexlock(this._mutex)
				element = this._RenderBuffer->Pop()
				mutexunlock(this._mutex)
				mutexlock(GFXMUTEX)
				PUT (element->dimensions.x, element->dimensions.y), element->Render(), Alpha
				mutexunlock(GFXMUTEX)
			wend			
		end if
		screensync
		sleep 1,1
	loop until this.ShutDown
	ThreadWait(eventThread)
end sub

sub uiWindow.HandleEvent(event as uiEvent)
	if (screenptr = 0) then exit sub
	
	if ( event.eventType AND keyPress ) then
		if (event.keypress.keycode = 17 ) then
			mutexlock(this._mutex)
			this.shutdown = true
			mutexunlock(this._mutex)
			shutdownEventListener = true
			exit sub
		end if
		if (this._focus <> 0) then
			this._focus->OnKeypress(event.keypress)
		end if
	end if
		if (event.eventType AND mouseMove)  then
	'	shell "echo move"
		if ( this._lastClick <> 0 ) then
			this._lastClick->OnMouseMove(event.mouse)
		end if
	end if
	if ( event.eventType AND mouseClick ) then
		dim clickedGadget as bool = false
		dim child as uiElement ptr
		for i as integer = 0 to this._children->count -1
			child = this._children->item(i)
			
			with child->dimensions
				if ( event.mouse.x >= .x) AND ( event.mouse.x <= .x + .w ) and ( event.mouse.y >= .y) and ( event.mouse.y <= .y + .h) then
					if (this._focus <> child) then
						if this._focus <> 0 then 
							this._focus->OnFocus(false)
						end if
						mutexlock(this._mutex)
						this._focus = child
						mutexunlock(this._mutex)
						this._focus->OnFocus(true)					
					end if
					clickedGadget = true
					mutexlock(this._mutex)
					this._lastClick = child
					mutexunlock(this._mutex)
					child->OnClick(event.mouse)
				end if
			end with
		next
		if ( not(clickedGadget) AND this._focus <> 0 ) then
			this._focus->OnFocus(false)
			mutexlock(this._mutex)
			this._focus = 0
			_lastClick = 0
			mutexunlock(this._mutex)
		end if
	end if
end sub

sub uiWindow.AddGadget( element as uiElement ptr)
	if (element <> 0) then
		mutexlock(this._mutex)
		element->Parent = @this
		this._children->append(element)
		
		mutexunlock(this._mutex)
		this.drawelement(element)
	end if
end sub

sub uiWindow.DrawElement( renderable as IRenderable ptr)
	if ( renderable <> 0  ) then
		mutexlock(this._mutex)
		this._RenderBuffer->Push(renderable)
		mutexunlock(this._mutex)
	end if
end sub

sub uiWindow.DrawAll()
	
	dim as uiElement ptr child
	
	cls
	mutexlock(this._mutex)
	for i as integer = 0 to this._children->count -1
		child = this._children->item(i)
		mutexlock(GFXMUTEX)
		PUT (child->dimensions.x, child->dimensions.y), child->Render, Alpha
		mutexunlock(GFXMUTEX)
		
	next	
	mutexunlock(this._mutex)
end sub


sub UIDestructor() Destructor 101
	uiWindow.DestroyInstance()
end sub
