' uiButton.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/control.bas"

namespace fbUI

type uiButton extends uiControl
	protected:
		dim as string _Label
		dim as boolean _hold
	public:
		dim as boolean IsChecked = true
		
		declare virtual function Render() as fb.image  ptr
		declare virtual sub OnClick( mouse as uiMouseEvent)	
		declare virtual sub Onfocus( focus as boolean)
		
		declare constructor overload( x as integer, y as integer, newLabel as string = "", length as integer = 0)

		declare property Label() as string
		declare property Label(value as string)
end type

constructor uiButton( x as integer, y as integer, newLabel as string = "", length as integer = 0)
	base()
	with this._dimensions
		.h = FONT_HEIGHT + 6
		.w = 20 + IIF(length = 0, (len(newlabel)*FONT_WIDTH), length * FONT_WIDTH)
		.x = x
		.y = y
	end with
	this._label = newLabel
	this.CreateBuffer()
end constructor

property uiButton.Label(value as string)
	mutexlock(this._mutex)
	this._label = value
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiButton.Label() as string
	return this._label
end property

function uiButton.Render() as fb.image  ptr
	with this._dimensions
		if (this._hold ) then
			line this._surface, (1, 1) - (.w-2, .h-2), ElementDark, BF
		else
			line this._surface, (1, 1) - (.w-2, .h-2), ElementLight, BF
		end if
		line this._surface, (0, 0) - (.w-1, .h-1), ElementBorderColor, B
		draw string this._surface, ((.w - FONT_HEIGHT * len(this.Label)) / 2 ,(.h - FONT_HEIGHT)/2 ), this.label,ElementTextColor
		
	end with
	return this._surface
end function

sub uiButton.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = uiReleased  ) then
		mutexlock(this._mutex)
		this._hold = false
		sleep 75, 1
		mutexunlock(this._mutex)
		this.DoCallback()
		base.Redraw()
	elseif ( mouse.lmb = uiClick OR mouse.lmb = uiHold ) then
		mutexlock(this._mutex)
		this._hold = true
		mutexunlock(this._mutex)
		base.Redraw()
	end if
end sub

sub uiButton.OnFocus( focus as boolean )
	if (focus = false) then
		this._hold = false
		base.Redraw()
	end if
end sub

end namespace
