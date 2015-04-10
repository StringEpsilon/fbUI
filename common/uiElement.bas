' uiElement.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "fbgfx.bi"
#include once "uiEvent.bi"
#include once "linkedlist.bas"
#include once "cairoHelper.bas"
#include once "uiBaseElement.bas"

type uiElement extends IRenderable
	private:
		_parent as IDrawing	ptr
	protected:
		_mutex as any ptr
		_buffer as fb.image ptr
		_isActive as bool = true
		_hasFocus as bool = false
		_surface as cairo_surface_t ptr 
		_cairo as cairo_t ptr
		_dimensions as uiDimensions
		
		declare constructor (x as integer, y as integer)
		declare virtual sub CreateBuffer()
		declare sub Redraw()
	public:
		Callback as sub(payload as any ptr)
		declare property Dimensions () as uiDimensions ' Part of IRenderable
		declare property Parent(value as IDrawing ptr)
		
		declare destructor()
		declare constructor(dimensions as uiDimensions)
		declare constructor overload()
		
		declare virtual sub OnClick(mouse as uiMouseEvent)
		declare virtual sub OnKeypress(keypress as uiKeyEvent)
		declare virtual sub OnMouseMove(mouse as uiMouseEvent)
		declare virtual sub OnFocus(focus as bool)
end type

declareList(uiElement ptr, uiElementList)

constructor uiElement()
	this._mutex = mutexCreate()
end constructor 

constructor uiElement(x as integer, y as integer)
	this.constructor()
	this._dimensions.x = x
	this._dimensions.y = y
end constructor 

constructor uiElement(newDimensions as uiDimensions)
	this.constructor()
	this._dimensions = newDimensions
end constructor 


Destructor uiElement()
	if (this._mutex <> 0 ) then
		mutexdestroy(this._mutex)
		this._mutex = 0
	end if
	if (this._buffer <> 0 ) then
		imagedestroy(this._buffer)
		this._buffer = 0
	end if
	cairo_surface_destroy (this._surface)
	cairo_destroy(this._cairo)
end destructor

property uiElement.Dimensions() as uiDimensions
	return this._dimensions
end property

property uiElement.Parent(value as IDrawing ptr)
	mutexlock(this._mutex)
	this._parent = value
	mutexunlock(this._mutex)
end property

sub uiElement.Redraw()
		this._parent->DrawElement(@this)		
end sub

sub UiElement.OnClick(mouse as uiMouseEvent)
end sub

sub UiElement.OnMouseMove(mouse as uiMouseEvent)
end sub

sub UiElement.OnKeypress(keypress as uiKeyEvent)
end sub

sub UiElement.OnFocus(focus as bool)
	mutexlock(this._mutex)
	this._hasFocus = focus
	mutexunlock(this._mutex)
	this.Redraw()
end sub

sub uiElement.CreateBuffer()
	if (this._buffer <> 0) then
		ImageDestroy(this._buffer)
	end if
	this._buffer = IMAGECREATE(this._dimensions.w,this._dimensions.h,&h00000000)
	if (this._buffer = 0) then	
		exit sub
	end if
	if ( this._cairo <> 0) then
		cairo_destroy(this._cairo)
		cairo_surface_destroy(this._surface)
	end if

	this._surface = cairo_image_surface_create_for_data(cast(any ptr,this._buffer)+32, CAIRO_FORMAT_ARGB32, this._dimensions.w, this._dimensions.h, this._buffer->pitch)
	this._cairo = cairo_create(this._surface)
	cairo_select_font_face (this._cairo , "mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (this._cairo , CAIRO_FONTSIZE)
end sub
