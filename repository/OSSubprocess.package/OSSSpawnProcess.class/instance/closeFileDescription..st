files
closeFileDescription: aFileDescription
	| returnValue |
	returnValue := self primitiveClose: aFileDescription.
	(returnValue = -1) ifTrue:  [ 
		self primitivePerror: 'close()'.
		self error: 'Failed in close() call. You may want to check errors in stderr'
	].
	^ returnValue
