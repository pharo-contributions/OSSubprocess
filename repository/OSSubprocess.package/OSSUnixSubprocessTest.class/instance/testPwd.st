tests - pwd
testPwd
	| oldLs newLs | 
	
	self newCommand
		command: '/bin/ls';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			oldLs := outString. 				
		].
		 
	(File openForWriteFileNamed: '/tmp/testPwd.deleteme') close. 

	self newCommand
		command: '/bin/ls';
		pwd: '/tmp';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			newLs := outString. 				
		].
		 
	'/tmp/testPwd.deleteme' asFileReference ensureDelete.	
	
	self deny: oldLs = newLs.	
	self assert: (newLs includesSubstring: 'testPwd.deleteme').
	
	"Parent should have back it's original cwd"
	self newCommand
		command: '/bin/ls';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString  |
			self assert: oldLs equals: outString
		].
		 
	
	
