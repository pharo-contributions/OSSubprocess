reading
openWriteStreamFor: aFileID withName: aWriteStreamName
	writer := OSSAttachableFileStream name: aWriteStreamName attachTo: aFileID writable: true.
	^ writer