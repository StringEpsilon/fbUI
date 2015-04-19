' uiTextbox.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015
#INCLUDE once "fbgfx.bi"
#include once "fbthread.bi"
#include once "../common/uiElement.bas"

type uiTextBoxCursor
	position as integer
	SelectionStart as integer = -1
	SelectionEnd as integer = -1
end type

type uiTextbox extends uiElement
	private:
		dim as uiTextBoxCursor _cursor
		dim as integer _boxOffset
		dim as string _Text
		dim as integer _length	
		dim as integer _offset = 0
		
		declare sub MoveTo(value as integer)
		declare sub MoveBy(value as integer)	
		declare sub RemoveSelected()
	public: 
		declare constructor overload( x as integer, y as integer,length as integer, newText as string = "")
		declare constructor(dimensions as uiDimensions, newText as string = "")

		declare function Render() as  cairo_surface_t  ptr
		declare virtual sub OnKeypress( keypress as uiKeyEvent )
		declare virtual sub OnClick( mouse as uiMouseEvent )
		declare virtual sub OnMouseMove( mouse as uiMouseEvent )
		
		declare property Text() as string
		declare property Text(value as string)

end type

constructor uiTextbox( x as integer, y as integer, w as integer, newText as string = "")
	base(x,y)
	
	this._dimensions.h = 16
	this._dimensions.w = w
	
	this._length = (w - 12) / CAIRO_FONTWIDTH
	this._text = newText
	this.CreateBuffer()
end constructor

constructor uiTextbox(newdim as uiDimensions, newText as string = "")
	base(newdim)
	
	this._boxOffset = ( this._dimensions.h-12 ) \ 2
	this.CreateBuffer()
end constructor

property uiTextbox.Text(value as string)
	if ( len(value) <> len(this._Text) ) then 
		this._Text = value
	else
		this._Text = value
		this.CreateBuffer()
	end if
	this.Redraw()
end property

property uiTextbox.Text() as string
	return this._Text
end property

sub uiTextbox.MoveTo(value as integer)
	with this._cursor
		if ( multikey(FB.SC_LSHIFT) ) then
			if ( .selectionStart = -1) then
				.selectionStart = .Position
				.selectionEnd = value
			else
				.selectionEnd = value
			end if
		else
			.selectionStart = -1
			.selectionEnd = -1
		end if
		.Position = value
		if (.Position - this._offset > this._length ) then
			this._offset = value -this._length
		elseif (.Position < this._offset) then
			this._offset = 0
		end if
	end with
end sub

sub uiTextbox.MoveBy(value as integer)
	with this._cursor
		if (.Position + value < 0 ) then exit sub
		if (.Position + value > len(this._text) ) then exit sub
		
		.Position += value
		if (.Position - this._offset > this._length  OR .Position - this._offset < 0) then
			this._offset += value
		end if
		if ( multikey(FB.SC_LSHIFT) ) then
			if (.selectionStart = -1) then
				.selectionStart = .Position -value
				.selectionEnd = .Position
			else
				.selectionEnd = .Position
			end if
		else
			.selectionStart = -1
			.selectionEnd = -1
		end if
	end with
end sub

sub uiTextbox.RemoveSelected()
	if this._cursor.SelectionStart > this._cursor.SelectionEnd then swap this._cursor.SelectionStart, this._cursor.SelectionEnd
	this._text = left(text, this._cursor.SelectionStart) + right (text, len(this._text) -this._cursor.SelectionEnd )
	this._cursor.Position = this._cursor.selectionStart
	this._cursor.SelectionStart = -1
	this._cursor.SelectionEnd = -1
end sub

