' menuItem.bas - StringEpsilon, 2015, WTFPL

namespace fbUI

#include once "../common/controlContainer.bas"

type uiMenuItem extends uiControlContainer
	protected:
		dim as string _Label
		dim as boolean _hold
	public:
		dim as boolean IsChecked = true
		
		declare virtual function Render() as fb.image  ptr
		declare virtual sub OnClick( mouse as uiMouseEvent)	
		declare virtual sub Onfocus( focus as boolean)
		
		declare constructor overload(newLabel as string = "")

		declare property Label() as string
		declare property Label(value as string)
end type

constructor uiMenuItem(newLabel as string = "")
	base()
	with this._dimensions
		.h = FONT_HEIGHT + 6
		.w = 20 + (len(newlabel)*FONT_WIDTH)
	end with
	this._label = newLabel
	this.CreateBuffer()
end constructor

property uiMenuItem.Label(value as string)
	mutexlock(this._mutex)
	this._label = value
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiMenuItem.Label() as string
	return this._label
end property

function uiMenuItem.Render() as fb.image  ptr
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

sub uiMenuItem.OnClick( mouse as uiMouseEvent )
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

sub uiMenuItem.OnFocus( focus as boolean )
	if (focus = false) then
		this._hold = false
		base.Redraw()
	end if
end sub

end namespace
