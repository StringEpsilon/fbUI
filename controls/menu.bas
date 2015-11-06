' menu.bas - StringEpsilon, 2015, WTFPL

#include once "menuItem.bas"

namespace fbUI

#include once "../common/controlContainer.bas"

type uiMenu extends uiControlContainer
	public:
		declare function Render() as fb.image ptr
		Callback as sub(payload as any ptr)
		
		declare destructor()
		declare constructor(h as integer, w as integer, list() as string)
				
		declare sub OnClick(mouse as uiMouseEvent)
		declare sub OnKeypress(keypress as uiKeyEvent)
		declare sub OnMouseMove(mouse as uiMouseEvent)
end type

constructor uiMenu(h as integer, w as integer, list() as string)
	base(0,0)
	this._dimensions.h = h
	this._dimensions.w = w
	
	dim child as uiMenuItem ptr 
	dim yOffset as integer
	for i as integer = 0 to ubound(list)
		child = new uiMenuItem(list(i))
		child->dimensions.x = yOffset
		shell "echo "& yOffset & " . " & child->dimensions.x
		yOffset += child->dimensions.w
		child->Parent = @this
		this._children->Append(child)
	next
	this.CreateBuffer()
end constructor 

Destructor uiMenu()
	base.Destructor()
	delete this._children
end destructor


sub uiMenu.OnClick(mouse as uiMouseEvent)
	mouse.x = mouse.x - this.dimensions.x
	mouse.y = mouse.y - this.dimensions.y
	
	dim uiClickedElement as uiControl ptr = this.GetElementAt(mouse.x, mouse.y)
	if ( uiClickedElement <> 0 ) then
		if (this._focus <> uiClickedElement) then
			if (this._focus <> 0 ) then
				this._focus->OnFocus(false)
			end if
			mutexlock(this._mutex)
			this._focus = uiClickedElement
			mutexunlock(this._mutex)
			this._focus->OnFocus(true)
		end if
		uiClickedElement->OnClick(mouse)
	elseif (this._focus <> 0) then
		this._focus->OnFocus(false)
		mutexlock(this._mutex)
		this._focus = 0
		mutexunlock(this._mutex)
	end if
end sub

sub uiMenu.OnMouseMove(mouse as uiMouseEvent)
	mouse.x = mouse.x - this.dimensions.x
	mouse.y = mouse.y - this.dimensions.y
	if ( this._focus <> 0 ) then
		this._focus->OnMouseMove(mouse)
	end if
end sub

sub uiMenu.OnKeypress(keypress as uiKeyEvent)
	if (this._focus <> 0) then
		this._focus->OnKeyPress(keypress)
	end if
end sub

function uiMenu.Render() as fb.image ptr
	if ( this._stateChanged ) then
		dim element as uiControl ptr
		dim as integer offset = 1
		with this.dimensions
			line this._surface, (1, 1) - (.w-2, .h-2), ElementLight, BF
			line this._surface, (0, 0) - (.w-1, .h-1), ElementBorderColor, B
			
			for i as integer = 1 to this._children->count()-1
				element = this._children->item(i)
				with element->dimensions
					put this._surface, (.x,.w), element->render(), ALPHA
				end with
			next
		end with
		'put this._surface, (this._scrollbar->dimensions.x, this._scrollbar->dimensions.y),this._scrollbar->Render(),ALPHA
	end if
	return this._surface
end function

end namespace
