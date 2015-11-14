' textbox.bas - StringEpsilon, 2015, WTFPL

namespace fbUI

#include once "../common/control.bas"

type uiTextBoxCursor
	position as integer = 0
	selectStart as integer = -1
	selectEnd as integer = -1
end type

type uiTextbox extends uiControl
	private:
		_selection as uiTextboxCursor
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

		declare function Render() as  fb.image  ptr
		declare virtual sub OnKeypress( keypress as uiKeyEvent )
		declare virtual sub OnClick( mouse as uiMouseEvent )
		declare virtual sub OnMouseMove( mouse as uiMouseEvent )
		
		declare property Value() as string
		declare property Value(value as string)

end type

constructor uiTextbox( x as integer, y as integer, w as integer, newText as string = "")
	base(x,y)
	
	this._dimensions.h = 14
	this._dimensions.w = w
	
	this._length = (w - 12) / FONT_WIDTH
	this._text = newText
	this.CreateBuffer()
end constructor

property uiTextbox.Value(newValue as string)
	if ( len(value) <> len(this._Text) ) then 
		this._Text = value
	else
		this._Text = value
		this.CreateBuffer()
	end if
	this.Redraw()
end property

property uiTextbox.Value() as string
	return this._Text
end property

sub uiTextbox.MoveTo(newValue as integer)
	with this._cursor
		if ( multikey(FB.SC_LSHIFT) ) then
			if ( .selectStart = -1) then
				.selectStart = .Position
				.selectEnd = newValue
			else
				.selectEnd = newValue
			end if
		else
			.selectStart = -1
			.selectEnd = -1
		end if
		.Position = newValue
		if (.Position - this._offset > this._length ) then
			this._offset = newValue -this._length
		elseif (.Position < this._offset) then
			this._offset = 0
		end if
	end with
end sub

sub uiTextbox.MoveBy(newValue as integer)
	with this._cursor
		if (.Position + newValue < 0 ) then exit sub
		if (.Position + newValue > len(this._text) ) then exit sub
		
		.Position += newValue
		if (.Position - this._offset > this._length  OR .Position - this._offset < 0) then
			this._offset += newValue
		end if
		if ( multikey(FB.SC_LSHIFT) ) then
			if (.selectStart = -1) then
				.selectStart = .Position - newValue
				.selectEnd = .Position
			else
				.selectEnd = .Position
			end if
		else
			.selectStart = -1
			.selectEnd = -1
		end if
	end with
end sub

sub uiTextbox.RemoveSelected()
	if this._cursor.selectStart > this._cursor.selectEnd then swap this._cursor.selectStart, this._cursor.selectEnd
	this._text = left(_text, this._cursor.selectStart) + right (_text, len(this._text) -this._cursor.selectEnd )
	this._cursor.Position = this._cursor.selectStart
	this._cursor.selectStart = -1
	this._cursor.selectEnd = -1
end sub

function uiTextbox.Render() as fb.image ptr
	if ( this._stateChanged ) then
		with this._dimensions
			line this._surface, (1, 1) - (.w-2, .h-2), ElementLight, BF
			line this._surface, (0, 0) - (.w-1, .h-1), ElementBorderColor, B
			if (len(this._text) <> 0) then
				if (this._cursor.selectStart >= 0 AND this._cursor.selectEnd >= 0) then
					IF (this._cursor.selectStart > this._cursor.selectEnd) then 
						this._selection.selectEnd = this._cursor.selectEnd
						this._selection.selectStart = this._cursor.selectStart
					else
						this._selection.selectStart = this._cursor.selectStart
						this._selection.selectEnd = this._cursor.selectEnd
					end if
					with this._selection
						line this._surface, ((.selectStart - _offset)  * FONT_WIDTH +2, 2) - ((.selectEnd - _offset) * FONT_WIDTH +2, this._dimensions.h-3), &hFFA0A0FF, BF
					end with
				else
					this._selection.selectStart = -1 
					this._selection.selectEnd = -1
				end if
				
				if (this._offset <> 0 ) then
					dim offsetText as string = mid(this._text, _offset+1, this._length)
					draw string this._surface, (3 ,(.h - FONT_HEIGHT)/2 ), offsetText,ElementTextColor
				else
					draw string this._surface, (3 ,(.h - FONT_HEIGHT)/2 ), this._text,ElementTextColor
				end if
			end if
			
			if (this._hasFocus) then			
				line this._surface, ((this._cursor.position - _offset)  * FONT_WIDTH +2, 2) - ((this._cursor.position- _offset) * FONT_WIDTH +2, .h-3), ElementBorderColor, 
			end if
		end with
	end if 
	return this._surface
end function

sub uiTextbox.OnClick( mouse as uiMouseEvent )
	if ( mouse.lmb = uiClick ) then
		
		dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / FONT_WIDTH + this._offset
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
		dim as integer newCursor = (mouse.x - this.dimensions.x - 3 ) / FONT_WIDTH + this._offset
		if ( newCursor > len(this._text) ) then
			newCursor = len(this._text)
		elseif newCursor < 0 then 
			newCursor = 0
		end if
		if ( this._cursor.selectStart <> -1  and this._cursor.selectStart <> newCursor) then
			this._cursor.selectEnd = newCursor
		else
			this._cursor.selectStart = this._cursor.Position
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
				if (this._cursor.selectStart <> -1) then
					this.RemoveSelected()
				else
					this._text = left(_text, this._cursor.Position) + right (_text, len(this._text) -this._cursor.Position -1)
				end if				
		end select
	else
		select case keypress.keycode
			case 1 'ctrl + a
				this.MoveTo(0)
				this._cursor.selectStart = 0
				this._cursor.selectEnd = len(this._text)
			case 8 ' Backspace
				if (this._cursor.selectStart <> -1) then
					this.RemoveSelected()
				else
					if (this._cursor.Position > 0) then
						if ( this._cursor.Position = len(this._text) ) then
							this._text = left(_text, len(_text)-1)
						else
							this._text = left(_text, this._cursor.Position-1) + right (_text, len(this._text) -this._cursor.Position )
						end if
						this.MoveBy(-1)
					end if
				end if
			case 9: 'tab
				
			case 13 ' Enter
				this.DoCallback()
			case 32 to 254:
				if (this._cursor.selectStart <> -1) then
					this.RemoveSelected()
				end if
				if ( len(this._text) < 255  ) then
					if ( this._cursor.Position = len(this._text) ) then
						this._Text += keypress.key
					else
						this._text = left(_text, this._cursor.Position) + keypress.key + right (_text, len(this._text) - this._cursor.Position )
					end if
					this.MoveBy(+1)
					this._cursor.selectStart = -1
				end if
			case else:
		end select
	end if
	mutexunlock(this._mutex)
	this.Redraw()
end sub

end namespace
