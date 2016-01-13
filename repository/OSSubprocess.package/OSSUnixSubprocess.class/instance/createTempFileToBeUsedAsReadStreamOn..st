temp files
createTempFileToBeUsedAsReadStreamOn: aDirectoryPath
	
	^ (aDirectoryPath asFileReference / self createTempFilename) writeStream
	