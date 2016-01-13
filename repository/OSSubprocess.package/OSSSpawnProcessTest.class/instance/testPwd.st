tests - pwd
testPwd
	| command oldLs newLs recoveredLs | 
	
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
	
	"Parent should have back it's original cwd"
	command := OSSSpawnProcess new
				command: '/bin/ls';
				createAndSetStdoutPipe.
	self shouldnt: [ command run ] raise: Error. 
	recoveredLs := command stdoutStream upToEndOfFile.
	self assert: oldLs equals: recoveredLs
