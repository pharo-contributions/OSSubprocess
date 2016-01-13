env - primitives
primitiveGetenv: variableName
	
	^ self ffiCall: #( char * getenv(char* variableName) )