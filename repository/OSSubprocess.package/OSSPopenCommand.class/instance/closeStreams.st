running
closeStreams
	| answer |
	answer := self primitivePclose: self getCFile.
	(answer = -1)
		ifTrue: [ 
			self primitivePerror: 'pclose()'.
			self error: 'Failed in pclose() call. You may want to check errors in stderr' ]
		ifFalse: [ self terminationStatus: answer ]