temp files
createTempFileToBeUsedAsWriteStreamOn: aDirectoryPath
	
	^ (aDirectoryPath asFileReference / self createTempFilename) writeStream
	