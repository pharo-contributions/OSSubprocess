argv building
primitiveCollectArgumentPointersInto: aPointer
	self primitiveShellArguments allButLast withIndexDo: [ :string :index || pointer | "0 terminated"
		pointer := NativeBoost allocate: string size + 1.
		self registerPointer: pointer.
		NativeBoost memCopy: string to: pointer size: string size.
		pointer nbUInt8AtOffset: string size put: 0. "string terminating null char"
		aPointer nbUInt32AtOffset: (index - 1) * 4 put: pointer value ].
	
	aPointer nbUInt32AtOffset: (self primitiveShellArguments size - 1) * 4 put: 0