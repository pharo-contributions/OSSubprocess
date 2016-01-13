attaching
name: aSymbolOrString attachTo: aFileID writable: readWriteFlag

	name := aSymbolOrString.
	fileID := aFileID.
	readWriteFlag ifTrue: [self readWrite] ifFalse: [self readOnly].
	self ascii.self register

