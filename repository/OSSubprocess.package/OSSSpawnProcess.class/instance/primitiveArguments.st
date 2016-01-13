argv building
primitiveArguments
	| bufferPointer |
	bufferPointer := NativeBoost allocate: self primitiveShellArguments size * 4.
	self registerPointer: bufferPointer.
	self primitiveCollectArgumentPointersInto: bufferPointer.
	
	 ^ bufferPointer