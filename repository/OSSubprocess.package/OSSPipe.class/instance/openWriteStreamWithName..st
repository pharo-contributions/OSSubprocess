reading
openWriteStreamWithName: aWriteStreamName
	| cFile |
	cFile := OSSSystemAccessor current fileDescriptorOpen: self writeEndFileDescriptor mode: 'w'.
	writeStream := OSSAttachableFileStream name: aWriteStreamName attachTo: cFile writable: true.
	^ writeStream