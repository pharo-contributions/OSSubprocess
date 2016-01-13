accessing
upToEnd
	"Answer the remaining elements in the string. This method is retained for backward
	compatibility with older versions of CommandShell."

	| strm s |
	strm := WriteStream on: String new.
	[(s := self next: 2000) isEmpty
		ifTrue: [^ strm contents]
		ifFalse: [strm nextPutAll: s]] repeat
