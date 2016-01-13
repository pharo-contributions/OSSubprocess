private - primitives
primitiveClose: aFileDescription 
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin>
	^ self nbCall: #( int close(int aFileDescription) )
	