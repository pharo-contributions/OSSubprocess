temp files
createTempFileToBeUsedAsWriteStreamOn: aDirectoryPath
	"See comment of #createTempFileToBeUsedAsReadStreamOn:"
	^ (aDirectoryPath asFileReference / self createTempFilename) writeStream
	