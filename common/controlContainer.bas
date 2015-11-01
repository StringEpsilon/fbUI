' control.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "control.bas"

namespace fbUI

type controlContainer extends control
	protected:
		_children as controlList ptr
		_focus as control ptr
		
		declare function GetElementAt(x as integer, y as integer) as control ptr
		declare constructor (x as integer, y as integer)
	
	public:
		Callback as sub(payload as any ptr)
				
		declare destructor()
		declare constructor overload()
				
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)
		declare virtual sub OnMouseMove(mouse as uiMouseEvent)
		declare virtual sub OnFocus(focus as boolean)
end type

constructor controlContainer()
	base()
	this._children = new controlList()
end constructor 

constructor controlContainer(x as integer, y as integer)
	base(x,y)
	this._children = new controlList()
end constructor 

Destructor controlContainer()
	base.Destructor()
	delete this._children
end destructor

function controlContainer.GetElementAt(x as integer, y as integer) as control ptr
	dim result as control ptr = 0
	dim i as integer = 0
	dim child as control ptr
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

sub controlContainer.OnClick(mouse as uiMouseEvent)
end sub

sub controlContainer.OnMouseMove(mouse as uiMouseEvent)
end sub

sub controlContainer.OnKeypress(keypress as uiKeyEvent)
end sub


sub controlContainer.OnFocus(focus as boolean)
	base.OnFocus(focus)
	if ( this._focus <> 0 ) then
		this._focus->OnFocus(false)
	end if
end sub

end namespace
