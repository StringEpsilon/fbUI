' uiButton.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiButton.bas"

type uiToggleButton extends uiButton
	dim as bool State = false
	
	declare virtual function Render() as cairo_surface_t  ptr
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


function uiToggleButton.Render() as cairo_surface_t  ptr
	with this.dimensions
		DrawButton(this._cairo,.w,.h,  this.State OR this._hold)
		DrawLabel(this._cairo, 10, (.h - CAIRO_FONTSIZE)/2 , this._Label)
	end with
	return this._surface
end function

sub uiToggleButton.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = released  ) then
		mutexlock(this._mutex)
		this.State = not(this.State)
		this._hold = false
		mutexunlock(this._mutex)
		if ( this.callback <> 0 ) then
			threaddetach(threadcreate(this.callback, @this))
		end if
		this.Redraw()
	elseif ( mouse.lmb = hit OR mouse.lmb = hold ) then
		mutexlock(this._mutex)
		this._hold = true
		mutexunlock(this._mutex)
		base.Redraw()
	end if
end sub
