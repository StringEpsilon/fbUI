' uiElement.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElementContainer.bas"
#include once "uiLabel.bas"
#include once "uiVScrollbar.bas"

type uiListBox extends uiElementContainer
	private:
		_selection as uiLabel ptr
		_scrollbar as uiVScrollbar ptr
		declare function GetElementAt(x as integer, y as integer) as uiElement ptr
	public:
		declare function Render() as cairo_surface_t ptr
		Callback as sub(payload as any ptr)
		
		declare destructor()
		declare constructor (x as integer, y as integer,h as integer, w as integer, list() as string)
				
		declare sub OnClick(mouse as uiMouseEvent)
		declare sub OnKeypress(keypress as uiKeyEvent)
		declare sub OnMouseMove(mouse as uiMouseEvent)
end type

constructor uiListBox(x as integer, y as integer,h as integer, w as integer, list() as string)
	base(x,y)
	this._dimensions.h = h
	this._dimensions.w = w
	
	this._scrollbar = new uiVScrollbar(w-11, 2, h-4,ubound(list)-h/16+1, lbound(list))
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

function uiListBox.GetElementAt(x as integer, y as integer) as uiElement ptr
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


sub uiListBox.OnClick(mouse as uiMouseEvent)
	mouse.x = mouse.x - this.dimensions.x
	mouse.y = mouse.y - this.dimensions.y
	
	dim clickedElement as uiElement ptr = this.GetElementAt(mouse.x, mouse.y)
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
		if (*clickedElement is uiLabel) then
			this._selection = cast(uiLabel ptr, clickedElement)
			this.Redraw()
		else
			clickedElement->OnClick(mouse)
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


function uiListBox.Render() as cairo_surface_t ptr
	dim as integer offset = 16 * this._scrollbar->Value
	dim element as uiElement ptr

	cairo_set_source_rgb(this._cairo,1,1,1)
	cairo_paint(this._cairo)
	
	for i as integer = 1 to this._dimensions.h/16
		element = this._children->item(i+this._scrollbar->Value)
		cairo_set_source_surface (this._cairo, element->Render(), 2, (i-1)*16)
		cairo_paint (this._cairo)
	next
	cairo_set_source_surface (this._cairo,this._scrollbar->Render(), this._scrollbar->dimensions.x, this._scrollbar->dimensions.y)
	cairo_paint (this._cairo)
	return this._surface
end function

