files - primitives
primitiveFdopen: aFileDescription mode: aMode
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin>
	^ self nbCall: #( OSSCFile fdopen(int aFileDescription, String aMode) )
	