running
closeStreams
	| answer |
	answer := self primitivePclose: self getCFile.
	(answer = -1)
		ifTrue: [ self perror: 'pclose()'. ]
		ifFalse: [ self terminationStatus: answer ]