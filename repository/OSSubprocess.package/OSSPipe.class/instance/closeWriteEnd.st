closing
closeWriteEnd
	OSSSystemAccessor current closeFileDescriptor: self writeEndFileDescriptor.
	writeStream ifNotNil: [ writeStream close ]