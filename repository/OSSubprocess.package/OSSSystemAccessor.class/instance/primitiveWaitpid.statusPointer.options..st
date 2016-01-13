waiting - primitives
primitiveWaitpid: aProcessId statusPointer: statusPointer options: optionBits
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin>
	^ self nbCall: #( int waitpid(int aProcessId, NBExternalAddress statusPointer, int optionBits) )