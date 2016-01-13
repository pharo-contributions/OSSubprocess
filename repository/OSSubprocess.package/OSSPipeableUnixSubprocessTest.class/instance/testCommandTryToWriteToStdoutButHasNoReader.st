tests - streams
testCommandTryToWriteToStdoutButHasNoReader
	| command | 
	command := self newCommand
					bashCommand: 'sleep 2; echo 42';
					createAndSetStdoutStream;
					createAndSetStderrStream.
	
	command run.
	command stdoutStream closeReader.				
	command waitForChild.
	"This should be a SIGPIPE because there is no reader opened for the pipe and someone is trying to write to it. " 
	self assert:( command stderrStreamContents includesSubstring: 'Broken pipe')