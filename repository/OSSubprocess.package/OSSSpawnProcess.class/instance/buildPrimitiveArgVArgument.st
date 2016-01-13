argv building
buildPrimitiveArgVArgument
	| bufferPointer |
	bufferPointer := NativeBoost allocate: self argVArguments size * 4.
	self registerPointer: bufferPointer.
	self collectArgumentPointersInto: bufferPointer.
	 ^ bufferPointer