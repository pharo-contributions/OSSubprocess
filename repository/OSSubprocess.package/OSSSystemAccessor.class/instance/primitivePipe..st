pipes - primitives
primitivePipe: pipePointer
	
	^ self ffiCall: #( int pipe(void* pipePointer) )