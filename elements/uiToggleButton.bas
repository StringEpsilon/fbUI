' uiButton.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiButton.bas"

type uiToggleButton extends uiButton
	dim as boolean State = false
	
	declare virtual function Render() as fb.image  ptr
	declare virtual sub OnClick( mouse as uiMouseEvent)	
	
	declare constructor( x as integer, y as integer, newLabel as string = "")
	
	private:
		declare constructor(byref element as const uiToggleButton)
end type


constructor uiToggleButton(byref element as const uiToggleButton)
	base(element)
end constructor


constructor uiToggleButton( x as integer, y as integer, newLabel as string = "")
	base(x,y,newLabel)
end constructor


function uiToggleButton.Render() as fb.image  ptr
	with this.dimensions
		if (this._hold OR this.State ) then
			line this._surface, (1, 1) - (.w-2, .h-2), ElementDark, BF
		else
			line this._surface, (1, 1) - (.w-2, .h-2), ElementLight, BF
		end if
		line this._surface, (0, 0) - (.w-1, .h-1), ElementBorderColor, B
		draw string this._surface, ((.w - FONT_HEIGHT * len(this.Label)) / 2 ,(.h - FONT_HEIGHT)/2 ), this.label,ElementTextColor
		
	end with
	return this._surface
end function

sub uiToggleButton.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = uiReleased  ) then
		mutexlock(this._mutex)
		this.State = not(this.State)
		this._hold = false
		mutexunlock(this._mutex)
		this.DoCallback()
		this.Redraw()
	elseif ( mouse.lmb = uiClick OR mouse.lmb = uiHold ) then
		mutexlock(this._mutex)
		this._hold = true
		mutexunlock(this._mutex)
		base.Redraw()
	end if
end sub
