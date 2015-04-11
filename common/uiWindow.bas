' uiWindow.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015
#include once "fbthread.bi"
#include once "uiEvents.bas"
#include once "uiElement.bas"
#include once "buffer.bas"

SCREENRES 1,1, 32,, FB.GFX_NULL

declarebuffer(IRenderable ptr, RenderableBuffer)

type uiWindow extends IDrawing
	private:
		static _instance as uiWindow ptr
		_mutex as any ptr
		_children as uiElementList ptr
		_focus as uiElement ptr
		_RenderBuffer as RenderableBuffer ptr
		_mouseOver as uiElement ptr 'For tracking mouseLeave
		
		declare Constructor()
		declare Destructor()
		declare sub DrawAll()	
		declare function GetElementAt(x as integer, y as integer) as uiElement ptr
	public:
		'IDrawing:
		declare virtual sub DrawElement( element as IRenderable ptr)
		
		declare static function GetInstance() as uiWindow ptr
		declare static sub DestroyInstance()
		declare sub CreateWindow(h as integer, w as integer)
		declare sub HandleEvent(event as uiEvent)
		declare sub Main()
		declare sub AddElement( uiElement as uiElement ptr)
		declare sub RemoveElement( uiElement as uiElement ptr)
				
		shutdown as bool = false
end type

dim uiWindow._instance as uiWindow ptr = 0

sub UIDestructor() Destructor 101
	uiWindow.DestroyInstance()
end sub

sub uiWindowEventDispatcher(event as uiEvent ptr)
	uiWindow.GetInstance()->HandleEvent(*event)
end sub

' Dummy parameter because of threadcreate. 
sub uiWindowStart(dummyParameter as uinteger)
	uiWindow.GetInstance()->Main()
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

sub uiWindow.DrawAll()
	dim as uiElement ptr child
	COLOR 0,BackGroundColor
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

function uiWindow.GetElementAt(x as integer, y as integer) as uiElement ptr
	dim result as uiElement ptr = 0
	dim i as integer = 0
	dim child as uiElement ptr
	
	while i < this._children->count and result = 0
		child = this._children->item(i)
		with child->dimensions
			if (( x >= .x) AND ( x <= .x + .w ) and ( y >= .y) and (y <= .y + .h)) then
				result = child
				
			end if
		end with
		i+=1
	wend
	return result
end function

sub uiWindow.AddElement( element as uiElement ptr)
	if (element <> 0) then
		mutexlock(this._mutex)
		element->Parent = @this
		this._children->append(element)
		mutexunlock(this._mutex)
		this.drawelement(element)
	end if
end sub

sub uiWindow.CreateWindow(h as integer, w as integer)
	screenres h, w, 32
	COLOR 0,BackGroundColor
	cls
			
	if( screenptr = 0 ) then 
		end 2
	end if
	cls
end sub

sub uiWindow.DestroyInstance()
	if (uiWindow._instance <> 0) then
		delete uiWindow._instance
	end if
end sub

sub uiWindow.RemoveElement(element as uiElement ptr)
	if (element <> 0) then
		dim i as integer = 0
		while i < this._children->count
			if ( this._children->item(i) = element) then
				mutexlock(this._mutex)
				this._children->remove(i)
				element->Parent = cast(IDrawing ptr,0)
				mutexunlock(this._mutex)
				exit while
			end if
			i += 1
		wend
		
		if (this._focus = element) then 
			mutexlock(this._mutex)
			this._focus = 0
			mutexunlock(this._mutex)
		end if
		this.DrawAll()
	end if
end sub

sub uiWindow.DrawElement( renderable as IRenderable ptr)
	if ( renderable <> 0  ) then
		mutexlock(this._mutex)
		this._RenderBuffer->Push(renderable)
		mutexunlock(this._mutex)
	end if
end sub


function uiWindow.GetInstance() as uiWindow ptr
	if ( uiWindow._instance = 0 ) then
		_instance = new uiWindow()
	end if
	return _instance
end function

sub uiWindow.HandleEvent(event as uiEvent)
	if (screenptr = 0) then exit sub
	select case as const event.eventType 
		case uiShutdown
			mutexlock(this._mutex)
			this.shutdown = true
			mutexunlock(this._mutex)
			shutdownEventListener = true
			exit sub
		case keyPress
			if (this._focus <> 0) then
				this._focus->OnKeypress(event.keypress)
			end if
		case mouseClick
			dim clickedElement as uiElement ptr = this.GetElementAt(event.mouse.x, event.mouse.y)
			if (clickedElement <> 0) then
				if (this._focus <> clickedElement) then
					if (this._focus <> 0 ) then
						this._focus->OnFocus(false)
					end if
					mutexlock(this._mutex)
					this._focus = clickedElement
					mutexunlock(this._mutex)
					this._focus->OnFocus(true)
				end if
				clickedElement->OnClick(event.Mouse)
			elseif (this._focus <> 0) then
				this._focus->OnFocus(false)
				mutexlock(this._mutex)
				this._focus = 0
				mutexunlock(this._mutex)
			end if
		case mouseMove
			if ( this._focus <> 0 ) then
				this._focus->OnMouseMove(event.mouse)
			end if
			
			dim as uielement ptr mouseLeave, mouseEnter
			dim clickedElement as uiElement ptr = this.GetElementAt(event.mouse.x, event.mouse.y)
			
			mutexlock(this._mutex)
			if ( this._mouseOver <> clickedElement) then
				if (this._mouseOver <> 0) then
					mouseLeave = this._mouseOver
				end if
				this._mouseOver = clickedElement
				if (this._mouseOver <> 0) then
					mouseEnter = this._mouseOver
				end if
			end if
			mutexunlock(this._mutex)
			
			if (mouseLeave <> 0) then mouseLeave->OnMouseLeave(event.mouse)
			if (mouseEnter <> 0) then mouseEnter->OnMouseOver(event.mouse)
	end select
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
				with element->dimensions
					LINE (.x, .y)-(.x+.w, .y+.h),BackgroundColor, BF
					PUT (.x, .y), element->Render(), alpha
				end with
				mutexunlock(GFXMUTEX)
			wend			
		end if
		screensync
		sleep 1,1
	loop until this.ShutDown
	ThreadWait(eventThread)
end sub

