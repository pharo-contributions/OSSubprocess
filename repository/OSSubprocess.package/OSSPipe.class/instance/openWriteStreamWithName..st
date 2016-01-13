reading
openWriteStreamWithName: aWriteStreamName
	| cFile |
	cFile := OSSSystemAccessor current fileDescriptorOpen: self writeEndFileDescriptor mode: 'w'.
	writer := OSSAttachableFileStream name: aWriteStreamName attachTo: cFile writable: true.
	^ writer