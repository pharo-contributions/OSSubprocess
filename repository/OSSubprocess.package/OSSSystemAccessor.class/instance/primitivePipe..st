pipes - primitives
primitivePipe: pipePointer
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin>
	^ self nbCall: #( int pipe(NBExternalAddress pipePointer) )