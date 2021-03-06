' checkbox.bas - StringEpsilon, 2015, WTFPL

namespace fbUI

#include once "../control.bas"

type uiCheckBox extends uiControl
	private:
		_boxOffset as integer
		_Label as string 
		_value as boolean  = false
		
	public:
		declare function Render() as fb.image  ptr
		
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)

		declare constructor overload( x as integer, y as integer, label as string = "")
		declare constructor(dimensions as uiDimensions)
		declare constructor(byref json as jsonItem)

		declare property Label() as string
		declare property Label(value as string)
			
		declare property Value() as boolean
		declare property Value(value as boolean)
end type

constructor uiCheckBox( byref json as jsonItem )
	base(json)
	this._dimensions.h = 16
	this._label = json["label"].value
	if ( this._dimensions.w = 0 ) then
		this._dimensions.w = 20 + len(this._label)*FONT_WIDTH
	end if
	this._boxOffset = ( this._dimensions.h-12 ) \ 2
	this.CreateBuffer()
end constructor

constructor uiCheckBox( x as integer, y as integer, newLabel as string = "")
	base()
	
	with this._dimensions
		.h = 16
		.w = 20 + (len(newlabel)*FONT_WIDTH)
		.x = x
		.y = y
		this._boxOffset = ( .h-12 ) \ 2
	end with
	this._label = newLabel
	this.CreateBuffer()
end constructor

constructor uiCheckBox(newdim as uiDimensions)
	base()
	this._dimensions = newdim
	this._boxOffset = ( this.Dimensions.h-12 ) \ 2
	this.CreateBuffer()
end constructor

property uiCheckBox.Label(newValue as string)
	if ( len(value) <> len(this._label) ) then 
		mutexlock(this._mutex)
		this._label = newValue
		mutexunlock(this._mutex)
	else
		mutexlock(this._mutex)
		this._label = newValue
		this._dimensions.w = 20 + len(value) * FONT_WIDTH
		this.CreateBuffer()
		mutexunlock(this._mutex)
	end if
end property

property uiCheckBox.Label() as string
	return this._label
end property

property uiCheckBox.Value(newValue as boolean)
	mutexlock(this._mutex)
	this._value = newValue
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiCheckBox.Value() as boolean
	return this._value
end property

function uiCheckBox.Render() as  fb.image  ptr
	with this._dimensions
		line this._surface, (1, 1) - (.h-2, .h-2), ElementLight, BF
		line this._surface, (1, 1) - (.h-2, .h-2), ElementBorderColor, B
		
		if (this._value) then
			line this._surface, (.h-2, 1) - (1, .h-2), ElementBorderColor
			line this._surface, (.h-3, 1) - (1, .h-3), ElementBorderColor
			
			line this._surface, (.h-2,.h-2) - (1,1), ElementBorderColor
			line this._surface, (.h-2,.h-3) - (2,1), ElementBorderColor
		end if
		
		draw string this._surface, (.h+3, (.h - FONT_HEIGHT)/2 ), this.label
	end with
	return this._surface
end function

sub uiCheckBox.OnClick(mouse as UiMouseEvent)
	if ( mouse.lmb = uiReleased ) then
		dim as integer x, y, boxOffset
		
		with this._dimensions
			x = mouse.x - .x
			y = mouse.y - .y
			boxOffset =(.h-12)\2
		end with
		
		if ( x >= boxOffset ) AND ( x <= boxOffset +12 ) AND (y >= boxOffset) AND (y <= boxOffset +12) then
			mutexlock(this._mutex)
			this._value = not(this._value)
			mutexunlock(this._mutex)
			this.DoCallback()
			this.Redraw()
		end if
	end if
end sub

sub uiCheckBox.OnKeyPress( keyPress as uiKeyEvent )
	if ( keyPress.key = " " ) then
		mutexlock(this._mutex)
		this._value = not(this._value)
		mutexunlock(this._mutex)
		this.DoCallback()
		this.Redraw()
	end if
end sub

end namespace
