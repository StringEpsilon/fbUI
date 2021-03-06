' radiobutton.bas - StringEpsilon, 2015, WTFPL

namespace fbUI

#include once "../control.bas"

type _uiRadioButtonlist as uiRadioButtonlist

type uiRadiobutton extends uiControl
	private:
		_boxOffset as integer
		_Label as string 
		_value as boolean = false
		_head as uiRadiobutton ptr
	protected:
		_group as _uiRadioButtonlist ptr
		declare sub SelectElement(selection as uiRadiobutton ptr)
	public:
		declare function Render() as  fb.image  ptr
		
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)

		declare constructor overload( x as integer, y as integer, label as string = "", head as uiRadiobutton ptr = 0)

		declare property Label() as string
		declare property Label(newValue as string)
			
		declare property Value() as boolean
		declare property Value(newValue as boolean)

end type

declareList(uiRadioButton, uiRadioButtonlist)

constructor uiRadiobutton( x as integer, y as integer, newLabel as string = "", head as uiRadiobutton ptr = 0)
	base()
	with this._dimensions
		.h = 16
		.w = 20 + len(newlabel) * FONT_WIDTH
		.x = x
		.y = y
		this._boxOffset = ( .h-12 ) \ 2
	end with
	this._label = newLabel
	if ( head <> 0 ANDALSO head->_group <> 0 ) then
		this._head = head
		this._head->_group->Append(@this)
	else
		this._group = new uiRadioButtonlist()
		this._group->Append(@this)
	end if
	this.CreateBuffer()
end constructor

property uiRadiobutton.Label(newValue as string)
	if ( len(newValue) <> len(this._label) ) then 
		mutexlock(this._mutex)
		this._label = newValue
		mutexunlock(this._mutex)
	else
		mutexlock(this._mutex)
		this._label = newValue
		this._dimensions.w = 20 + len(newValue)* FONT_WIDTH
		this.CreateBuffer()
		mutexunlock(this._mutex)
	end if
end property

property uiRadiobutton.Label() as string
	return this._label
end property

property uiRadiobutton.Value(newValue as boolean)
	if (newValue = this._value) then exit property
	
	if (newValue = true) then
		mutexlock(this._mutex)
		this._value = true
		mutexunlock(this._mutex)
		if (this._group = 0 AND this._head <> 0) then
			this._head->SelectElement(@this)
		else
			this.SelectElement(@this)
		end if
	else
		mutexlock(this._mutex)
		this._value = false
		mutexunlock(this._mutex)
	end if
end property

property uiRadiobutton.Value() as boolean
	return this._value
end property

function uiRadiobutton.Render() as  fb.image ptr
	with this._dimensions		
		CIRCLE this._surface, (.h/2,.h/2), .h/2-1,ElementBorderColor
		
		if (this._value) then
			CIRCLE this._surface, (.h/2,.h/2), .h/4,ElementBorderColor,,,,F
		else
			CIRCLE this._surface, (.h/2,.h/2), .h/4,BackgroundColor,,,,F
		end if
		
		draw string this._surface, ((.w - FONT_HEIGHT * len(this.Label)) / 2 +.h/2+1 ,(.h - FONT_HEIGHT)/2 ), this.label, ElementTextColor
		
	end with
	return this._surface
end function

sub uiRadiobutton.OnClick(mouse as UiMouseEvent)
	if ( mouse.lmb = uiReleased ) then
		dim as integer x, y, boxOffset
		
		with this._dimensions
			x = mouse.x - .x
			y = mouse.y - .y
			boxOffset =(.h-12)\2
		end with
		
		if ( x >= boxOffset ) AND ( x <= boxOffset +12 ) AND (y >= boxOffset) AND (y <= boxOffset +12) then
			this.Value = true
			this.DoCallback()
		end if
	end if
end sub

sub uiRadiobutton.SelectElement(selection as uiRadiobutton ptr)
	if (this._group <> 0 AND this._head = 0) then
		dim as uiRadiobutton ptr item
		for i as integer = 0 to this._group->count -1
			item = this._group->item(i)
			
			if (item = selection) then
				mutexlock(item->_mutex)
				item->_value = true
				mutexunlock(item->_mutex)
				item->Redraw()
			elseif (item->_value) then
				item->Value = false
				item->Redraw()
			end if
		next
	end if
end sub

sub uiRadiobutton.OnKeyPress( keyPress as uiKeyEvent )
	if ( keyPress.key = " " ) then
		this.Value = true
		this.DoCallback()
	end if
end sub

end namespace
