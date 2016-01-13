tests
testBasicCommandReadFromStderr
	| command stderrString stdoutString | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					arguments: (Array with: '-' with: 'foo').
	
	self shouldnt: [ command run ] raise: Error. 
	stderrString := command stderrStream upToEndOfFile.
	stdoutString := command stdoutStream upToEndOfFile.
	self assert: (stderrString includesSubstring: 'foo: No such file or directory').
	self assert: stdoutString isEmpty.