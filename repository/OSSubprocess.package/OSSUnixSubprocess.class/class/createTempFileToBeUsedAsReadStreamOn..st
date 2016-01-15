temp files
createTempFileToBeUsedAsReadStreamOn: aDirectoryPath
	"This is a simple facility method if the user wants to use regular files rather than pipes.
	In the customization of defaultReadStreamCreationBlock: or defaultWriteStreamCreationBlock: 
	the user may want to use this method to automatically create a temp file on a aDirectoryPath.
	If you want another way of building temp files, then simply do not use this method and
	set the closure you want in defaultReadStreamCreationBlock: or defaultWriteStreamCreationBlock: 
	"
	^ (aDirectoryPath asFileReference / self createTempFilename) writeStream
	