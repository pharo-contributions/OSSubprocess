pipes
createADefaultPipe
	^ OSSSystemAccessor current makeNoneBlockingReadPipe.
	