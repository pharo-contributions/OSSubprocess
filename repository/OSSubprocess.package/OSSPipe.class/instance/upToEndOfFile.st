accessing
upToEndOfFile
	"Answer the remaining elements in the pipe. Use #atEndOfFile to
	determine end of file status with feof(), required for reliable end of
	file test on OS pipes. Compare #upToEnd, which uses the generic end
	of file test in FilePlugin."

	| strm d s |
	strm := WriteStream on: String new.
	d := Delay forMilliseconds: 200.
	[(s := self next: 2000) isEmpty
		ifTrue: [self atEndOfFile
			ifTrue: [^ strm contents]
			ifFalse: [d wait]]
		ifFalse: [strm nextPutAll: s]] repeat
