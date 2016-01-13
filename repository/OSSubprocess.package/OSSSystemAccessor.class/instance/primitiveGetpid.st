general
primitiveGetpid

	^ self ffiCall: #( int getpid() )
	
