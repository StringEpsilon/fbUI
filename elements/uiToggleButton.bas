' uiButton.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "uiButton.bas"

type uiToggleButton extends uiButton
	dim as bool State = false
	
	declare virtual function Render() as fb.image  ptr
	declare virtual sub OnClick( mouse as uiMouseEvent)	
	
	declare constructor( x as integer, y as integer, newLabel as string = "")
	declare constructor(newdim as uiDimensions, newLabel as string = "")
	
	private:
		declare constructor(byref element as const uiToggleButton)
end type


constructor uiToggleButton(byref element as const uiToggleButton)
	base(element)
end constructor


constructor uiToggleButton( x as integer, y as integer, newLabel as string = "")
	base(x,y,newLabel)
end constructor

constructor uiToggleButton(newdim as uiDimensions, newLabel as string = "")
	base(newDim, newLabel)
end constructor

function uiToggleButton.Render() as fb.image  ptr
	with this.dimensions
		mutexlock(this._mutex)
		'Dirty, dirty workaround ... I'm lazy.. *sigh*
		this._hasFocus = this.State
		mutexunlock(this._mutex)
		
		DrawButton(this._cairo,.w,.h,  this.State)
		DrawLabel(this._cairo, 10, (.h - CAIRO_FONTSIZE)/2 , this._Label)
	end with

	return this._buffer
end function

sub uiToggleButton.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = released  ) then
		mutexlock(this._mutex)
		this.State = not(this.State)
		
		mutexunlock(this._mutex)
		if ( this.callback <> 0 ) then
'			threaddetach(threadcreate(this.callback, @this))
		end if
		this.DoRedraw()
	end if
end sub
