USING FROM OSPROCESS
makeFileNoneBocking: aFileId

	self primSQFileSetNonBlocking: aFileId
