tests - streams
testBasicCommandReadFromStderr
	| command stderrString | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					arguments: (Array with: '-' with: 'foo');
					createAndSetStderrPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	stderrString := command stderrStream upToEndOfFile.
	self assert: (stderrString includesSubstring: 'foo: No such file or directory').
	self assert: command stdoutStream isNil.