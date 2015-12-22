' IDrawing.bi - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015

#include "IRenderable.bi"

type IDrawing extends object
	declare abstract sub DrawElement( element as IRenderable ptr)
end type
