tests - streams
testBasicCommandWriteToStdin
	| command stdOutString string numberOfOpenFiles | 
	
	numberOfOpenFiles := self numberOfOpenFiles.
	string := 'this is a test shat should have been printed in the stdout'.
	command := self newCommand
					command: '/bin/cat';
					createAndSetStdinStream;
					createAndSetStdoutStream.
					
	command run.
	command stdinStream 
		nextPutAll: string;
		close.
	command waitForChild.
	stdOutString := command stdoutStreamContents.
	command closeStreams.
	self assert: stdOutString equals: string.
	self assert: self numberOfOpenFiles equals: numberOfOpenFiles.
	
	
