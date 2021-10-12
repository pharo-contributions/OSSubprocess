cwd - primitives
primitiveChdir: aDirString encoding: encoding
	| encodingOption |
	encodingOption := #optStringEncoding , encoding.
	^ self 
		ffiCall: #( int chdir(String aDirString) )
		options: { #optStringEncodingMandatory . encodingOption }.