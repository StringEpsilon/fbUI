' Doppelt verkettete Liste, geschrieben in FreeBASIC
' (c) 2011 MilkFreeze
' Refactored by StringEpsilon, 2015.

#MACRO DeclareList(datatype, listname)

type ##listname##Element extends object
	previousElement as ##listname##Element ptr
	nextElement as ##listname##Element ptr
	element as datatype ptr

	declare constructor()
	declare destructor()
end type

constructor ##listname##Element()
   this.element = new datatype
end constructor

destructor ##listname##Element()
	delete this.nextElement
	delete this.element
	this.previousElement = 0
end destructor

TYPE ##listname##
	PRIVATE:
		_first as ##listname##Element ptr
		_last as ##listname##Element ptr
		_count as uinteger
		_lastAccessPtr as ##listname##Element ptr
		_lastAccessIndex as uinteger = -1

		declare function GetElement(index as uinteger) as  ##listname##Element ptr
	PUBLIC:
		declare property item(index as uinteger) as datatype
		declare property item(index as uinteger, value as datatype)

		declare sub append (newItem as datatype)
		declare sub insert (index as uinteger, newItem as datatype)
		declare sub remove (index as uinteger)

		declare function count () as uinteger

		declare constructor ()
		declare destructor ()

		declare operator LET (new_list as ##listname##)
end TYPE

Constructor ##listname##()
	this._count = 0
end constructor

destructor ##listname##()
	if (this._count <> 0) then
		delete this._first
		this._first = 0
		this._last  = 0
		this._count = 0
	end if
end destructor

function ##listname##.GetElement(index as uinteger) as ##listname##Element ptr
	if ( index <= 0 ) then return this._first
	dim p_tmp_item as ##listname##Element ptr
	dim i as integer
	if ( this._lastAccessIndex = index-1) then
		p_tmp_item =  this._lastAccessPtr->nextElement
	else
		if (index < (this._count-1) / 2) then
			i = 0
			p_tmp_item = this._first
			while (i < index)
				p_tmp_item = p_tmp_item->nextElement
				i += 1
			wend
		else
			i = this._count - 1
			p_tmp_item = this._last
			while (i > index)
				p_tmp_item = p_tmp_item->previousElement
				i -= 1
			wend
		end if
	end if
	this._lastAccessIndex = index
	this._lastAccessPtr = p_tmp_item
	return p_tmp_item
end function

sub ##listname##.remove (index as uinteger)
	if (index <= 0 OR index > this._count) then exit sub
	dim element as ##listname##Element ptr

	element = this.GetElement(index)
	'Special case for end of the list:
	if ( element->nextElement = 0 ) then
		this._last = element->previousElement
		this._last->nextElement = 0
	else
		element->nextElement->previousElement = element->previousElement
		if ( element->previousElement <> 0 ) then
			element->previousElement->nextElement = element->nextElement
		end if
	end if

	if ( index = 0 ) then
	_first = element->nextElement
	end if

	element->nextElement = 0
	delete element
	this._count -= 1
end sub

sub ##listname##.insert (index as uinteger, newItem as datatype)
	if (index >= this._count ) then
		this.append(newItem)
	elseif (index <= this._count AND index > 0 ) then
		dim nextElement as ##listname##Element ptr  =  this.GetElement(index)
		dim previousElement as ##listname##Element ptr = nextElement->previousElement
		
		dim newElement as ##listname##Element ptr = NEW ##listname##Element
		*(newElement->element) = newItem
		
		newElement->nextElement = nextElement
		nextElement->previousElement = newElement
		
		if ( index = 1 ) then
			this._first = newElement
		else
			previousElement->nextElement = newElement
			newElement->previousElement = previousElement
		end if

		this._count += 1
	end if
end sub

sub ##listname##.append(newItem as datatype)
	if (this._first = 0 ) then
		this._first = NEW ##listname##Element
		*this._first->element = newItem
		this._last = this._first
		this._last->previousElement = this._first
	elseif (_last <> 0) then
		this._last->nextElement = NEW ##listname##Element
		this._last->nextElement->previousElement = this._last
		this._last = this._last->nextElement
		*this._last->element = newItem
	end if
	_count += 1
end sub

property ##listname##.item(index as uinteger) as datatype
	return (*this.GetElement(index)->element)
end property

property ##listname##.item(index as uinteger, value as datatype)
	*this.GetElement(index)->element = value
end property

function ##listname##.count() as uinteger
	return this._count
end function

operator ##listname##.let(new_list as ##listname##)
	if (@this = @new_list OR new_list.count = 0) then exit operator
	dim i as integer
	this.destructor()
	
	for i as integer = 0 to new_list.count() -1
		this.append( new_list.item(i) )
	next
end operator

#endMACRO
