utilities
insertLineFeeds
	"(FileStream oldFileNamed: 'BBfix2.st') insertLineFeeds"
	| s crLf f |
	crLf := String crlf.
	s := self next: self size.
	self close.
	f := OldFileStream newFileNamed: self name.
	s linesDo: [:line | f nextPutAll: line; nextPutAll: crLf].
	f close