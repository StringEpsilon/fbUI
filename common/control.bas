' uiElement.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include "fbthread.bi"
#include "uiEvent.bi"
#include "linkedlist.bas"
#include "controlBase.bas"

namespace fbUI

type Control extends IRenderable
	private:
		_parent as IDrawing	ptr
		_parentElement as control ptr
		_callback as sub(payload as any ptr)
		_layer as integer = normal
	protected:
		_mutex as any ptr
		_isActive as boolean = true
		_hasFocus as boolean = false
		_surface as fb.image ptr 
		_dimensions as uiDimensions
		_stateChanged as boolean = true
		
		declare constructor (x as integer, y as integer)
		declare virtual sub CreateBuffer()
		declare sub Redraw()
		declare sub DoCallback()
	public:
		' IRenderable:
		declare property Dimensions () as uiDimensions
		declare property Layer() as integer
		
		declare property Callback(cb as sub(payload as control ptr)) 
		declare property Parent(value as IDrawing ptr)
		declare property Parent(value as control ptr)
		
		declare destructor()
		declare constructor overload()
				
		' General events:
		declare virtual sub OnFocus(focus as boolean)
		' Keyboard events:
		declare virtual sub OnKeypress(keypress as uiKeyEvent)
		' Mouse events:
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnMouseMove(mouse as uiMouseEvent)
		declare virtual sub OnMouseOver(mouse as uiMouseEvent)
		declare virtual sub OnMouseLeave(mouse as uiMouseEvent)
		declare virtual sub OnMouseWheel(mouse as uiMouseEvent)
end type

declareList(Control ptr, controlList)

constructor Control()
	this._mutex = mutexCreate()
end constructor 

constructor Control(x as integer, y as integer)
	this.constructor()
	this._dimensions.x = x
	this._dimensions.y = y
end constructor 

Destructor Control()
	if (this._mutex <> 0 ) then
		mutexdestroy(this._mutex)
		this._mutex = 0
	end if
	imagedestroy( this._surface )
end destructor

property Control.Dimensions() as uiDimensions
	return this._dimensions
end property

property Control.Layer() as integer
	return this._layer
end property


property Control.Parent(value as IDrawing ptr)
	mutexlock(this._mutex)
	this._parent = value
	mutexunlock(this._mutex)
end property

property Control.Parent(value as Control ptr)
	mutexlock(this._mutex)
	this._parentElement = value
	mutexunlock(this._mutex)
end property

sub Control.Redraw()
	' We assume that if an element requested to be redrawn, it has changes.
	this._stateChanged = true
	if (this._parentElement <> 0) then
		this._parentElement->_stateChanged = true
		this._parentElement->Redraw()
	elseif ( this._parent ) then
		this._parent->DrawElement(@this)
	end if
end sub

sub Control.CreateBuffer()
	if ( this._surface <> 0) then
		imagedestroy( this._surface )
	end if
	
	this._surface = imagecreate(this._dimensions.w, this._dimensions.h, &h00ffffff, 32)
end sub

property Control.Callback(cb as sub(payload as Control ptr)) 
	mutexlock(this._mutex)
	if (cb <> 0) then
		this._callback = cast(sub(payload as any ptr),cb)
	end if
	mutexunlock(this._mutex)
end property

sub Control.DoCallback()
	if (this._callback <> 0) then
		threaddetach(threadcreate(this._callback, @this))
	end if
end sub

' The event handling methods:
sub Control.OnFocus(focus as boolean)
	mutexlock(this._mutex)
	this._hasFocus = focus
	mutexunlock(this._mutex)
	this.Redraw()
end sub

sub Control.OnKeypress(keypress as uiKeyEvent)
end sub

sub Control.OnClick(mouse as uiMouseEvent)
end sub

sub Control.OnMouseMove(mouse as uiMouseEvent)
end sub

sub Control.OnMouseOver(mouse as uiMouseEvent)
end sub

sub Control.OnMouseLeave(mouse as uiMouseEvent)
end sub

sub Control.OnMouseWheel(mouse as uiMouseEvent)
end sub

end namespace
