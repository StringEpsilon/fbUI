' uiCheckBox.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "../common/uiElement.bas"


type uiCheckBox extends uiElement
	private:
		_boxOffset as integer
		_Label as string 
		_IsChecked as bool  = false
		
	public:
		declare function Render() as cairo_surface_t  ptr
		
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)

		declare constructor overload( x as integer, y as integer, label as string = "")
		declare constructor(dimensions as uiDimensions)

		declare property Label() as string
		declare property Label(value as string)
			
		declare property IsChecked() as bool
		declare property IsChecked(value as bool)

end type

constructor uiCheckBox( x as integer, y as integer, newLabel as string = "")
	base()
	
	with this._dimensions
		.h = 16
		.w = 20 + (len(newlabel)*CAIRO_FONTWIDTH)
		.x = x
		.y = y
		this._boxOffset = ( .h-12 ) \ 2
	end with
	this._label = newLabel
	this.CreateBuffer()
end constructor

constructor uiCheckBox(newdim as uiDimensions)
	base()
	this._dimensions = newdim
	this._boxOffset = ( this.Dimensions.h-12 ) \ 2
	this.CreateBuffer()
end constructor

property uiCheckBox.Label(value as string)
	if ( len(value) <> len(this._label) ) then 
		mutexlock(this._mutex)
		this._label = value
		mutexunlock(this._mutex)
	else
		mutexlock(this._mutex)
		this._label = value
		this._dimensions.w = 20 + len(value) * CAIRO_FONTWIDTH
		this.CreateBuffer()
		mutexunlock(this._mutex)
	end if
end property

property uiCheckBox.Label() as string
	return this._label
end property

property uiCheckBox.IsChecked(value as bool)
	mutexlock(this._mutex)
	this._isChecked = value
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiCheckBox.IsChecked() as bool
	return this._isChecked
end property

function uiCheckBox.Render() as  cairo_surface_t  ptr
	with this._dimensions
		cairo_set_source_surface(this._cairo, this._surface, .w, .h)
		cairo_set_source_rgba(this._cairo,&hE8/255,&hE8/255,&hE8/255,1)
		cairo_paint(this._cairo)
		DrawCheckbox(this._cairo, this._boxOffset, this._boxOffset, 12, this._isChecked)
		DrawLabel(this._cairo, 20, (.h - CAIRO_FONTSIZE)/2, this._label)
	end with
	return this._surface
end function

sub uiCheckBox.OnClick(mouse as UiMouseEvent)
	if ( mouse.lmb = released ) then
		dim as integer x, y, boxOffset
		
		with this._dimensions
			x = mouse.x - .x
			y = mouse.y - .y
			boxOffset =(.h-12)\2
		end with
		
		if ( x >= boxOffset ) AND ( x <= boxOffset +12 ) AND (y >= boxOffset) AND (y <= boxOffset +12) then
			mutexlock(this._mutex)
			this._IsChecked = not(this._IsChecked)
			mutexunlock(this._mutex)
			if ( this.callback <> 0 ) then
				this.callback(@this)
			end if
			this.Redraw()
		end if
	end if
end sub

sub uiCheckBox.OnKeyPress( keyPress as uiKeyEvent )
	if ( keyPress.key = " " ) then
		mutexlock(this._mutex)
		this._IsChecked = not(this._IsChecked)
		mutexunlock(this._mutex)
		if ( this.callback <> 0 ) then
			this.callback(@this)
		end if
		this.Redraw()
	end if
end sub

