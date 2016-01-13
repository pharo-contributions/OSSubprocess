system
system: aCommandString
	| returnValue |
	returnValue := self primitiveSystem: aCommandString.
	(returnValue = -1) ifTrue: [ 
		self perror: 'system()'	
	].
	^ returnValue 