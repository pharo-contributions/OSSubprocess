private-primitives
primitiveGetdtablesize
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( int getdtablesize(void) )

