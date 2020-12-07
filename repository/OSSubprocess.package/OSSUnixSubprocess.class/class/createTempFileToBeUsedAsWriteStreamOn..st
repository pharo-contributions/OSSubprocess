temp files
createTempFileToBeUsedAsWriteStreamOn: aDirectoryPath
	"See comment of #createTempFileToBeUsedAsReadStreamOn:."
	^  OldStandardFileStream forceNewFileNamed: (aDirectoryPath asFileReference / self createTempFilename) fullName