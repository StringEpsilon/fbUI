' Control.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/controlContainer.bas"
#include once "label.bas"
#include once "scrollbar.bas"

namespace fbUI

type uiListBox extends uiControlContainer
	private:
		_selection as uiLabel ptr
		_scrollbar as uiScrollbar ptr
		declare function GetElementAt(x as integer, y as integer) as uiControl ptr
	public:
		declare function Render() as fb.image ptr
		Callback as sub(payload as any ptr)
		
		declare destructor()
		declare constructor (x as integer, y as integer,h as integer, w as integer, list() as string)
				
		declare sub OnClick(mouse as uiMouseEvent)
		declare sub OnKeypress(keypress as uiKeyEvent)
		declare sub OnMouseMove(mouse as uiMouseEvent)
		declare sub OnMouseWheel(mouse as uiMouseEvent)
end type

constructor uiListBox(x as integer, y as integer,h as integer, w as integer, list() as string)
	base(x,y)
	this._dimensions.h = h
	this._dimensions.w = w
	
	this._scrollbar = new uiScrollbar(w-11, 2, h-4,ubound(list)-h/16+1, lbound(list))
	this._scrollbar->Parent = @this
	this._children->Append(this._scrollbar)
	
	dim child as uiLabel ptr 
	for i as integer = 0 to ubound(list)
		child = new uiLabel(2, i*16+2, list(i))
		child->Parent = @this
		this._children->Append(child)
	next
		
	this.CreateBuffer()
end constructor 

Destructor uiListBox()
	base.Destructor()
	delete this._children
end destructor

function uiListBox.GetElementAt(x as integer, y as integer) as uiControl ptr
	dim result as uiControl ptr = 0
	dim i as integer = 0
	dim child as uiControl ptr
	dim as integer offset = 16 * this._scrollbar->Value
	
	while i < this._children->count and result = 0
		child = this._children->item(i)
		with child->dimensions
			if ( *child is uiLabel ) then
				if (( x >= .x) AND ( x <= .x + .w ) and ( y >= .y - offset) and (y <= .y - offset + .h)) then
					result = child
				end if
			else
				if (( x >= .x) AND ( x <= .x + .w ) and ( y >= .y - offset) and (y <= .y - offset + .h)) then
					result = child
				end if
			end if
		end with
		i+=1
	wend
	return result
end function


sub uiListBox.OnClick(mouse as uiMouseEvent)
	mouse.x = mouse.x - this.dimensions.x
	mouse.y = mouse.y - this.dimensions.y
	
	dim uiClickedElement as uiControl ptr = this.GetElementAt(mouse.x, mouse.y)
	if ( uiClickedElement <> 0 ) then
		if (this._focus <> uiClickedElement) then
			if (this._focus <> 0 ) then
				this._focus->OnFocus(false)
			end if
			mutexlock(this._mutex)
			this._focus = uiClickedElement
			mutexunlock(this._mutex)
			this._focus->OnFocus(true)
		end if
		if (*uiClickedElement is uiLabel) then
			this._selection = cast(uiLabel ptr, uiClickedElement)
			this.Redraw()
		else
			uiClickedElement->OnClick(mouse)
		end if
	elseif (this._focus <> 0) then
		this._focus->OnFocus(false)
		mutexlock(this._mutex)
		this._focus = 0
		mutexunlock(this._mutex)
	end if
end sub

sub uiListBox.OnMouseMove(mouse as uiMouseEvent)
	mouse.x = mouse.x - this.dimensions.x
	mouse.y = mouse.y - this.dimensions.y
	if ( this._focus <> 0 ) then
		this._focus->OnMouseMove(mouse)
	end if
end sub

sub uiListBox.OnKeypress(keypress as uiKeyEvent)
	if (this._focus <> 0) then
		this._focus->OnKeyPress(keypress)
	end if
end sub

sub uiListBox.OnMouseWheel( mouse as uiMouseEvent )
	this._scrollbar->OnMouseWheel( mouse  )
	' TODO Should listen to event, but in the meantime:
	this.redraw()
end sub

function uiListBox.Render() as fb.image ptr
	if ( this._stateChanged ) then
		dim as integer offset = 16 * this._scrollbar->Value
		dim element as uiControl ptr
		with this.dimensions
			line this._surface, (1, 1) - (.w-2, .h-2), ElementLight, BF
			line this._surface, (0, 0) - (.w-1, .h-1), 0, B
			
			for i as integer = 1 to this._dimensions.h/16
				element =  this._children->item(i+this._scrollbar->Value)
				if (element = this._selection) then
					line this._surface, (2, (i-1)*16 - offset + 1) - (.w -2, (i)*16 - offset -2), &hFFA0A0FF, BF
				end if
				
				put this._surface, (2, (i-1)*16), element->render(), ALPHA
				
			next
		end with
		put this._surface, (this._scrollbar->dimensions.x, this._scrollbar->dimensions.y),this._scrollbar->Render(),ALPHA
	end if
	return this._surface
end function

end namespace