function uiTextbox.Render() as  cairo_surface_t  ptr
	with this._dimensions
		cairo_rectangle (this._cairo, 0, 0, .w, .h)
		cairo_set_source_rgb(this._cairo,1,1,1)
		cairo_fill(this._cairo)
			
		if (this._hasFocus) then
			if (this._cursor.SelectionStart >= 0 AND this._cursor.SelectionEnd >= 0) then
				dim as integer selectionX, selectionWidth
				selectionX = (this._cursor.SelectionStart - this._offset) * CAIRO_FONTWIDTH
				selectionWidth = (this._cursor.SelectionEnd - this._offset) * CAIRO_FONTWIDTH -selectionX
				
				cairo_rectangle (this._cairo, selectionX+3, 1, selectionWidth, .h-2)
				cairo_set_source_rgb(this._cairo,0.75,.75,.75)
				cairo_fill(this._cairo)
			end if
			cairo_rectangle (this._cairo, 3 +(this._cursor.Position-this._offset)*CAIRO_FONTWIDTH, 1, 1, .h-2)
			cairo_set_source_rgb(this._cairo,0,0,0)
			cairo_fill(this._cairo)
		end if
		
		if (len(this._text) <> 0) then
			if (this._offset <> 0 ) then
				dim offsetText as string = mid(this._text, _offset+1, this._length)
				DrawLabel(this._cairo,3, (.h - CAIRO_FONTSIZE)/2, offsetText)
			else
				DrawLabel(this._cairo,3, (.h - CAIRO_FONTSIZE)/2, this._text)
			end if
		end if
		DrawTextbox(this._cairo,.w,.h)			
	end with
	return this._surface
end function

sub uiTextbox.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = uiClick ) then
		dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / CAIRO_FONTWIDTH +this._offset
		if ( newCursor > len(this._text) ) then
			newCursor = len(this._text)
		end if
		if (newCursor <> this._cursor.Position ) then
			mutexlock(this._mutex)
			this.MoveTo(newCursor)
			mutexunlock(this._mutex)
			this.Redraw()
		end if
	end if
end sub

sub uiTextbox.OnMouseMove( mouse as uiMouseEvent )
	if (mouse.lmb = uiHold and mouse.x <> -1 and mouse.y <> -1 ) then
		dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / CAIRO_FONTWIDTH + this._offset
		if ( newCursor > len(this._text) ) then
			newCursor = len(this._text)
		elseif newCursor < 0 then 
			newCursor = 0
		end if
		if ( this._cursor.selectionStart <> -1  and this._cursor.selectionStart <> newCursor) then
			this._cursor.selectionEnd = newCursor
		else
			this._cursor.selectionStart = this._cursor.Position
		end if
		this.Redraw()
	end if
end sub


sub uiTextbox.OnKeypress( keypress as uiKeyEvent )
	mutexlock(this._mutex)
	if ( keypress.extended ) then
		' In this case, we got a 2 character key.
		select case keypress.keycode
			case 71 ' pos1 / home
				this.MoveTo(0)
			case 79 ' end
				this.MoveTo(len(this._text))
			case 75 ' Arrow left
				this.MoveBy(-1)
			case 77 ' arrow right
				this.MoveBy(+1)
			case 83 'Delete
				if (this._cursor.SelectionStart <> -1) then
					this.RemoveSelected()
				else
					this._text = left(text, this._cursor.Position) + right (text, len(this._text) -this._cursor.Position -1)
				end if				
		end select
	else
		select case keypress.keycode
			case 1 'ctrl + a
				this.MoveTo(0)
				this._cursor.SelectionStart = 0
				this._cursor.SelectionEnd = len(this._text)
			case 8 ' Backspace
				if (this._cursor.SelectionStart <> -1) then
					this.RemoveSelected()
				else
					if (this._cursor.Position > 0) then
						if ( this._cursor.Position = len(this._text) ) then
							this._text = left(text, len(text)-1)
						else
							this._text = left(text, this._cursor.Position-1) + right (text, len(this._text) -this._cursor.Position )
						end if
						this.MoveBy(-1)
					end if
				end if
			case 9:
				
			case 13 ' Enter
				if ( this.callback <> 0 ) then
					this.callback(@this)
				end if
			case 32 to 254:
				if (this._cursor.SelectionStart <> -1) then
					this.RemoveSelected()
				end if
				if ( len(this._text) < 255  ) then
					if ( this._cursor.Position = len(this._text) ) then
						this._Text += keypress.key
						
					else
						this._text = left(text, this._cursor.Position) + keypress.key + right (text, len(this._text) - this._cursor.Position )
					end if
					this.MoveBy(+1)
					this._cursor.SelectionStart = -1
				end if
			case else:
		end select
	end if
	mutexunlock(this._mutex)
	this.Redraw()
end sub
