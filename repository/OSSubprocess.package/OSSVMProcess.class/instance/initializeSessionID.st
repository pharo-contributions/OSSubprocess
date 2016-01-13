initialize - release
initializeSessionID
	| oldFile | 
	oldFile := StandardFileStream oldFileNamed: Smalltalk image imagePath.
	currentSession := oldFile basicFileID copy first: 4.
	oldFile close.