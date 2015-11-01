' uiWindow.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

SCREENRES 1, 1,32,,-1

#include once "fbthread.bi"
#include once "uiElement.bas"
#include once "buffer.bas"
#include once "uiEvents.bas"

declarebuffer(IRenderable ptr, RenderableBuffer,true)

type uiWindow extends IDrawing
	private:
		static _instance as uiWindow ptr
		_mutex as any ptr
		_children as uiElementList ptr
		_focus as uiElement ptr
		_mouseOver as uiElement ptr
		_RenderBuffer as RenderableBuffer ptr
		_title as string
		
		declare Constructor()
		declare Destructor()
		declare sub DrawAll()	
		declare function GetElementAt(x as integer, y as integer) as uiElement ptr
	public:
		declare property Title() as string
		declare property Title(newTitle as string)
	
		'IDrawing:
		declare virtual sub DrawElement( element as IRenderable ptr)
		
		declare static function GetInstance() as uiWindow ptr
		declare static sub DestroyInstance()
		
		declare sub CreateWindow(h as integer, w as integer, newTitle as string = "")
		declare sub HandleEvent(event as uiEvent)
		declare sub Main()
		declare sub AddElement( uiElement as uiElement ptr)
		declare sub RemoveElement( uiElement as uiElement ptr)
		
		shutdown as boolean = false
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


property uiWindow.Title() as string
	return this._title
end property

property uiWindow.Title(newTitle as string)
	mutexlock(this._mutex)
	this._title = newTitle
	WindowTitle(this._title)
	mutexunlock(this._mutex)
end property

sub uiWindow.DrawAll()
	dim as uiElement ptr child
	mutexlock(this._mutex)
	for i as integer = 0 to this._children->count -1
		child = this._children->item(i)
		
		screenlock
		
		put (child->dimensions.x, child->dimensions.y), child->Render(), ALPHA
		
		screenunlock
	next
	mutexunlock(this._mutex)
end sub

function uiWindow.GetElementAt(x as integer, y as integer) as uiElement ptr
	dim result as uiElement ptr = 0
	dim child as uiElement ptr
	
	for i as integer = 0 to this._children->count -1
		child = this._children->item(i)
		if child->Layer = background then 
			continue for
		end if
		with child->dimensions
			if (( x >= .x) AND ( x <= .x + .w ) and ( y >= .y) and (y <= .y + .h)) then
				if (result = 0 OrElse result->layer < child->layer) then
					result = child
				end if
			end if
		end with
	next
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

sub uiWindow.CreateWindow(h as integer, w as integer, newTitle as string = "")
	mutexlock(this._mutex)
	this._title = newTitle
	screenres w, h, 32
	WINDOWTITLE(this._title)
	COLOR 0,BackGroundColor
	cls
		
	mutexunlock(this._mutex)
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
		this._RenderBuffer->Push(renderable)
	end if
end sub


function uiWindow.GetInstance() as uiWindow ptr
	if ( uiWindow._instance = 0 ) then
		_instance = new uiWindow()
	end if
	return _instance
end function

sub uiWindow.HandleEvent(event as uiEvent)
	select case as const event.eventType 
		case uiShutdown
			mutexlock(this._mutex)
			this.shutdown = true
			mutexunlock(this._mutex)
			shutdownEventListener = true
			exit sub
		case uikeyPress
			if (this._focus <> 0) then
				this._focus->OnKeypress(event.keypress)
			end if
		case uiMouseClick
			dim uiClickedElement as uiElement ptr = this.GetElementAt(event.mouse.x, event.mouse.y)
			' Always forward the release event to the element last clicked.
			if ( event.mouse.last = uiReleased and this._focus <> 0 ) then
				this._focus->OnClick(event.mouse)
			else
				if (uiClickedElement <> 0) then
					if ( this._focus <> uiClickedElement ) then
						if (this._focus <> 0 ) then
							this._focus->OnFocus(false)
						end if
						mutexlock(this._mutex)
						this._focus = uiClickedElement
						mutexunlock(this._mutex)
						this._focus->OnFocus(true)
					end if
					uiClickedElement->OnClick(event.Mouse)
				elseif (this._focus <> 0) then
					this._focus->OnFocus(false)
					mutexlock(this._mutex)
					this._focus = 0
					mutexunlock(this._mutex)
				end if
			end if
		case uiMouseMove
			if ( this._focus <> 0 ) then
				this._focus->OnMouseMove(event.mouse)
			end if
			
			dim as uielement ptr mouseLeave, mouseEnter
			dim uiClickedElement as uiElement ptr = this.GetElementAt(event.mouse.x, event.mouse.y)
			
			mutexlock(this._mutex)
			if ( this._mouseOver <> uiClickedElement) then
				if (this._mouseOver <> 0) then
					mouseLeave = this._mouseOver
				end if
				this._mouseOver = uiClickedElement
				if (this._mouseOver <> 0) then
					mouseEnter = this._mouseOver
				end if
			end if
			mutexunlock(this._mutex)
			
			if (mouseLeave <> 0) then mouseLeave->OnMouseLeave(event.mouse)
			if (mouseEnter <> 0) then mouseEnter->OnMouseOver(event.mouse)
		case uiMouseWheel
			if (this._focus <> 0) then
				this._focus->OnMouseWheel(event.mouse)
			elseif (this._mouseOver <> 0) then
				this._mouseOver->OnMouseWheel(event.mouse)
			end if
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
				element = this._RenderBuffer->Pop()
				with element->dimensions
					screenlock
					put (element->dimensions.x, element->dimensions.y), element->Render(), ALPHA
					screenunlock
				end with
			wend			
		end if
		screensync
	loop until this.ShutDown
	ThreadWait(eventThread)
end sub

