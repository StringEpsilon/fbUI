' spinner.bas - StringEpsilon, 2015, WTFPL

namespace fbUI

#ifndef PI
const PI = 3.1415
#endif

#include once "../control.bas"

type uiSpinner extends uiControl
	private:
		_state as boolean = false
		_currentFrame as integer = 1
		_diameter as integer
		_threadHandle as any ptr
		_exitAnimation as boolean = false
	public:
		declare function Render() as fb.image  ptr
		
		declare constructor(byref json as jsonItem)
		declare constructor(x as integer, y as integer, d as integer)
		declare destructor()
		
		declare Property ThreadHandle(value as any ptr)
		declare property State() as boolean
		declare property State(newState as boolean)
		
		declare sub AnimationLoop()
end type

declare sub StartSpinnerAnimation(spinner as any ptr)

constructor uiSpinner(byref json as jsonItem)
	base(json)	
	this._diameter = cint(json["diameter"].value)
	with this._dimensions
		.h = this._diameter
		.w = this._diameter
	end with
	this.CreateBuffer()
	this._threadHandle = ThreadCreate(@StartSpinnerAnimation,@this)
end constructor

constructor uiSpinner( x as integer, y as integer,d as integer)
	base()	
	this._diameter = d
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

property uiSpinner.State(value as boolean)
	mutexlock(this._mutex)
	this._state = value
	mutexunlock(this._mutex)
	this.Redraw()
end property

property uiSpinner.State() as boolean
	return this._state
end property

sub uiSpinner.AnimationLoop()
	do
		if (this._state = true) then
			mutexlock(this._mutex)
			this._currentFrame += 2
			if this._currentFrame > 100 then
				this._currentFrame = 1
			end if
			mutexunlock(this._mutex)
			this.Redraw()
		end if
		sleep 1000/30
	loop until this._exitAnimation
end sub

function uiSpinner.Render() as fb.image ptr
	with this._dimensions
		dim as double angle1 = this._currentFrame * (PI/50)
		dim as double angle2 = angle1 + 180.0 * (PI/180.0)
		
		line this._surface, (0,0) - (.w, .h), BackGroundColor, BF
		circle this._surface, (.h/2, .h/2), _diameter / 2-1, ElementBorderColor, angle1, angle2
		circle this._surface, (.h/2, .h/2), _diameter / 2-2, ElementBorderColor, angle1, angle2
	end with
	return this._surface
end function

sub StartSpinnerAnimation(element as any ptr)
	dim as uiSpinner ptr spinner = cast(uiSpinner ptr, element)
	spinner->AnimationLoop()
end sub

end namespace
