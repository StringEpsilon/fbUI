' uiTextbox.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015
#INCLUDE once "fbgfx.bi"
#include once "fbthread.bi"
#include once "../common/uiElement.bas"

type uiTextCurser
	position as integer
	SelectionStart as integer = -1
	SelectionEnd as integer = -1
	declare sub MoveTo(value as integer)
	declare sub MoveBy(value as integer)
end type


sub uiTextCurser.MoveTo(value as integer)
	if ( multikey(FB.SC_LSHIFT) ) then
		if (selectionStart = -1) then
			selectionStart = this.Position
			selectionEnd = value
		else
			selectionEnd = value
		end if
	else
		selectionStart = -1
		selectionEnd = -1
	end if
	this.Position = value
end sub

sub uiTextCurser.MoveBy(value as integer)
	if (this.Position + value < 0 ) then exit sub
	this.Position += value
	if ( multikey(FB.SC_LSHIFT) ) then
		if (selectionStart = -1) then
			selectionStart = this.Position -value
			selectionEnd = this.Position
		else
			selectionEnd = this.Position
		end if
	else
		selectionStart = -1
		selectionEnd = -1
	end if
end sub

type uiTextbox extends uiElement
	public: 
		declare constructor overload( x as integer, y as integer,length as integer, newText as string = "")
		declare constructor(dimensions as uiDimensions, newText as string = "")

		declare function Render() as fb.image  ptr
		declare virtual sub OnKeypress( keypress as uiKeyEvent )
		declare virtual sub OnClick( mouse as uiMouseEvent )
		
		declare property Text() as string
		declare property Text(value as string)
	private:
		dim as uiTextCurser _cursor
		dim as integer _boxOffset
		dim as string _Text
		dim as integer _length		
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

function uiTextbox.Render() as fb.image  ptr
	' Thanks to MuttonHead, extracted and refactored from sGUI_Drawing.bas
	dim as uinteger topleft,bottomright,ptopleft,pmiddle,pbottomright
	
	with this._dimensions	
		DrawTextbox(this._cairo,.w,.h)	
		if (this._hasFocus) then
			cairo_rectangle (this._cairo, 3+(this._cursor.Position*7), 0, 1, .h)
			cairo_set_source_rgb(this._cairo,0,0,0)
			cairo_fill(this._cairo)
			shell "echo selection from "& this._cursor.SelectionStart & " to " & this._cursor.SelectionEnd
		end if

		if (this._cursor.SelectionStart >= 1) then
			cairo_rectangle (this._cairo, (this._cursor.SelectionStart-1*7), 0, (this._cursor.SelectionEnd-this._cursor.SelectionStart )*7, .h)
			cairo_set_source_rgb(this._cairo,0.75,.75,.75)
			cairo_fill(this._cairo)
			'shell "echo selection from "& this._selection.first & " to " & this._selection.last
		end if
		
		DrawLabel(this._cairo,3, (.h - CAIRO_FONTSIZE)/2, this._text)
	end with
	return this._buffer
end function

sub uiTextbox.OnClick( mouse as uiMouseEvent )
	dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / 8
		
	if ( newCursor > len(this._text) ) then
		newCursor = len(this._text)
	end if
	if (newCursor <> this._cursor.Position ) then
		mutexlock(this._mutex)
		this._cursor.MoveTo(newCursor)
		mutexunlock(this._mutex)
		this.DoRedraw()
	end if
	
end sub

sub uiTextbox.OnKeypress( keypress as uiKeyEvent )
	mutexlock(this._mutex)
	if ( keypress.extended ) then
		' In this case, we got a 2 character key.
		select case keypress.keycode
			case 71 ' pos1 / home
				this._Cursor.MoveTo(0)
			case 79 ' end
				this._Cursor.MoveTo(len(this._text))
			case 75 ' Arrow left
				this._Cursor.MoveBy(-1)
			case 77 ' arrow right
				this._Cursor.MoveBy(+1)
			case 83 'Delete
				this._text = left(text, this._cursor.Position) + right (text, len(this._text) -this._cursor.Position -1)
			case else:
				shell "echo extended: " & keypress.keycode
		end select
	else
		select case keypress.keycode
			case 1 'ctrl + a
				this._cursor.MoveTo(0)
				this._cursor.SelectionStart = 0
				this._cursor.SelectionEnd = len(this._text)
			case 8 ' Backspace
				if (this._cursor.Position > 0) then
					if ( this._cursor.Position = len(this._text) ) then
						this._text = left(text, len(text)-1)
					else
						this._text = left(text, this._cursor.Position-1) + right (text, len(this._text) -this._cursor.Position )
					end if
					this._cursor.MoveBy(-1)
				end if
			case 9:
				
			case 13 ' Enter
				' Callback?
			case 32 to 127:
				if ( len(this._text) < this._length  ) then
					if ( this._cursor.Position = len(this._text) ) then
						this._Text += keypress.key
						
					else
						this._text = left(text, this._cursor.Position) + keypress.key + right (text, len(this._text) - this._cursor.Position )
					end if
					this._cursor.MoveBy(+1)
					this._cursor.SelectionStart = -1
				end if
			case else:
				shell "echo keycode: " & keypress.keycode
		end select
	end if
	mutexunlock(this._mutex)
	this.DoRedraw()
end sub
