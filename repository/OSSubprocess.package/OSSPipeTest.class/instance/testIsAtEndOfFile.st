testing
testIsAtEndOfFile

	| pipe |
	pipe := self nonBlockingPipe.
	self primTestEndOfFileFlag: pipe reader fileID. "check that OSPP is updated"
	self deny: (OSProcess accessor isAtEndOfFile: pipe reader fileID).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	self assert: (pipe reader basicNext == nil).
	self deny: (OSProcess accessor isAtEndOfFile: pipe reader fileID).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	pipe writer nextPut: $X; flush.
	self assert: (pipe reader basicNext == $X).
	self deny: (OSProcess accessor isAtEndOfFile: pipe reader fileID).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	self assert: (pipe reader basicNext == nil).
	self deny: (OSProcess accessor isAtEndOfFile: pipe reader fileID).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.

	pipe writer close.
	self deny: (OSProcess accessor isAtEndOfFile: pipe reader fileID).
	self deny: pipe atEndOfFile. "no read yet, so flag has not been set"
	self deny: pipe reader atEnd.
	self assert: pipe atEnd. "writer closed and read gives nil"

	self assert: (pipe reader basicNext == nil). "read operation should set flag"
	self assert: (OSProcess accessor isAtEndOfFile: pipe reader fileID).
	self deny: pipe reader atEnd. "#atEnd does not detect EOF on a pipe"
	self assert: pipe reader atEndOfFile.
	self assert: pipe atEnd.
	pipe close
