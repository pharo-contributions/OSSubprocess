private-primitives
primitivePclose: file
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( int pclose(#OSSCFile file) )
