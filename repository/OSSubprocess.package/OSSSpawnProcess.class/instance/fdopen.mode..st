files
fdopen: aFileDescription mode: aMode
	| cFile |
	cFile := self primitiveFdopen: aFileDescription mode: aMode.
	cFile ifNil: [ 
		self primitivePerror: 'fdopen()'.
		self error: 'Failed in fdopen() call. You may want to check errors in stderr'
	].
	^ cFile
