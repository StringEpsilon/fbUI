' uiElement.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiElement.bas"

type uiElementContainer extends uiElement
	protected:
		_children as uiElementList ptr
		_focus as uiElement ptr
		
		declare function GetElementAt(x as integer, y as integer) as uiElement ptr
		declare constructor (x as integer, y as integer)
	
	public:
		Callback as sub(payload as any ptr)
		
		
		declare destructor()
		declare constructor overload()
				
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)
		declare virtual sub OnMouseMove(mouse as uiMouseEvent)
		declare virtual sub OnFocus(focus as bool)
end type

constructor uiElementContainer()
	base()
	this._children = new uiElementList()
end constructor 

constructor uiElementContainer(x as integer, y as integer)
	base(x,y)
	this._children = new uiElementList()
end constructor 

Destructor uiElementContainer()
	base.Destructor()
	delete this._children
end destructor

function uiElementContainer.GetElementAt(x as integer, y as integer) as uiElement ptr
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

sub uiElementContainer.OnClick(mouse as uiMouseEvent)
end sub

sub uiElementContainer.OnMouseMove(mouse as uiMouseEvent)
end sub

sub uiElementContainer.OnKeypress(keypress as uiKeyEvent)
end sub


sub uiElementContainer.OnFocus(focus as bool)
	base.OnFocus(focus)
	if ( this._focus <> 0 ) then
		this._focus->OnFocus(false)
	end if
end sub


