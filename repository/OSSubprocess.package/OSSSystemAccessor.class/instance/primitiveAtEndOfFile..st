files - primitives
primitiveAtEndOfFile: filePointer
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( int feof( #OSSCFile filePointer) )
