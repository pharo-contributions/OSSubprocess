closing
closeReadEnd
	OSSSystemAccessor current closeFileDescriptor: self readEndFileDescriptor.
	readStream ifNotNil: [ readStream close ]