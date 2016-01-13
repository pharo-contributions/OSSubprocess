reading
openReadStreamWithName: aReadStreamName
	| cFile |
	cFile := self systemAccessor fileDescriptorOpen: self readEndFileDescriptor mode: 'r'.
	reader := OSSAttachableFileStream name: aReadStreamName attachTo: cFile writable: false.
	readBlocking ifFalse: [ reader setNonBlocking ].
	^ reader