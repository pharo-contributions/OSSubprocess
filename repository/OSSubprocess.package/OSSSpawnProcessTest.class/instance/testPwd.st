tests - streams
testPwd
	| command oldLs newLs | 
	
	command := OSSSpawnProcess new
					command: '/bin/ls';
					createAndSetStdoutPipe.
	self shouldnt: [ command run ] raise: Error. 
	oldLs := command stdoutStream upToEndOfFile.
	
	File openForWriteFileNamed: '/tmp/delete.me'. 
	command := OSSSpawnProcess new
					command: '/bin/ls';
					pwd: '/tmp';
					createAndSetStdoutPipe.
	self shouldnt: [ command run ] raise: Error. 
	newLs := command stdoutStream upToEndOfFile.
	
	self deny: oldLs = newLs.	
	self assert: (newLs includesSubstring: 'delete.me').
		
	
