Class {
	#name : #OSSPipeBasedUnixSubprocessTest,
	#superclass : #OSSUnixSubprocessTest,
	#category : 'OSSubprocess-Tests-Unit'
}

{ #category : #helper }
OSSPipeBasedUnixSubprocessTest >> newCommand [
	
	^ self commandClass new
			"For pipes, we can use a pipe for both reading or writing"
			defaultReadStreamCreationBlock: [self systemAccessor makeBlockingPipe];
			defaultWriteStreamCreationBlock: [self systemAccessor makeNonBlockingPipe];
			yourself 
	
	
]

{ #category : #'tests - streams' }
OSSPipeBasedUnixSubprocessTest >> testCommandTryToWriteToStdoutButHasNoReader [
	| command errString  | 
	command := self newCommand
					shellCommand: 'sleep 2; echo 42';
					redirectStdout;
					redirectStderr.
	
	command run.
	command stdoutStream closeReader.				
	command waitForExit.
	"This should be a SIGPIPE because there is no reader opened for the pipe and someone is trying to write to it. " 
	errString := command stderrStream upToEndOfFile.
	self assert: command exitStatusInterpreter exitStatus > 0. "It ended with error".
	"Ideally I would also add this assert, but it seems not all OS write this on stderr. For example,
	OSX does write it, while Linux does not."
	"self assert:( errString includesSubstring: 'Broken pipe')."
	command closeAndCleanStreams.
]

{ #category : #'tests - streams' }
OSSPipeBasedUnixSubprocessTest >> testReadingFromStdoutBlocksVM [
	| command customStream | 
	customStream := self systemAccessor makeBlockingPipe.
	command := self newCommand
					command: '/bin/sleep';
					arguments: (Array with: '4');
					redirectStdoutTo: customStream.
	
	command run. 
	self assert:[ command stdoutStream upToEnd ] timeToRun seconds > 2. 
	command waitForExit.
	command closeAndCleanStreams.
]

{ #category : #'tests - streams' }
OSSPipeBasedUnixSubprocessTest >> testReadingFromStdoutDoesNotBlocksVM [
	| command customStream | 
	customStream := self systemAccessor makeNonBlockingPipe.
	command := self newCommand
					command: '/bin/sleep';
					arguments: (Array with: '4');
					redirectStdoutTo: customStream.
	
	command run. 
	self assert:[ command stdoutStream upToEnd ] timeToRun seconds <= 2. 
	command waitForExit. 
	command closeAndCleanStreams.
]
