helpers
numberOfOpenFiles
	"This is estimation number. Not to be used for real code. It's basically to check the number of opened FIFO files at the beginning of a test and at the end, to validate we are not leaving behind opened files.
	This should work in most Unix-like and Linux systems.
	Only FIFO files are checked as we can't control other threads, and it is redirecting stdio that is happening in the tests."
	| tmpFileName openFiles |
	tmpFileName := (FileSystem workingDirectory / 'openFilesByPharoVM-' , UUID new printString) fullName.
	tmpFileName asFileReference ensureDelete.
	self systemAccessor system: ('lsof -p ', OSSVMProcess vmProcess pid printString, ' > "', tmpFileName, '" 2>&1').
	openFiles := tmpFileName asFileReference readStreamDo: [ :str | | lines |
		lines := str contents lines.
		"Count only pipes"
		lines select: [ :each | each includesSubstring: 'FIFO' ]
	].
	tmpFileName asFileReference ensureDelete.
	^ openFiles size
