' control.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "fbthread.bi"
#include once "base/linkedlist.bas"
#include once "uiEvent.bi"
#include once "base/IDrawing.bi"
#include once "base/colors.bi"
#include once "fbJson.bi"


type uiControl extends IRenderable
	private:
		_parent as IDrawing	ptr
		_parentElement as uiControl ptr
		_callback as sub(payload as any ptr)
		_layer as integer = normal
	protected:
		_id as string
		_mutex as any ptr
		_isActive as boolean = true
		_hasFocus as boolean = false
		_surface as fb.image ptr 
		_dimensions as uiDimensions
		_stateChanged as boolean = true
		
		declare constructor (x as integer, y as integer)
		declare constructor (byref json as jsonItem)
		declare virtual sub CreateBuffer()
		declare sub Redraw()
		declare sub DoCallback()
	public:
		' IRenderable:
		declare property Dimensions () byref as uiDimensions
		declare property Layer() byref as integer
				
		declare property Callback(cb as sub(payload as uiControl ptr)) 
		declare property Parent(value as IDrawing ptr)
		declare property Parent(value as uiControl ptr)
		
		declare property ID(value as string)
		declare property ID() as string
		
		declare virtual destructor()
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

declareList(uiControl, controlList)

constructor uiControl()
	this._mutex = mutexCreate()
end constructor 

constructor uiControl(byref json as jsonItem)
	this._mutex = mutexCreate()
	if ( json["dimensions"].count >= 0 ) then
		this._dimensions.h = cint(json["dimensions"]["h"].value)
		this._dimensions.w = cint(json["dimensions"]["w"].value)
		this._dimensions.x = cint(json["dimensions"]["x"].value)
		this._dimensions.y = cint(json["dimensions"]["y"].value)
	end if
	
	this._id = json["id"].value
end constructor

constructor uiControl(x as integer, y as integer)
	this.constructor()
	this._dimensions.x = x
	this._dimensions.y = y
end constructor 

Destructor uiControl()
	if (this._mutex <> 0 ) then
		mutexdestroy(this._mutex)
		this._mutex = 0
	end if
	imagedestroy( this._surface )
end destructor

property uiControl.Dimensions() byref as uiDimensions
	return this._dimensions
end property

property uiControl.Layer() byref as integer
	return this._layer
end property


property uiControl.Parent(value as IDrawing ptr)
	mutexlock(this._mutex)
	this._parent = value
	mutexunlock(this._mutex)
end property

property uiControl.Parent(value as uiControl ptr)
	mutexlock(this._mutex)
	this._parentElement = value
	mutexunlock(this._mutex)
end property

property uiControl.ID(value as string)
	mutexlock(this._mutex)
	this._id = value
	mutexunlock(this._mutex)
end property

property uiControl.ID() as string
	return this._id
end property

sub uiControl.Redraw()
	' We assume that if an element requested to be redrawn, it has changes.
	'mutexlock(this._mutex)
	this._stateChanged = true
	if (this._parentElement <> 0) then
		this._parentElement->_stateChanged = true
	'	mutexunlock(this._mutex)
		this._parentElement->Redraw()
	elseif ( this._parent ) then
	'	mutexunlock(this._mutex)
		this._parent->DrawElement(@this)
	end if
	'mutexunlock(this._mutex)
end sub

sub uiControl.CreateBuffer()
	if ( this._surface <> 0) then
		imagedestroy( this._surface )
	end if
	this._surface = imagecreate(this._dimensions.w, this._dimensions.h+1, &h00ffffff, 32)
end sub

property uiControl.Callback(cb as sub(payload as uiControl ptr)) 
	mutexlock(this._mutex)
	if (cb <> 0) then
		this._callback = cast(sub(payload as any ptr),cb)
	end if
	mutexunlock(this._mutex)
end property

sub uiControl.DoCallback()
	if (this._callback <> 0) then
		threaddetach(threadcreate(this._callback, @this))
	end if
end sub

' The event handling methods:
sub uiControl.OnFocus(focus as boolean)
	mutexlock(this._mutex)
	this._hasFocus = focus
	mutexunlock(this._mutex)
	this.Redraw()
end sub

sub uiControl.OnKeypress(keypress as uiKeyEvent)
end sub

sub uiControl.OnClick(mouse as uiMouseEvent)
end sub

sub uiControl.OnMouseMove(mouse as uiMouseEvent)
end sub

sub uiControl.OnMouseOver(mouse as uiMouseEvent)
end sub

sub uiControl.OnMouseLeave(mouse as uiMouseEvent)
end sub

sub uiControl.OnMouseWheel(mouse as uiMouseEvent)
end sub
