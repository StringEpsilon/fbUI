' uiLabel.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElement.bas"

type uiLabel extends uiElement
	private:
		_Text as string 
	public:
		declare function Render() as cairo_surface_t  ptr
		
		declare constructor overload( x as integer, y as integer,newText as string,  length as integer = 0)

		declare property Text() as string
		declare property Text(value as string)
end type

constructor uiLabel( x as integer, y as integer,newText as string,  length as integer = 0)
	base()	
	with this._dimensions
		.h = 16
		.w = 4 + IIF(length = 0, len(newText) * CAIRO_FONTWIDTH, length * CAIRO_FONTWIDTH)
		.x = x
		.y = y
	end with
	this._text = newText
	this.CreateBuffer()
end constructor

property uiLabel.Text(value as string)
	mutexlock(this._mutex)
	this._text = value
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiLabel.Text() as string
	return this._Text
end property

function uiLabel.Render() as cairo_surface_t ptr
	with this._dimensions
		cairo_save (this._cairo)
		cairo_set_source_rgba(this._cairo,0,0,0,0)
		cairo_set_operator (this._cairo, CAIRO_OPERATOR_SOURCE)
		cairo_paint(this._cairo)
		cairo_restore (this._cairo)
		
		if (len(this._text) <> 0) then
			DrawLabel(this._cairo, 2, (.h - CAIRO_FONTSIZE)/2, this._text)
		end if
		
	end with
	return this._surface
end function
