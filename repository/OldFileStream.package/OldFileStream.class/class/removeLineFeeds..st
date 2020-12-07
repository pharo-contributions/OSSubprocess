file reader services
removeLineFeeds: fullName
	| fileContents |
	fileContents := ((OldFileStream readOnlyFileNamed: fullName) wantsLineEndConversion: true) contentsOfEntireFile.
	(OldFileStream newFileNamed: fullName) 
		nextPutAll: fileContents;
		close.