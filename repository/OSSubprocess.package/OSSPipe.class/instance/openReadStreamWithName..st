reading
openReadStreamWithName: aReadStreamName
	| cFile |
	cFile := OSSSystemAccessor current fileDescriptorOpen: fileDescriptors first mode: 'r'.
	readStream := OSSAttachableFileStream name: aReadStreamName attachTo: cFile writable: false.
	^ readStream