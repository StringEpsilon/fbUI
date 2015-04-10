' uiVScrollbar.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElement.bas"



type uiVScrollbar extends uiElement
	private:
		_min as integer
		_max as integer
		_segments as integer
		_value as integer
		_knobSize as double
		_hold as bool = false
		declare sub CalculateValue(position as integer)
	public:
		declare function Render() as fb.image  ptr
		
		declare constructor overload( x as integer, y as integer, h as integer, max as integer, min as integer = 1)
		declare constructor(dimensions as uiDimensions)

		declare property Value() as integer
		declare property Value(newValue as integer)
		
		declare virtual sub OnMouseMove( mouse as uiMouseEvent )
		declare virtual sub OnClick( mouse as uiMouseEvent ) 
end type

constructor uiVScrollbar( x as integer, y as integer, h as integer, max as integer, min as integer = 1)
	base()
	with this._dimensions
		.h = h
		.w = 10
		.x = x
		.y = y
	end with
	this._max = max
	this._min = min
	this._value = this._min
	this._segments = (this._max - this._min + 1) 
	this._knobSize = (this.dimensions.h-1) / this._segments
	this.CreateBuffer()
end constructor

constructor uiVScrollbar(newdim as uiDimensions)
	base()
	this._dimensions = newdim
	this.CreateBuffer()
end constructor

property uiVScrollbar.Value() as integer
	return this._value
end property


property uiVScrollbar.Value(newValue as integer)
	mutexlock(this._mutex)
	this._value = newValue
	mutexunlock(this._mutex)
	this.Redraw()
end property

sub uiVScrollbar.OnMouseMove( mouse as uiMouseEvent )
	if (mouse.lmb = hit  OR mouse.lmb = hold) then
		dim y as integer = mouse.y - this._dimensions.y 
		if ( y > 0 and y < this._dimensions.h and this._hold ) then
			mutexlock(this._mutex)
			this.CalculateValue(y)
			mutexunlock(this._mutex)
		end if
	end if
end sub

sub uiVScrollbar.CalculateValue(position as integer)
	dim as integer newValue =  int( position / (this.dimensions.h+1) * this._segments)  + this._min
	if (this._value <> newValue ) then
		this._value = newValue
		this.Redraw()
		
		if (this.callback <> 0) then
			threaddetach(threadcreate(this.callback, @this))
		end if
	end if
end sub

sub uiVScrollbar.OnClick( mouse as uiMouseEvent )
	dim y as integer = mouse.y - this._dimensions.y 
	dim as integer y1, y2 
	y1 = (this._knobSize * (this._value - this._min))
	y2 = y1 + this._knobSize
		
	if ( mouse.lmb = hit ) then
		if (y >= y1 and y <= y2 ) then
			this._hold = true
		end if
	elseif ( mouse.lmb = released ) then
		this._hold = false
		if (y < y1 OR y > y2) then
			this.CalculateValue(y)
		end if
	else
		this._hold = false
	end if
end sub

function uiVScrollbar.Render() as fb.image  ptr
	with this._dimensions
		dim knobY as integer = (this._knobSize * (this._value - this._min))
		
		cairo_set_source_rgb(this._cairo,RGBA_R(ElementLight),RGBA_G(ElementLight),RGBA_B(ElementLight))
		cairo_set_line_width(this._cairo, 1)
		cairo_paint(this._cairo)
		cairo_rectangle (this._cairo, .5, .5, .w-1, .h-1)
		cairo_set_source_rgb(this._cairo,0,0,0)
		
		cairo_stroke (this._cairo)
				
		cairo_rectangle (this._cairo, .5,knobY+.5, .w-1,this._knobSize)
		cairo_stroke_preserve (this._cairo)
		cairo_set_source_rgb(this._cairo,RGBA_R(ElementDark),RGBA_G(ElementDark),RGBA_B(ElementDark))
		cairo_fill(this._cairo)		
	end with
	return this._buffer
end function
