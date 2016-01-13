testing
testBasicWriteAndRead
	| pipe writeStream readStream string readString |
	string := 'this is a testing string'. 
	pipe := self blockingPipe.
	writeStream := pipe openWriteStreamWithName: 'pipeWriter'.
	readStream := pipe openReadStreamWithName: 'pipeReader'.
	writeStream nextPutAll: string; flush.
	readString := readStream next: string size.
	self assert: string equals: readString