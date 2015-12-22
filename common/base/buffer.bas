' buffer.bas - Do what the f... you want (WTFPL). 
' Author: StringEpsilon, 2015
' Like the hashtable, this is heavily inspired by mono / .net

#MACRO DeclareBuffer(datatype, buffername, CreateThreadSafe)

type ##buffername##
	private:
		#if CreateThreadSafe = true
		_mutex as any ptr
		#endif
		_array	 as datatype ptr
		_arraySize as uinteger
		_head	 as uinteger = 0
		_tail	 as uinteger = 0
		_size    as uinteger
		_version as uinteger
		
	public:
		declare destructor ()
		declare constructor overload ()
		declare constructor (initialCount as uinteger)
		
		declare function Contains(item as datatype) as boolean
		declare sub clear()
		declare function Pop () as datatype
		declare sub Push (element as datatype)
		
		declare sub SetCapacity (newSize as uinteger)
		
		declare property Count() as uinteger
		declare property Capacity() as uinteger
end type

constructor ##buffername##()
	#if CreateThreadSafe = true
	this._mutex = mutexcreate()
	#endif
	this._array = callocate(sizeof(datatype))
end constructor

constructor ##buffername##(initialCount as uinteger)
	#if CreateThreadSafe = true
	this._mutex = mutexcreate()
	#endif
	this._array = callocate(sizeof(datatype)*initialCount)
	this._arraySize = initialCount
end constructor

destructor ##buffername##()
	deallocate (this._array)
	#if CreateThreadSafe = true
	mutexdestroy(this._mutex)
	#endif
end destructor

sub ##buffername##.Clear()
	#if CreateThreadSafe = true
	mutexlock(this._mutex)
	#endif
	
	deallocate(this._array)
	this._head = this._tail = this._size = 0
	this._version += 1
	
	#if CreateThreadSafe = true
	mutexunlock(this._mutex)
	#endif
end sub

function ##buffername##.Pop() as datatype
	dim as datatype element
	if ( this._size > 0 ) then
		#if CreateThreadSafe = true
		mutexlock(this._mutex)
		#endif
		
		element = this._array[this._head]
		if (this._head + 1 =  this._arraySize) then
			this._head = 0
		else
			this._head +=1
		end if
		this._size -= 1
		this._version +=1
		
		#if CreateThreadSafe = true
		mutexunlock(this._mutex)
		#endif
	end if
	return element
end function

function ##buffername##.Contains(item as datatype) as boolean
	if (this._size = 0) then return false
	dim i as integer = 0
	while i < this._size
		if ( this._array[i] = item )  then return true
		i += 1
	wend
	return false
end function 

sub ##buffername##.Push(item as datatype)
	#if CreateThreadSafe = true
	mutexlock(this._mutex)
	#endif
	
	if (this._size = this._arraySize OR this._tail = this._arraySize) then
		this.SetCapacity(IIF(_size<_tail, _tail, _size)* 2)
	end if

	this._array[this._tail] = item
	
	if ( this._tail + 1 = this._arraySize ) then
		this._tail = 0
	else
		this._tail += 1
	end if
	this._size +=1
	this._version +=1
	#if CreateThreadSafe = true
	mutexunlock(this._mutex)
	#endif
end sub
				
sub ##buffername##.SetCapacity(newSize as uinteger)
	if ( newSize <= this._size) then
		exit sub
	end if
	this._arraySize = newSize
	this._array = reallocate(this._array ,sizeof(datatype)*this._arraySize)
	this._tail = _size
	this._head = 0
	this._version +=1
end sub
		
property ##buffername##.Count() as uinteger
	return this._size
end property

property ##buffername##.Capacity() as uinteger
	return this._arraySize
end property

#endmacro
