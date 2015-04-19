#INCLUDE once "fbgfx.bi"
#include once "../common/uiElement.bas"

type uiTextBoxCursor
	position as integer = 0
	selectStart as integer = -1
	selectEnd as integer = -1
end type

type uiTextbox extends uiElement
	private:
		_layout as PangoLayout ptr
		_selection as PangoAttribute ptr
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
	this._layout = pango_cairo_create_layout (this._cairo)
	pango_layout_set_font_description (this._layout, desc)
	
	dim as PangoAttrList ptr list = pango_attr_list_new()
	this._selection = pango_attr_background_new(65535*.75,65535*.75,65535*.75)

	this._selection->start_index = -1 ' this._cursor.selectStart
	this._selection->end_index = -1' this._cursor.selectEnd

	pango_attr_list_insert (list,this._selection)

	pango_layout_set_attributes (this._layout, list)
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
			if ( .selectStart = -1) then
				.selectStart = .Position
				.selectEnd = value
			else
				.selectEnd = value
			end if
		else
			.selectStart = -1
			.selectEnd = -1
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
			if (.selectStart = -1) then
				.selectStart = .Position -value
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
	this._text = left(text, this._cursor.selectStart) + right (text, len(this._text) -this._cursor.selectEnd )
	this._cursor.Position = this._cursor.selectStart
	this._cursor.selectStart = -1
	this._cursor.selectEnd = -1
end sub

function uiTextbox.Render() as  cairo_surface_t  ptr
	with this._dimensions
		DrawTextbox(this._cairo,.w,.h)	
		cairo_set_source_rgb(this._cairo,0,0,0)
		if (len(this._text) <> 0) then
			if (this._offset <> 0 ) then
				dim offsetText as string = mid(this._text, _offset+1, this._length)
				pango_layout_set_text(this._layout, offsetText, -1)
			else
				pango_layout_set_text(this._layout, this._text, -1)
			end if
			if (this._hasFocus) then
				if (this._cursor.selectStart >= 0 AND this._cursor.selectEnd >= 0) then
					IF (this._cursor.selectStart > this._cursor.selectEnd) then 
						this._selection->start_index = this._cursor.selectEnd
						this._selection->end_index = this._cursor.selectStart
					else
						this._selection->start_index = this._cursor.selectStart
						this._selection->end_index = this._cursor.selectEnd
					end if
				else
					this._selection->start_index = -1 
					this._selection->end_index = -1
				end if
				pango_cairo_update_layout(this._cairo, this._layout)
				cairo_move_to(this._cairo,3,(.h - CAIRO_FONTSIZE)/2)
				pango_cairo_show_layout(this._cairo, this._layout)
				
				dim cursorRect as PangoRectangle ptr = new PangoRectangle
				pango_layout_get_cursor_pos(this._layout, this._cursor.position,cursorRect ,0)
				cairo_rectangle (this._cairo, 3 + cursorRect->x / PANGO_SCALE, cursorRect->y  / PANGO_SCALE, 1, cursorRect->height)
				cairo_fill(this._cairo)
			else
				pango_cairo_update_layout(this._cairo, this._layout)
				cairo_move_to(this._cairo,3,(.h - CAIRO_FONTSIZE)/2)
				pango_cairo_show_layout(this._cairo, this._layout)
			end if
		end if
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
					this._text = left(text, this._cursor.Position) + right (text, len(this._text) -this._cursor.Position -1)
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
							this._text = left(text, len(text)-1)
						else
							this._text = left(text, this._cursor.Position-1) + right (text, len(this._text) -this._cursor.Position )
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
						this._text = left(text, this._cursor.Position) + keypress.key + right (text, len(this._text) - this._cursor.Position )
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
