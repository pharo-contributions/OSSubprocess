testing
testIsAtEndOfFile

	| pipe |
	pipe := self nonBlockingPipe.

	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	self assert: (pipe reader basicNext == nil).
	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	pipe writer nextPut: $X; flush.
	self assert: (pipe reader basicNext == $X).
	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.
	self assert: (pipe reader basicNext == nil).
	self deny: (pipe reader atEndOfFile).
	self deny: pipe reader atEnd.
	self deny: pipe atEnd.

	pipe writer close.
	self deny: (pipe reader atEndOfFile).
	self deny: pipe atEndOfFile. "no read yet, so flag has not been set"
	
	"From Pharo 7 on, #atEnd does detect EOF on a pipe"
	SystemVersion current major <= 6
		ifTrue: [ self deny: pipe reader atEnd ]
		ifFalse: [ self assert: pipe reader atEnd ].

	self assert: pipe atEnd. "writer closed and read gives nil"

	self assert: (pipe reader basicNext == nil). "read operation should set flag"
	self assert: (pipe reader atEndOfFile).

	"From Pharo 7 on, #atEnd does detect EOF on a pipe"
	SystemVersion current major <= 6
		ifTrue: [ self deny: pipe reader atEnd ]
		ifFalse: [ self assert: pipe reader atEnd ].
	
	self assert: pipe reader atEndOfFile.
	self assert: pipe atEnd.
	pipe close
