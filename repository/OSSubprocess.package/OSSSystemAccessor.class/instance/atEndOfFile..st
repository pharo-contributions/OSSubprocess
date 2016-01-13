files
atEndOfFile: aCFile
	| result |
	result := self primitiveAtEndOfFile: aCFile.
	^ result ~= 0
	
