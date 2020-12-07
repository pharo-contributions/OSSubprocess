stdio
standardIOStreamNamed: moniker forWrite: forWrite
	"Create if necessary and store default stdin, stdout and other files based on the their names"
	
	| index |
	
	"This is an ugly hack, while waiting for a real fix for windows. There  several problems with this approach, but it allow us to run tests, etc."
	Smalltalk os isWin32 
		ifTrue: [ 
			[ ^ OldMultiByteFileStream forceNewFileNamed: moniker asString ]
			on: CannotDeleteFileException do: [
				"HACK: if the image is opened a second time windows barks about the already opened locked file"
				^ OldMultiByteFileStream forceNewFileNamed: moniker asString, '_', (Random new nextInt: SmallInteger maxVal) asString   ]]. 	
	
	index := #(stdin stdout stderr) identityIndexOf: moniker.
	^((StdioFiles ifNil: [ StdioFiles := Array new: 3 ]) at: index)
		ifNil: [
			StdioFiles
				at: index 
				put: (
					(TheStdioHandles at: index)
						ifNil: [ ^self error: moniker, ' is unavailable' ]
						ifNotNil: [ :handle |
							OldMultiByteFileStream newForStdio
								openOnHandle: handle
								name: moniker
								forWrite: forWrite ]) ]
