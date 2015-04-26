' uiElement.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "fbthread.bi"
#include once "uiEvent.bi"
#include once "linkedlist.bas"
#include once "cairoHelper.bas"
#include once "uiBaseElement.bas"

type uiElement extends IRenderable
	private:
		_parent as IDrawing	ptr
		_parentElement as uiElement ptr
		_callback as sub(payload as any ptr)
		_layer as integer = normal
	protected:
		_mutex as any ptr
		_isActive as bool = true
		_hasFocus as bool = false
		_surface as cairo_surface_t ptr 
		_cairo as cairo_t ptr
		_dimensions as uiDimensions
		
		declare constructor (x as integer, y as integer)
		declare virtual sub CreateBuffer()
		declare sub Redraw()
		declare sub DoCallback()
	public:
		' IRenderable:
		declare property Dimensions () as uiDimensions
		declare property Layer() as integer
		
		declare property Callback(cb as sub(payload as uiElement ptr)) 
		declare property Parent(value as IDrawing ptr)
		declare property Parent(value as uiElement ptr)
		
		declare destructor()
		declare constructor overload()
				
		' General events:
		declare virtual sub OnFocus(focus as bool)
		' Keyboard events:
		declare virtual sub OnKeypress(keypress as uiKeyEvent)
		' Mouse events:
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnMouseMove(mouse as uiMouseEvent)
		declare virtual sub OnMouseOver(mouse as uiMouseEvent)
		declare virtual sub OnMouseLeave(mouse as uiMouseEvent)
		declare virtual sub OnMouseWheel(mouse as uiMouseEvent)
end type

declareList(uiElement ptr, uiElementList)

constructor uiElement()
	this._mutex = mutexCreate()
end constructor 

constructor uiElement(x as integer, y as integer)
	this.constructor()
	this._dimensions.x = x
	this._dimensions.y = y
end constructor 

Destructor uiElement()
	if (this._mutex <> 0 ) then
		mutexdestroy(this._mutex)
		this._mutex = 0
	end if
	cairo_surface_destroy (this._surface)
	cairo_destroy(this._cairo)
end destructor

property uiElement.Dimensions() as uiDimensions
	return this._dimensions
end property

property uiElement.Layer() as integer
	return this._layer
end property


property uiElement.Parent(value as IDrawing ptr)
	mutexlock(this._mutex)
	this._parent = value
	mutexunlock(this._mutex)
end property

property uiElement.Parent(value as uiElement ptr)
	mutexlock(this._mutex)
	this._parentElement = value
	mutexunlock(this._mutex)
end property

sub uiElement.Redraw()
	if (this._parentElement <> 0) then
		this._parentElement->Redraw()
	elseif ( this._parent ) then
		this._parent->DrawElement(@this)		
	end if
end sub

sub uiElement.CreateBuffer()
	if ( this._cairo <> 0) then
		cairo_destroy(this._cairo)
		cairo_surface_destroy(this._surface)
	end if

	this._surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, this._dimensions.w, this._dimensions.h)
	this._cairo = cairo_create(this._surface)
end sub

property uiElement.Callback(cb as sub(payload as uiElement ptr)) 
	mutexlock(this._mutex)
	if (cb <> 0) then
		this._callback = cast(sub(payload as any ptr),cb)
	end if
	mutexunlock(this._mutex)
end property

sub uiElement.DoCallback()
	if (this._callback <> 0) then
		threaddetach(threadcreate(this._callback, @this))
	end if
end sub

' The event handling methods:
sub UiElement.OnFocus(focus as bool)
	mutexlock(this._mutex)
	this._hasFocus = focus
	mutexunlock(this._mutex)
	this.Redraw()
end sub

sub UiElement.OnKeypress(keypress as uiKeyEvent)
end sub

sub UiElement.OnClick(mouse as uiMouseEvent)
end sub

sub UiElement.OnMouseMove(mouse as uiMouseEvent)
end sub

sub UiElement.OnMouseOver(mouse as uiMouseEvent)
end sub

sub UiElement.OnMouseLeave(mouse as uiMouseEvent)
end sub

sub UiElement.OnMouseWheel(mouse as uiMouseEvent)
end sub

