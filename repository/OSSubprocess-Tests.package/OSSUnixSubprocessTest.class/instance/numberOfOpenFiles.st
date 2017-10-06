helpers
numberOfOpenFiles
	"This is estimation number. Not to be used for real code. IT's basically 
	to check the number of opened files (regular files, directories, pipes) at the beginning of a  test and at the end, to validate we are not leaving behind opened files. 
	This should work in most Unix-like and Linux
	"
	| tmpFileName openFiles |
	tmpFileName := (FileSystem workingDirectory / 'openFilesByPharoVM-' , UUID new printString) fullName.
	tmpFileName asFileReference ensureDelete.
	self systemAccessor system: ('lsof -p ', OSSVMProcess vmProcess pid printString, ' > "', tmpFileName, '" 2>&1').
	openFiles := tmpFileName asFileReference readStreamDo: [ :str |
		"The -1 is because the above command brings one line which is a header." 
		str contents lines allButFirst sorted
	].
	tmpFileName asFileReference ensureDelete.
	^ openFiles
	