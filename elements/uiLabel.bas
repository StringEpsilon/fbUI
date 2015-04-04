' uiLabel.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElement.bas"

type uiLabel extends uiElement
	private:
		_Text as string 
	public:
		declare function Render() as fb.image  ptr
		
		declare constructor overload( x as integer, y as integer, newText as string = "")
		declare constructor(dimensions as uiDimensions)

		declare property Text() as string
		declare property Text(value as string)
end type

constructor uiLabel( x as integer, y as integer, newText as string = "")
	base()
	
	with this._dimensions
		.h = 16
		.w = 4 + (len(newText)*7)
		.x = x
		.y = y
	end with
	this._text = newText
	this.CreateBuffer()
end constructor

constructor uiLabel(newdim as uiDimensions)
	base()
	this._dimensions = newdim
	this.CreateBuffer()
end constructor

property uiLabel.Text(value as string)
	if ( len(value) <> len(this._text) ) then 
		mutexlock(this._mutex)
		this._text = value
		mutexunlock(this._mutex)
	else
		mutexlock(this._mutex)
		this._text = value
		this._dimensions.w = 2 + len(value)*7
		this.CreateBuffer()
		mutexunlock(this._mutex)
	end if
end property

property uiLabel.Text() as string
	return this._Text
end property

function uiLabel.Render() as fb.image  ptr
	with this._dimensions
		cairo_set_source_rgba(this._cairo,&hE8/255,&hE8/255,&hE8/255,1)
		cairo_paint(this._cairo)
		DrawLabel(this._cairo, 2, (.h - CAIRO_FONTSIZE)/2, this._text)
	end with
	return this._buffer
end function
