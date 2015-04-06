' uiHScrollbar.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElement.bas"


type uiHScrollbar extends uiElement
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
		
		declare constructor overload( x as integer, y as integer, w as integer, max as integer, min as integer = 1)
		declare constructor(dimensions as uiDimensions)

		declare property Value() as integer
		declare property Value(newValue as integer)
		
		declare virtual sub OnMouseMove( mouse as uiMouseEvent )
		declare virtual sub OnClick( mouse as uiMouseEvent ) 
end type

constructor uiHScrollbar( x as integer, y as integer, w as integer, max as integer, min as integer = 1)
	base()
	with this._dimensions
		.h = 10
		.w = w
		.x = x
		.y = y
	end with
	this._max = max
	this._min = min
	this._value = this._min
	this._segments = (this._max - this._min + 1) 
	this._knobSize = (this.dimensions.w-1) / this._segments
	this.CreateBuffer()
end constructor

constructor uiHScrollbar(newdim as uiDimensions)
	base()
	this._dimensions = newdim
	this.CreateBuffer()
end constructor

property uiHScrollbar.Value() as integer
	return this._value
end property


property uiHScrollbar.Value(newValue as integer)
	mutexlock(this._mutex)
	this._value = newValue
	mutexunlock(this._mutex)
	this.DoRedraw()
end property

sub uiHScrollbar.CalculateValue(position as integer)
	dim as integer newValue =  int( position / (this.dimensions.w+1) * this._segments)  + this._min
	if (this._value <> newValue ) then
		this._value = newValue
		this.DoRedraw()
		if (this.callback <> 0) then
			threaddetach(threadcreate(this.callback, @this))
		end if
	end if
end sub

sub uiHScrollbar.OnMouseMove( mouse as uiMouseEvent )
	if (mouse.lmb = hit  OR mouse.lmb = hold) then
		dim x as integer = mouse.x - this._dimensions.x
		if ( x > 0 and x < this._dimensions.w and this._hold ) then
			mutexlock(this._mutex)
			this.CalculateValue(x)
			mutexunlock(this._mutex)
		end if
	end if
end sub

sub uiHScrollbar.OnClick( mouse as uiMouseEvent )
	dim x as integer = mouse.x - this._dimensions.x 
	dim as integer x1, x2 
	x1 = (this._knobSize * (this._value - this._min))
	x2 = x1 + this._knobSize
		
	if ( mouse.lmb = hit ) then
		if (x >= x1 and x <= x2 ) then
			this._hold = true
		end if
	elseif ( mouse.lmb = released ) then
		this._hold = false
		if (x < x1 OR x > x2) then
			this.CalculateValue(x)
		end if
	else
		this._hold = false
	end if
end sub

function uiHScrollbar.Render() as fb.image  ptr
	with this._dimensions
		dim knobX as integer = (this._knobSize * (this._value - this._min))
		
		cairo_set_source_rgb(this._cairo,RGBA_R(ElementLight),RGBA_G(ElementLight),RGBA_B(ElementLight))
		cairo_set_line_width(this._cairo, 1)
		cairo_paint(this._cairo)
		cairo_rectangle (this._cairo, .5, .5, .w-1, .h-1)
		cairo_set_source_rgb(this._cairo,0,0,0)
		
		cairo_stroke (this._cairo)
				
		cairo_rectangle (this._cairo, knobX+.5,.5,this._knobSize,.h-1)
		cairo_stroke_preserve (this._cairo)
		cairo_set_source_rgb(this._cairo,RGBA_R(ElementDark),RGBA_G(ElementDark),RGBA_B(ElementDark))
		cairo_fill(this._cairo)		
	end with
	return this._buffer
end function
