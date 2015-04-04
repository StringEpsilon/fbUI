' uiBaseElement.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015


#include once "cairo/cairo.bi"

#DEFINE RGBA_R(c) (CDBL((c) SHR 16 AND 255)/255)
#DEFINE RGBA_G(c) (CDBL((c) SHR  8 AND 255)/255)
#DEFINE RGBA_B(c) (CDBL((c)        AND 255)/255)
#DEFINE RGBA_A(c) (CDBL((c) SHR 24        )/255)

#ifndef bool
enum bool
	false = 0
	true = not false
end enum
#endif

const BackgroundColor = &hE8E8E8
const ElementLight = &hFFFFFF
const ElementDark = &hA0A0A0
const ElementTextColor = 0 ' Black
'const BackgroundColor = &hE8E8E8

const CAIRO_FONTSIZE = 12
Const PI = 3.14159265358979323846

sub DrawRadio(c as cairo_t ptr, x as double, y as double , radius as double, active as byte )
	dim as double cx, cy
	cx = x + radius
	cy = y + radius
	dim as uinteger col = ElementLight
	dim as uinteger col2 = ElementDark
	
	
	dim as cairo_pattern_t ptr pat

	pat = cairo_pattern_create_radial (cx,cy, radius-1.5, cx,  cy, radius)
	cairo_pattern_add_color_stop_rgba (pat, 0, RGBA_R(col),RGBA_G(col),RGBA_B(col), 1)
	cairo_pattern_add_color_stop_rgba (pat, 1, 0.1,0.1,0.1, 1)
	cairo_set_source (c, pat)
	cairo_arc (c, cx, cy, radius, 0, 2 * PI)
	cairo_fill (c)
	if ( active = -1 ) then
		cairo_set_source_rgb(c, RGBA_R(ElementTextColor),RGBA_G(ElementTextColor),RGBA_B(ElementTextColor))
		cairo_arc (c, cx, cy, radius-3, 0, 2 * PI)
		cairo_fill (c)
	end if
	cairo_pattern_destroy (pat)
end sub

sub DrawButton(c as cairo_t ptr,w as double,h as double,  invert as bool = false)
	'dim c as cairo_t ptr = cairo_create(surface)
	dim x as double = 0.5
	dim y as double = 0.5
	w = w - 1
	h = h - 1
	const as double aspect = 1.0
	const as double corner_radius = 2
	
	const as double radius = corner_radius / aspect
	const as double degrees = PI / 180.0

	dim as uinteger col = ElementLight
	dim as uinteger col2 = ElementDark 
	
	dim as cairo_pattern_t ptr pat = cairo_pattern_create_linear(x,y,x,y+w)
	if (invert = false ) then
		cairo_pattern_add_color_stop_rgb (pat,0,RGBA_R(col),RGBA_G(col),RGBA_B(col))
		cairo_pattern_add_color_stop_rgb (pat,0.3,RGBA_R(col2),RGBA_G(col2),RGBA_B(col2))
		cairo_pattern_add_color_stop_rgb (pat,1,RGBA_R(col),RGBA_G(col),RGBA_B(col))
	else
		cairo_pattern_add_color_stop_rgb (pat,0,RGBA_R(col2),RGBA_G(col2),RGBA_B(col2))
		cairo_pattern_add_color_stop_rgb (pat,0.6,RGBA_R(col),RGBA_G(col),RGBA_B(col))
		cairo_pattern_add_color_stop_rgb (pat,1,RGBA_R(col2),RGBA_G(col2),RGBA_B(col2))
	end if
	cairo_new_sub_path (c)
	cairo_set_source_rgba(c,1,1,1,1)
	cairo_fill(c)
	cairo_arc (c, x + w - radius, y + radius, radius, -90 * degrees, 0 * degrees)
	cairo_arc (c, x + w - radius, y + h - radius, radius, 0 * degrees, 90 * degrees)
	cairo_arc (c, x + radius, y + h - radius, radius, 90 * degrees, 180 * degrees)
	cairo_arc (c, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
	cairo_close_path (c)
	cairo_set_source (c, pat)
	cairo_fill_preserve (c)
	cairo_set_source_rgba (c, 0.1, 0.1, 0.1, 1)
	cairo_set_line_width (c, 1)
	cairo_stroke (c)
	cairo_pattern_destroy (pat)
end sub


sub DrawCheckbox(c as cairo_t ptr,x as double, y as double,size as double, checked as byte)
	const as double radius = 2 
	const as double degrees = PI / 180.0
	
	x = x + .5
	y = y + .5


	dim as uinteger col = ElementLight
	dim as uinteger col2 = ElementDark

	dim as cairo_pattern_t ptr pat = cairo_pattern_create_radial (x+size/2,y+size/2, size/2, x+size/2, y+size/2, radius)
	cairo_pattern_add_color_stop_rgb (pat,0,RGBA_R(col2),RGBA_G(col2),RGBA_B(col2))
	cairo_pattern_add_color_stop_rgb (pat,.7,RGBA_R(col), RGBA_G(col), RGBA_B(col))
	
	
	cairo_new_sub_path (c)
	cairo_set_source_rgba(c,1,1,1,1)
	cairo_fill(c)
	cairo_arc (c, x + size - radius, y + radius, radius, -90 * degrees, 0 * degrees)
	cairo_arc (c, x + size - radius, y + size - radius, radius, 0 * degrees, 90 * degrees)
	cairo_arc (c, x + radius, y + size - radius, radius, 90 * degrees, 180 * degrees)
	cairo_arc (c, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
	cairo_close_path (c)
	cairo_set_source (c, pat)
	cairo_fill_preserve (c)
	cairo_set_source_rgba (c, 0.1, 0.1, 0.1, 1)
	cairo_set_line_width (c, 1)
	cairo_stroke (c)
	cairo_pattern_destroy (pat)
	
	if checked then
		cairo_move_to(c,x+1,	y+size/2-1)
		cairo_line_to(c,x+size/3, 	y+size-2)
		cairo_line_to(c,x+size-.5, 	y+.5)
		cairo_set_source_rgba(c,0,0,0,1)
		cairo_set_line_join (c, CAIRO_LINE_JOIN_ROUND)
		cairo_set_line_width(c, 2)
		cairo_stroke (c)
	end if
end sub

sub DrawLabel(c as cairo_t ptr, x as double,y as double,text as string )
	cairo_set_source_rgb(c,0,0,0)
	cairo_move_to (c, x, y+CAIRO_FONTSIZE-2)
	cairo_show_text (c, text)
end sub

sub DrawTextbox(c as cairo_t ptr,w as double, h as double)
	dim as uinteger col = ElementLight
	dim as uinteger col2 = ElementDark
	dim as cairo_pattern_t ptr pat = cairo_pattern_create_linear(0,h,0,0)
	cairo_pattern_add_color_stop_rgb (pat,0,RGBA_R(col),RGBA_G(col),RGBA_B(col))
	cairo_pattern_add_color_stop_rgb (pat,1,RGBA_R(col2),RGBA_G(col2),RGBA_B(col2))
	
	w = w-1
	h = h-1
	
	cairo_rectangle (c, .5, .5, w, h)
	cairo_set_source_rgb(c,1,1,1)
	cairo_fill_preserve(c)
	
	
	cairo_set_source (c, pat)
	cairo_set_line_width (c, 1)
	cairo_stroke (c)
	
	cairo_pattern_destroy (pat)
end sub
