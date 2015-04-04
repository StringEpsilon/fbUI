' uiVScrollbar.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElement.bas"

type uiVScrollbar extends uiElement
	private:
		_scrollSteps as uinteger = 20
		_position as uinteger = 1
		_hold as bool = false
	public:
		declare function Render() as fb.image  ptr
		
		declare constructor overload( x as integer, y as integer, h as integer, w as integer = 16)
		declare constructor(dimensions as uiDimensions)

		declare property Position() as integer
		declare property Position(value as integer)
		
		declare virtual sub OnMouseMove( mouse as uiMouseEvent )
end type

constructor uiVScrollbar( x as integer, y as integer, h as integer, w as integer = 16)
	base()
	with this._dimensions
		.h = h
		.w = w
		.x = x
		.y = y
	end with
	this.CreateBuffer()
end constructor

constructor uiVScrollbar(newdim as uiDimensions)
	base()
	this._dimensions = newdim
	this.CreateBuffer()
end constructor

property uiVScrollbar.Position() as integer
	return this._position
end property


property uiVScrollbar.Position(value as integer)
	mutexlock(this._mutex)
	this._position = value
	mutexunlock(this._mutex)
	this.DoRedraw()
end property

sub uiVScrollbar.OnMouseMove( mouse as uiMouseEvent )
	if (mouse.lmb = hit  OR mouse.lmb = hold) then
	
		dim y as integer = mouse.y - this._dimensions.y 
		
		if ( y > 0 and y < this._dimensions.h ) then
			dim as integer newPosition = y / this._scrollsteps
			if newPosition < 0 then newPosition = 0
			if newPosition > this._scrollSteps then newPosition = this._scrollSteps
			
			if (newPosition <> this._Position) then
				mutexlock(this._mutex)
				this._position = newPosition
				mutexunlock(this._mutex)
				shell "echo scrolling: " & y
				
				this.DoRedraw()
			end if
		end if
		
	end if
end sub

function uiVScrollbar.Render() as fb.image  ptr
	dim as integer ratio = this.dimensions.h / this._scrollSteps
	dim as double DraggableHeight = this.dimensions.h / this._scrollSteps
	with this._dimensions
		cairo_set_source_rgb(this._cairo,RGBA_R(ElementLight),RGBA_G(ElementLight),RGBA_B(ElementLight))
		cairo_paint(this._cairo)
				
		cairo_rectangle (this._cairo, .5, .5, .w-1, .h-1)
		cairo_set_source_rgb(this._cairo,0,0,0)
		
		cairo_set_line_width (this._cairo, 1)
		cairo_stroke (this._cairo)
		
		
		shell "echo " & this._position & " / "& DraggableHeight & " / " & .h
		
		cairo_rectangle (this._cairo, .5,  this._position*ratio+.5, .w-1,DraggableHeight)
		cairo_set_source_rgb(this._cairo,RGBA_R(ElementDark),RGBA_G(ElementDark),RGBA_B(ElementDark))
		cairo_fill_preserve(this._cairo)
		
		cairo_set_source_rgb(this._cairo,0,0,0)
		cairo_set_line_width (this._cairo, 1)
		cairo_stroke (this._cairo)
		
		'DrawLabel(this._cairo, 2, (.h - CAIRO_FONTSIZE)/2, this._text)
	end with
	return this._buffer
end function
