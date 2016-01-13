private-primitives
primitivePclose: file
	
	^ self ffiCall: #( int pclose(OSSCFile file) )
