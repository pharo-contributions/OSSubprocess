cwd
chdir: aDirString
	| returnValue | 
	returnValue := self primitiveChdir: aDirString.
	(returnValue = -1) ifTrue: [ self perror: 'chdir()' ].
	(returnValue = 0) ifFalse: [ self error: 'Unexpected return value from chdir() ', returnValue printString ].
	