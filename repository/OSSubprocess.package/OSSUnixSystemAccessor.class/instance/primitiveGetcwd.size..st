cwd - primitives
primitiveGetcwd: buffer size: size
	
	^ self ffiCall: #( String getcwd(char *buffer, int size) )
	