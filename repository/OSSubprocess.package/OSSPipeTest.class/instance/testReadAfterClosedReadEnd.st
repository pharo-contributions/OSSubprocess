testing
testReadAfterClosedReadEnd
	| pipe writeStream readStream string readString |
	string := 'this is a testing string'. 
	pipe := OSSSystemAccessor current makePipe.
	writeStream := pipe openWriteStreamWithName: 'pipeWriter'.
	writeStream nextPutAll: string; flush.
	readStream := pipe openReadStreamWithName: 'pipeReader'.
	pipe closeReadEnd.
	self assert: readStream closed.
	self should: [ readStream upToEndOfFile ] raise: Error.
	self should: [ readStream upToEnd ] raise: Error.
	