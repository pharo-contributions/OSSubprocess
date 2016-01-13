tests
testBasicCommandWriteToStdin
	| command stdOutString string | 
	string := 'this is a test shat should have been printed in the stdout'.
	command := OSSSpawnProcess new 
					command: '/bin/cat'.
						
	self shouldnt: [ command run ] raise: Error. 
	command stdinStream 
		nextPutAll: string;
		close.
	(Delay forSeconds: 2) wait. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: stdOutString equals: string.
	
	
