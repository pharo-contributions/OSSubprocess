cwd
chdir: aDirString encoding: encoding
	"Changes the current working directory of the vmProcess to aDirString"
	| returnValue | 
	returnValue := self primitiveChdir: aDirString encoding: encoding.
	(returnValue = -1) ifTrue: [ self perror: 'chdir()' ].
	(returnValue = 0) ifFalse: [ self error: 'Unexpected return value from chdir() ', returnValue printString ].
	