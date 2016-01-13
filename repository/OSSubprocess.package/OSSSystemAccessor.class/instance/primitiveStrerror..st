errors - primitives
primitiveStrerror: errorNumber
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( String strerror( int errorNumber) )
