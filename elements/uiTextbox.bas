' uiTextbox.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015
#INCLUDE once "fbgfx.bi"
#include once "fbthread.bi"
#include once "../common/uiElement.bas"

type uiTextCurser
	position as integer
	SelectionStart as integer = -1
	SelectionEnd as integer = -1
end type

type uiTextbox extends uiElement
	public: 
		declare constructor overload( x as integer, y as integer,length as integer, newText as string = "")
		declare constructor(dimensions as uiDimensions, newText as string = "")

		declare function Render() as fb.image  ptr
		declare virtual sub OnKeypress( keypress as uiKeyEvent )
		declare virtual sub OnClick( mouse as uiMouseEvent )
		declare virtual sub OnMouseMove( mouse as uiMouseEvent )
		
		declare property Text() as string
		declare property Text(value as string)
	private:
		dim as uiTextCurser _cursor
		dim as integer _boxOffset
		dim as string _Text
		dim as integer _length	
		
		declare sub MoveTo(value as integer)
		declare sub MoveBy(value as integer)	
		declare sub RemoveSelected()
end type

constructor uiTextbox( x as integer, y as integer, length as integer, newText as string = "")
	base(x,y)
	
	this._dimensions.h = 16
	this._dimensions.w = 12 + (length*7)
	
	this._length = length
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
		this._dimensions.w = 20 + len(value)*8
		this.CreateBuffer()
	end if
	this.DoRedraw()
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
	end with
end sub

sub uiTextbox.MoveBy(value as integer)
	with this._cursor
		if (.Position + value < 0 ) then exit sub
		if (.Position + value > len(this._text) ) then exit sub
		
		.Position += value
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

function uiTextbox.Render() as fb.image  ptr
	with this._dimensions	
		DrawTextbox(this._cairo,.w,.h)	
		if (this._hasFocus) then
			cairo_rectangle (this._cairo, 3+(this._cursor.Position*7), 0, 1, .h)
			cairo_set_source_rgb(this._cairo,0,0,0)
			cairo_fill(this._cairo)
			
			if (this._cursor.SelectionStart >= 0 AND this._cursor.SelectionEnd > 0) then
				cairo_rectangle (this._cairo, this._cursor.SelectionStart*7+3, 0, (this._cursor.SelectionEnd-this._cursor.SelectionStart)*7, .h)
				cairo_set_source_rgb(this._cairo,0.75,.75,.75)
				cairo_fill(this._cairo)
			end if
		end if
			
		DrawLabel(this._cairo,3, (.h - CAIRO_FONTSIZE)/2, this._text)
	end with
	return this._buffer
end function

sub uiTextbox.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = hit ) then
		dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / 7
		if ( newCursor > len(this._text) ) then
			newCursor = len(this._text)
		end if
		if (newCursor <> this._cursor.Position ) then
			mutexlock(this._mutex)
			this.MoveTo(newCursor)
			mutexunlock(this._mutex)
			this.DoRedraw()
		end if
	end if
end sub

sub uiTextbox.OnMouseMove( mouse as uiMouseEvent )
	if (mouse.lmb = hit and mouse.x <> -1 and mouse.y <> -1 ) then
		dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / 7
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
		this.DoRedraw()
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
			case else:
				shell "echo extended: " & keypress.keycode
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
				' Callback?
			case 32 to 127:
				if (this._cursor.SelectionStart <> -1) then
					this.RemoveSelected()
				end if
				if ( len(this._text) < this._length  ) then
					if ( this._cursor.Position = len(this._text) ) then
						this._Text += keypress.key
						
					else
						this._text = left(text, this._cursor.Position) + keypress.key + right (text, len(this._text) - this._cursor.Position )
					end if
					this.MoveBy(+1)
					this._cursor.SelectionStart = -1
				end if
		end select
	end if
	mutexunlock(this._mutex)
	this.DoRedraw()
end sub
