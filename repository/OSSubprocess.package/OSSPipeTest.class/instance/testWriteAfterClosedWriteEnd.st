testing
testWriteAfterClosedWriteEnd
	| pipe writeStream readStream string readString |
	string := 'this is a testing string'. 
	pipe := OSSSystemAccessor current makePipe.
	writeStream := pipe openWriteStreamWithName: 'pipeWriter'.
	pipe closeWriteEnd.
	self should: [ writeStream nextPutAll: string; flush ] raise: Error.
	