files
fileDescriptorOpen: aFileDescription mode: aMode
	| cFile |
	cFile := self primitiveFdopen: aFileDescription mode: aMode.
	cFile ifNil: [ self perror: 'fdopen()' ].
	^ cFile
