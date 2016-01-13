files - primitives
primitiveFflush: file
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( int fflush( #OSSCFile file) )
