argv building
collectArgumentPointersInto: aPointer
	"Allocates each string argument with a null terminated char and add them into aPointer"
	
	"#allButLast is because the last is 0."
	self argVArguments allButLast withIndexDo: [ :string :index |
		| pointer | "0 terminated"
		pointer := ExternalAddress allocate: string size + 1.
		self registerPointer: pointer.
		LibC memCopy: string to: pointer size: string size.
		pointer nbUInt8AtOffset: string size put: 0. "string terminating null char"
		aPointer platformUnsignedLongAt: ((index - 1) * self systemAccessor sizeOfPointer) + 1 put: pointer value ].

	aPointer platformUnsignedLongAt: ((self argVArguments size - 1) * self systemAccessor sizeOfPointer) + 1 put: 0.