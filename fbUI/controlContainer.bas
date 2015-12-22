' control.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "control.bas"

type uiControlContainer extends uiControl
	protected:
		_children as controlList ptr
		_focus as uiControl ptr
		
		declare function GetControlAt(x as integer, y as integer) as uiControl ptr
		declare constructor (x as integer, y as integer)
	
	public:	
		declare virtual destructor()
		declare constructor overload()
		declare constructor(byref json as jsonItem)
		
		declare sub AddControl(control as uiControl ptr)
		
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)
		declare virtual sub OnMouseMove(mouse as uiMouseEvent)
		declare virtual sub OnFocus(focus as boolean)
end type

constructor uiControlContainer()
	base()
	this._children = new controlList()
end constructor 

constructor uiControlContainer(x as integer, y as integer)
	base(x,y)
	this._children = new controlList()
end constructor 

constructor uiControlContainer(byref json as jsonItem)
	base(json)
	this._children = new controlList()
end constructor 

Destructor uiControlContainer()
	if (this._mutex <> 0 ) then
		mutexdestroy(this._mutex)
		this._mutex = 0
	end if
	for i as integer = 0 to this._children->count -1
		delete this._children->item(i)
	next
	delete this._children	
end destructor

function uiControlContainer.GetControlAt(x as integer, y as integer) as uiControl ptr
	dim result as uiControl ptr = 0
	dim i as integer = 0
	dim child as uiControl ptr
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

sub uiControlContainer.AddControl( control as uiControl ptr)
	if (control <> 0) then
		mutexlock(this._mutex)
		for i as integer = 0 to this._children->count 
			if (this._children->item(i) = control) then
				mutexunlock(this._mutex)
				exit sub
			end if
		next
		control->Parent = @this
		this._children->append(control)
		mutexunlock(this._mutex)
		this.Redraw()
	end if
end sub

sub uiControlContainer.OnClick(mouse as uiMouseEvent)
end sub

sub uiControlContainer.OnMouseMove(mouse as uiMouseEvent)
end sub

sub uiControlContainer.OnKeypress(keypress as uiKeyEvent)
end sub


sub uiControlContainer.OnFocus(focus as boolean)
	base.OnFocus(focus)
	if ( this._focus <> 0 ) then
		this._focus->OnFocus(false)
	end if
end sub
