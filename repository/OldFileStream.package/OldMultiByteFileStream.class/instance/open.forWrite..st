open/close
open: fileName forWrite: writeMode 
	| result |

	(writeMode and: [SessionManager default currentSession isReadOnlyAccessMode]) 
		ifTrue: [ ((CannotDeleteFileException fileName: fileName)
			messageText: 'Attempt to open file ' , fileName, ' as writable on read-only filesystem') signal. ].

	result := super open: fileName forWrite: writeMode.
	result ifNotNil: [
			converter ifNil: [self converter: UTF8TextConverter new].
			lineEndConvention ifNil: [ self detectLineEndConvention ]
	].
	^result