tests - pwd
testPwd
	| oldLs newLs | 

	(FileSystem workingDirectory / 'testing') ensureCreateDirectory.
	
	self newCommand
		command: '/bin/ls';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			oldLs := outString. 				
		].

	self newCommand
		command: '/bin/ls';
		pwd: (FileSystem workingDirectory / 'testing') fullName;
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			newLs := outString. 				
		].
	
	self deny: oldLs = newLs.	
	
	"Parent should have back it's original cwd"
	self newCommand
		command: '/bin/ls';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString  |
			self assert: oldLs equals: outString
		].
		 
	(FileSystem workingDirectory / 'testing' ) ensureDelete.
	
