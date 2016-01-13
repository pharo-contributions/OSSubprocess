close and dup2
getFdFromStream: aStream
	^ OSSSystemAccessor current fileno: aStream getFilePointerAsCFile