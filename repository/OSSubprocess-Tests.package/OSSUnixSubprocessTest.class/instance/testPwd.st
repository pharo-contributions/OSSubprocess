tests - pwd
testPwd
	| oldLs newLs | 
	
	self newCommand
		command: '/bin/ls';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			oldLs := outString. 				
		].
	
	(FileSystem workingDirectory / 'testing') ensureCreateDirectory.
	File openForWriteFileNamed: (FileSystem workingDirectory / 'testing' / 'testPwd.deleteme') fullName.
	
	self newCommand
		command: '/bin/ls';
		pwd: (FileSystem workingDirectory / 'testing') fullName;
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			newLs := outString. 				
		].
	
	(FileSystem workingDirectory / 'testing' / 'testPwd.deleteme') ensureDelete.	
	(FileSystem workingDirectory / 'testing' ) ensureDelete.	 
	
	self deny: oldLs = newLs.	
	self assert: (newLs includesSubstring: 'testPwd.deleteme').
	
	"Parent should have back it's original cwd"
	self newCommand
		command: '/bin/ls';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString  |
			self assert: oldLs equals: outString
		].
		 
	
	
