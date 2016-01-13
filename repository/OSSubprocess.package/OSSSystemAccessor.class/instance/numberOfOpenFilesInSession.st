RANDOM
numberOfOpenFilesInSession
	| tmpFileName openFilesNumber |
	tmpFileName := '/tmp/openFilesByPharoVM-' , UUID new printString.
	tmpFileName asFileReference ensureDelete.
	Transcript show: tmpFileName; cr.
	OSSSystemAccessor current system: ('lsof -p ', self getVMPid printString, ' | wc -l  > ', tmpFileName, ' 2>&1').
	openFilesNumber := tmpFileName asFileReference readStreamDo: [ :str | str contents trimmed asNumber].
	^ openFilesNumber
	