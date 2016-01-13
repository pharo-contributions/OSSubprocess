argv building
buildPrimitiveArgVArgument
	| bufferPointer |
	bufferPointer := ExternalAddress allocate: self argVArguments size * 4.
	self registerPointer: bufferPointer.
	self collectArgumentPointersInto: bufferPointer.
	 ^ bufferPointer