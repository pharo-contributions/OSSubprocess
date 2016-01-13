private-primitives
primitivePopen: aCommandString mode: aMode
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( #OSSCFile popen(String aCommandString, String aMode) )
