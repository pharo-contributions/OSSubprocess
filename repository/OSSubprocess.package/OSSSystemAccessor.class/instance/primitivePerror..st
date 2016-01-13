errors - primitives
primitivePerror: anErrorString
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( void perror(String anErrorString) )
