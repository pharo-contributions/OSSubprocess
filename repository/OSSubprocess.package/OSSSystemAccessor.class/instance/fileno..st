files
fileno: aCFile

	| returnValue |
	returnValue := self primitiveFileno: aCFile.
	(returnValue = -1) ifTrue: [ self perror: 'fileno()' ].
	^ returnValue "file descriptor"