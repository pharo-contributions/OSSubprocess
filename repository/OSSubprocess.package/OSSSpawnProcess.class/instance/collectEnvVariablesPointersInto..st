env building
collectEnvVariablesPointersInto: aPointer

	envVariables keys withIndexDo: [ :aKey :index |
		| string pointer | 
		string := aKey trimmed , '=', (envVariables at: aKey) trimmed. 
		"The +1 is because string must be NULL terminated"
		pointer := ExternalAddress allocate: string size + 1.
		self registerPointer: pointer.
		LibC memCopy: string to: pointer size: string size.
		pointer nbUInt8AtOffset: string size put: 0. "string terminating null char"
		aPointer nbUInt32AtOffset: (index - 1) * 4 put: pointer value
	].
	"The array of pointers also needs to finish with a NULL"
	aPointer nbUInt32AtOffset: envVariables keys size * 4 put: 0
