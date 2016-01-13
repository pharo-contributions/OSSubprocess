reading
openReadStreamFor: aFileID withName: aReadStreamName
	reader := OSSAttachableFileStream name: aReadStreamName attachTo: aFileID writable: false.
	readBlocking ifFalse: [ reader setNonBlocking ].
	^ reader