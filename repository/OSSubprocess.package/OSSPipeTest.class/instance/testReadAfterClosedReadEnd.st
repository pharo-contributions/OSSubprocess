testing
testReadAfterClosedReadEnd
	| pipe writeStream readStream string |
	string := 'this is a testing string'. 
	pipe := self blockingPipe.
	writeStream := pipe openWriteStreamWithName: 'pipeWriter'.
	writeStream nextPutAll: string; flush.
	readStream := pipe openReadStreamWithName: 'pipeReader'.
	pipe closeReader.
	self assert: readStream closed.
	self should: [ readStream upToEndOfFile ] raise: Error.
	self should: [ readStream upToEnd ] raise: Error.
	