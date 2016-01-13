streams
createADefaultStream
	^ OSSSystemAccessor current makeNonBlockingPipe.
	