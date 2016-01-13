files - primitives
primitiveAtEndOfFile: filePointer

	^ self ffiCall: #( int feof( OSSCFile filePointer) )
