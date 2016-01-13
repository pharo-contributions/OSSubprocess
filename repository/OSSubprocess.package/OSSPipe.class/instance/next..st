accessing
next: anInteger 
	"Answer the next anInteger elements of my collection."

	| c strm |
	strm := WriteStream on: String new.
	(1 to: anInteger) do:
		[:index |
		c := self next.
		c isNil
			ifTrue: [^ strm contents]	
			ifFalse: [strm nextPut: c. false]].
	^ strm contents
