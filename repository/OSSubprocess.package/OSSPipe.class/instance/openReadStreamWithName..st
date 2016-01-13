reading
openReadStreamWithName: aReadStreamName
	| cFile |
	cFile := OSSSystemAccessor current fileDescriptorOpen: self readEndFileDescriptor mode: 'r'.
	readStream := OSSAttachableFileStream name: aReadStreamName attachTo: cFile writable: false.
	^ readStream