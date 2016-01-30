tests - pwd
testPwd
	| oldPwd | 

	oldPwd := self systemAccessor getcwd.
	(FileSystem workingDirectory / 'testing') ensureCreateDirectory.
	
	self newCommand
		shellCommand: 'pwd';
		pwd: (FileSystem workingDirectory / 'testing') fullName;
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: (FileSystem workingDirectory / 'testing') fullName.	
		].
 
	self assert: self systemAccessor getcwd trimmed equals: oldPwd trimmed.
		 
	(FileSystem workingDirectory / 'testing' ) ensureDelete.
	
