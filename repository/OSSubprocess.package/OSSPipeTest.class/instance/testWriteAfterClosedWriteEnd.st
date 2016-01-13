testing
testWriteAfterClosedWriteEnd
	| pipe writeStream string |
	string := 'this is a testing string'. 
	pipe := self blockingPipe.
	writeStream := pipe openWriteStreamWithName: 'pipeWriter'.
	pipe closeWriter.
	self should: [ writeStream nextPutAll: string; flush ] raise: Error.
	