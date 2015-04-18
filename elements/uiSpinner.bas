' uiSpinner.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include once "fbthread.bi"
#include once "../common/uiElement.bas"

type uiSpinner extends uiElement
	private:
		_state as bool = false
		_currentFrame as integer = 1
		_d as integer
		_threadHandle as any ptr
		_exitAnimation as bool = false
	public:
		declare function Render() as cairo_surface_t  ptr
		
		declare constructor overload( x as integer, y as integer, d as integer)
		declare destructor()
		
		declare Property ThreadHandle(value as any ptr)
		declare property State() as bool
		declare property State(newState as bool)
		
		declare sub AnimationLoop()
end type

declare sub StartSpinnerAnimation(spinner as any ptr)

constructor uiSpinner( x as integer, y as integer,d as integer)
	base()	
	this._d = d
	with this._dimensions
		.h = d 
		.w = d
		.x = x
		.y = y
	end with
	this.CreateBuffer()
	this._threadHandle = ThreadCreate(@StartSpinnerAnimation,@this)
end constructor

destructor uiSpinner()
	mutexlock(this._mutex)
	this._state = false
	this._exitAnimation = true
	mutexunlock(this._mutex)
	threadwait(this._threadHandle)
end destructor

property uiSpinner.State(value as bool)
	mutexlock(this._mutex)
	this._state = value
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiSpinner.State() as bool
	return this._state
end property

sub uiSpinner.AnimationLoop()
	do
		if (this._state = true) then
			mutexlock(this._mutex)
			this._currentFrame += 5
			if this._currentFrame > 100 then
				this._currentFrame = 1
			end if
			mutexunlock(this._mutex)
			this.Redraw()
		end if
		sleep 50
	loop until this._exitAnimation
end sub

function uiSpinner.Render() as cairo_surface_t ptr
	with this._dimensions
		dim as double angle1 = this._currentFrame * (PI/50)
		dim as double angle2 = angle1 + 180.0 * (PI/180.0)
	
		cairo_save (this._cairo)
		cairo_set_source_rgba(this._cairo,0,0,0,0)
		cairo_set_operator (this._cairo, CAIRO_OPERATOR_SOURCE)
		cairo_paint(this._cairo)
		cairo_restore (this._cairo)
		cairo_set_source_rgb(this._cairo,0,0,0)
		cairo_set_line_width(this._cairo, cint(this._d/10))
		cairo_arc (this._cairo,(this._d/2), (this._d/2), this._d/2-(cint(this._d/10)), angle1, angle2)
		cairo_stroke(this._cairo)
		'DrawLabel(this._cairo, 2, (.h - CAIRO_FONTSIZE)/2, this._text)
		
	end with
	return this._surface
end function

sub StartSpinnerAnimation(element as any ptr)
	dim as uiSpinner ptr spinner = cast(uiSpinner ptr, element)
	spinner->AnimationLoop()
end sub
