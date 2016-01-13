files
closeFileDescriptor: aFileDescription
	| returnValue |
	returnValue := self primitiveClose: aFileDescription.
	(returnValue = -1) ifTrue:  [ self perror: 'close()' ].
	^ returnValue
