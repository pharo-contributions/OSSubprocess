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
	openFiles := tmpFileName asFileReference readStreamDo: [ :str | | lines |
		"We avoid the first header line" 
		lines := str contents lines allButFirst sorted.
		lines collect: [ :each | | fields |
			fields := each substrings.
			"We ignore the 7th field of lsof: SIZE/OFF.
			Size of an open file may change during test. We only care about open files."
			Character space join: ((fields first: 6), (fields last: 2))  ]
	].
	tmpFileName asFileReference ensureDelete.
	^ openFiles
	