reading
openWriteStreamWithName: aWriteStreamName
	| cFile |
	cFile := self systemAccessor fileDescriptorOpen: self writeEndFileDescriptor mode: 'w'.
	writer := OSSAttachableFileStream name: aWriteStreamName attachTo: cFile writable: true.
	^ writer