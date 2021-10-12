Class {
	#name : #OSSUnixSubprocessTest,
	#superclass : #OSSAbstractUnixSubprocessTest,
	#category : 'OSSubprocess-Tests-Unit'
}

{ #category : #testing }
OSSUnixSubprocessTest class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	TestCase instances built from it"

	^self name = #OSSUnixSubprocessTest
			
]

{ #category : #helpers }
OSSUnixSubprocessTest >> assertStreamsInfoWithPrevious: anObject [ 
	self assert: self getStreamsInfoForRunningTest equals: anObject
]

{ #category : #helpers }
OSSUnixSubprocessTest >> getStreamsInfoForRunningTest [
	^ self numberOfOpenFiles 
]

{ #category : #helpers }
OSSUnixSubprocessTest >> numberOfOpenFiles [
	"This is estimation number. Not to be used for real code. It's basically to check the number of opened FIFO files at the beginning of a test and at the end, to validate we are not leaving behind opened files.
	This should work in most Unix-like and Linux systems.
	Only FIFO files are checked as we can't control other threads, and it is redirecting stdio that is happening in the tests."
	| tmpFileName openFiles |
	tmpFileName := (FileSystem workingDirectory / 'openFilesByPharoVM-' , UUID new printString) fullName.
	tmpFileName asFileReference ensureDelete.
	self systemAccessor system: ('lsof -p ', OSSVMProcess vmProcess pid printString, ' > "', tmpFileName, '" 2>&1').
	openFiles := tmpFileName asFileReference readStreamDo: [ :str | | lines |
		lines := str contents lines.
		"Count only pipes"
		lines select: [ :each | each includesSubstring: 'FIFO' ]
	].
	tmpFileName asFileReference ensureDelete.
	^ openFiles size

]

{ #category : #helpers }
OSSUnixSubprocessTest >> numberOfZombiesProcesses [
	"This is estimation number. Not to be used for real code. IT's basically 
	to check the number of zombies at the beginning of a  test and at the end, to validate we are not leaving behind new zombies. 
	This should work in most Unix-like and Linux
	"
	| tmpFileName zombiesCount |
	tmpFileName := (FileSystem workingDirectory / 'zombiesByPharoVM-' , UUID new printString) fullName.
	tmpFileName asFileReference ensureDelete.
	self systemAccessor system: ('ps axo ppid=,stat= | grep ', OSSVMProcess vmProcess pid printString, ' | awk ''$2~/^Z/ { print $2 }'' | wc -l  > "', tmpFileName, '" 2>&1').
	zombiesCount := tmpFileName asFileReference readStreamDo: [ :str |
		str contents trimmed asNumber
	].
	tmpFileName asFileReference ensureDelete.
	^ zombiesCount
	
]

{ #category : #helpers }
OSSUnixSubprocessTest >> ppidOf: childPid [
	"Answers the parent pid (ppid) of the childPid
	"
	| tmpFileName openFilesNumber |
	tmpFileName := (FileSystem workingDirectory / ' ppidof-' , UUID new printString) fullName.
	tmpFileName asFileReference ensureDelete.
	Transcript show: tmpFileName; cr.
	self systemAccessor system: ('ps -p ', childPid , ' -o ppid=').
	openFilesNumber := tmpFileName asFileReference readStreamDo: [ :str |
		"The -1 is because the above command brings one line which is a header." 
		str contents trimmed asNumber
	].
	tmpFileName asFileReference ensureDelete.
	^ openFilesNumber
	
]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testAddAllEnvVariablesFromParent [
	| command | 
	command := self newCommand
					command: '/bin/ls';
					environmentAt: 'WHATEVER' put: 'vi';
					addAllEnvVariablesFromParentWithoutOverride. 

	self assert: command envVariables size equals: (OSSUnixSubprocess new defaultEnvVariablesDictionary keys size) + 1.
	
	

]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testAddAllEnvVariablesFromParentWithoutOverride [
	| command | 
	"Here we assume that the parent process will have the $PATH defined."
	command := self newCommand
					command: '/bin/ls';
					environmentAt: 'PATH' put: 'whatever';
					addAllEnvVariablesFromParentWithoutOverride. 

	self assert: command envVariables size equals: (OSSUnixSubprocess new defaultEnvVariablesDictionary keys size).
	self assert: (command envVariables at: 'PATH') equals: 'whatever'
	
	

]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testAddOnlyOneVariable [
	| command | 
	command := self newCommand
					command: '/bin/ls';
					environmentAt: 'EDITOR' put: 'vi'.

	self assert: command envVariables size equals: 1.
	
	

]

{ #category : #'tests - basic' }
OSSUnixSubprocessTest >> testBasicCommand [
	| command |
	command := self newCommand 
					command: '/bin/ls'.
	command runAndWait.
	
]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testBasicCommandReadFromStderr [
	| streamsInfo |
	streamsInfo := self getStreamsInfoForRunningTest.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: '-' with: 'foo');
		redirectStderr;
		runAndWaitOnExitDo: [ :command :outString :errString |
			self assert: (errString includesSubstring: ': No such file or directory').
			self assert: command stdoutStream isNil.
			self assert: command stderrStream closed.
			self assertStreamsInfoWithPrevious: streamsInfo.
		].
	
	
]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testBasicCommandReadFromStdout [
	| streamsInfo |
	streamsInfo := self getStreamsInfoForRunningTest.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).
			self assertStreamsInfoWithPrevious: streamsInfo.
		].
	
	
]

{ #category : #'tests - basic' }
OSSUnixSubprocessTest >> testBasicCommandWithArgument [
	| command | 
	
	command := self newCommand
					command: '/bin/ls';
					arguments: { Smalltalk image imagePath. }.
	
	command runAndWait
]

{ #category : #'tests - basic' }
OSSUnixSubprocessTest >> testBasicCommandWithNonAsciiArgument [
	| command | 
	
	self withNonAsciiDirectoryDo: [ :dir |
		command := self newCommand
					command: '/bin/ls';
					arguments: { dir fullName }.
		command runAndWait
	]

]

{ #category : #'tests - basic' }
OSSUnixSubprocessTest >> testBasicCommandWithoutFullPath [

	self newCommand
		command: 'ls';
		arguments: (Array with: Smalltalk image imagePath);
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).					
		]
		 

]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testBasicCommandWriteToStdin [
	| command stdOutString string streamsInfo | 
	streamsInfo := self getStreamsInfoForRunningTest.
	string := 'this is a test shat should have been printed in the stdout'.
	command := self newCommand
					command: '/bin/cat';
					redirectStdin;
					redirectStdout.
					
	command run.
	command stdinStream 
		nextPutAll: string;
		close.
	command waitForExit.
	stdOutString := command stdoutStream upToEndOfFile.
	command closeAndCleanStreams.
	self assert: command isSuccess.
	self assert: stdOutString equals: string.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
	

]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testBasicCommandWriteToStdin2 [
	| command streamsInfo outString | 
	streamsInfo := self getStreamsInfoForRunningTest.

	command := self newCommand
					command: 'wc';
					redirectStdin;
					redirectStdout;
					run. 

	command stdinStream 
			nextPutAll: Smalltalk image imagePath;
			close.

	command waitForExit.
	outString := command stdoutStream upToEndOfFile. 
	command closeAndCleanStreams.				
	self assert: command isSuccess.
	"It's hard to test the output of wc crossplatform..."
	self assert: outString size > 5.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
	

]

{ #category : #'tests - shell' }
OSSUnixSubprocessTest >> testBasicShellCommand [
	| command | 
	
	command := self newCommand
					shellCommand: 'ls'.
	
	command runAndWait.
	
]

{ #category : #'tests - shell' }
OSSUnixSubprocessTest >> testBasicShellCommandWithNonAsciiCharacters [
	
	self withNonAsciiDirectoryDo: [ :dir |
		(dir / 'ok.txt') ensureCreateFile.
		self newCommand
			shellCommand: 'ls ', dir fullName;
			redirectStdout;
			runAndWaitOnExitDo: [ :command :outString |
				self assert: (outString includesSubstring: 'ok.txt').						
		]
	]
]

{ #category : #'tests - shell' }
OSSUnixSubprocessTest >> testBasicShellCommandWithStdout [

	self newCommand
		shellCommand: 'ls "', Smalltalk image imagePath, '"';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).						
		]
		 

]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testCheckZombieStateAndTestChildWatcherWorking [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: '/bin/sleep';
				arguments: {'1'}.
	
	command run. 
	self assert: command pid > 0.
	(Duration seconds: 2) wait.
	"In this case we are NOT going to do the queryExitStatus since we want to know 
	if the child watcher is doing it's job."
	"self assert: command queryExitStatus isNil not."
	"Now it should not be a zombie anymore"
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
	
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testCheckZombieStateWithNonExistingCommang [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: 'whatever'.
				
		"Ideally, I would like to use a should:raise: but not all OS do fail. OSX does send errorl, while Linux does not.
	So...if error, then it;s ok. But if not, also."
	[ command runAndWait ] on: Error do: [  :ex | 
		self assert: (ex printString includesSubstring: 'No such file or directory') .
		self assert: command pid isNil.
		^ nil
	].
	
	self assert: command exitStatusInterpreter exitStatus > 0.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
	
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testCheckZombieStateWithOnExitApi [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: '/bin/sleep';
				arguments: {'1'};
				runAndWaitOnExitDo: [  ].
	
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
	
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testCheckZombieStateWithWaitChild [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: '/bin/sleep';
				arguments: {'1'}.
	
	command run.
	command waitForExit. 
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
	
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testCommandReturningDifferentThanZero [
	| command | 
	
	"When the file does not exists ls returns 1"
	command := self newCommand 
					command: '/bin/ls';
					arguments: {'asdasdasdasdsad'}.
	
	command runAndWait. 
	
	"Do not use #deny:equals: for Pharo 6 compatibility"
	self deny: (command exitStatusInterpreter exitStatus = 0)
]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testCreateMissingStandardStreamsDisabled [
	| command | 
	
	command := self newCommand
					command: '/bin/ls'.
					
	command runAndWait. 
	self assert: command stdinStream isNil.
	self assert: command stdoutStream isNil.
	self assert: command stderrStream isNil.
	
]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testCreateMissingStandardStreamsEnabled [
	| command streamsInfo | 
	streamsInfo := self getStreamsInfoForRunningTest.
	"The output of the ls command should be displayed in the stdout of the Pharo image. See comment of #createPipesForMissingStreams: for more details"
	command := self newCommand
					command: '/bin/ls';
					createMissingStandardStreams: true.
					
	command runAndWait. 
	self assert: command stdinStream isNil not.
	self assert: command stdoutStream isNil not.
	self assert: command stderrStream isNil not.
	command closeAndCleanStreams.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
]

{ #category : #'tests - shell' }
OSSUnixSubprocessTest >> testCustomShellWithStdout [

	self newCommand
		shell: '/bin/bash' command: 'ls "', Smalltalk image imagePath, '"';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).					
		]
		 

]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testCustomStdoutStream [
	| customStream streamsInfo | 
	streamsInfo := self getStreamsInfoForRunningTest.
	customStream := self newCommand createADefaultWriteStream.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		redirectStdoutTo: customStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).
			self assert: command stdoutStream == customStream	.				
			self assertStreamsInfoWithPrevious: streamsInfo.
		].
	
	


]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testGetChildPid [
	| command | 
	
	command := self newCommand 
					command: '/bin/ls'.
	
	command run.
	self assert: command pid > 0.
	command waitForExit. 
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testGetChildStatusAfterFailingCommand [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand
					command: '/bin/ls';
					arguments: {'whatever'}.
	command run.
	self assert: command pid > 0.
	command waitForExit.
	command queryExitStatus.
	self assert: command exitStatusInterpreter exitStatus >  0. 
	self deny: command isSuccess.
	self assert: command isComplete.
	self deny: command isRunning.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testGetChildStatusAfterFinishesMultipleTimes [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand
					command: '/bin/ls'.
	
	command run. 
	self assert: command pid > 0.
	command waitForExit.
	"Just wanted to be sure there is no problem calling waitpid() multiple times"
	command queryExitStatus.
	command queryExitStatus.
	command queryExitStatus.
	command queryExitStatus.
	
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
	self assert: command isSuccess.
	self assert: command isComplete.
	self deny: command isRunning.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testGetChildStatusAfterFinishesSuccess [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand
					command: '/bin/ls'.
	
	command run. 
	self assert: command pid > 0.
	command waitForExit.
	command queryExitStatus.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
	self assert: command isSuccess.
	self assert: command isComplete.
	self deny: command isRunning.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
]

{ #category : #'tests - child status' }
OSSUnixSubprocessTest >> testGetChildStatusBeforeAndAfterFinishing [
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: '/bin/sleep';
				arguments: {'3'}.
	
	command run. 
	self assert: command pid > 0.
	(Duration seconds: 1) wait.
	self assert: command queryExitStatus isNil.
	self deny: command isComplete.
	self assert: command isRunning.
	command waitForExit.
	self assert: command queryExitStatus isNil not.
	self assert: command exitStatusInterpreter exitStatus equals: 0.
	self assert: command isComplete.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testInheritVarFromEnv [
	| command | 
	command := self newCommand
					shellCommand: 'echo ${HOME} 2>&1 > /tmp/testReadUserDefinedEnvVar ';
					runAndWait.
	
	self assert: ('/tmp/testReadUserDefinedEnvVar' asFileReference readStreamDo: [ :str | str contents ]) trimmed equals: (Smalltalk os environment at: 'HOME') trimmed.
	'/tmp/testReadUserDefinedEnvVar' asFileReference ensureDelete. 
]

{ #category : #'tests - basic' }
OSSUnixSubprocessTest >> testNoneExistingCommand [
	| command stdout stderr | 
	
	command := self newCommand
					command: 'whatever';
					redirectStdout;
					redirectStderr.
	
	"Ideally, I would like to use a should:raise: but not all OS do fail. OSX does send errorl, while Linux does not.
	So...if error, then it;s ok. But if not, also."
	[ command runAndWait ] on: Error do: [  :ex | 
		self assert: (ex printString includesSubstring: 'No such file or directory') .
		self assert: command pid isNil.
		command closeAndCleanStreams.
		^ nil
	].
	
	self assert: command exitStatusInterpreter exitStatus > 0.
	command closeAndCleanStreams.
]

{ #category : #'tests - streams' }
OSSUnixSubprocessTest >> testReadingFromStdoutAfterCommandFinishesDoesNotBlocksVM [
	| command streamsInfo | 
	
	"We set the sunit test timeout to 30 seconds.
	Otherwise default sunit test timeout is 10 seconds.
	This is for Pharo version >= 6.0"
	(self respondsTo: #timeLimit:) ifTrue: [ 
		self timeLimit: 30 seconds.
	].
	
	streamsInfo := self getStreamsInfoForRunningTest.
	command := self newCommand
					command: '/bin/sleep';
					arguments: (Array with: '1');
					redirectStdout;
					runAndWait.
					
	"Even with a blocking stream, if the command has finished, we have
	all data ready to read and hence it's not blocking"
	self assert:[ command stdoutStream upToEndOfFile ] timeToRun seconds <= 5. 
	command closeAndCleanStreams.
	self assertStreamsInfoWithPrevious: streamsInfo.
	

	
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testRunAndWaitPollingEveryRetrievingStreamsOnExitDo [
	self newCommand 
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		redirectStdout;
		runAndWaitPollingEvery: (Delay forMilliseconds: 50)  retrievingStreams: true onExitDo: [ :command :outString :errString |
			self assert: command pid > 0.
			self assert: command exitStatusInterpreter exitStatus equals: 0. 
			self assert: (outString includesSubstring: Smalltalk image imagePath).
			self assert: command stdoutStream closed.
		]				

]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testSetAndReadCustomVariable [
	self newCommand 
		shellCommand: 'echo ${WHATEVER}';
		environmentAt: 'WHATEVER' put: 'hello';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: 'hello'
		]

]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testSetAndReadCustomVariableOutsideShell [
	self newCommand 
		command: 'printenv';
		arguments: (Array with: 'WHATEVER');
		environmentAt: 'WHATEVER' put: 'hello';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: 'hello'. 					
		]

]

{ #category : #'tests - env' }
OSSUnixSubprocessTest >> testSetCustomVariableOutsideShellAndPassedToCommand [
	" This test demonstrates that we do not expand variables automatically. So if you don't use the shell, or any other special command that
	will search for special variables (like git searching $GIT_EDITOR), these will not be resolved. 
	If you want that, then you must execute the command with the arguments already expandaded. That is, for example,
	in this case, you should pass the argument 'hello' rather than ${WHATEVER} "
	
	self newCommand 
		command: '/bin/echo';
		arguments: (Array with: '${WHATEVER}');
		environmentAt: 'WHATEVER' put: 'hello';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: '${WHATEVER}'. 			
		]

]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testShellCommandReturningDifferentThanZero [
	| command | 
	
	command := self newCommand shellCommand: 'exit 2'.
	command runAndWait. 
	
	self assert: command exitStatusInterpreter exitStatus equals: 2. 
]

{ #category : #'tests - shell' }
OSSUnixSubprocessTest >> testShellCommandWithPipingStdout [

	self newCommand
		shellCommand: 'ps -fea | grep Pharo';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: 'Pharo').						
		]
		 

]

{ #category : #'tests - shell' }
OSSUnixSubprocessTest >> testShellCommandWithStreamRedirects [
	| stdOutContents | 

	self newCommand
		shellCommand: 'ps -fea | grep Pharo > /tmp/testShellCommandWithStreamRedirects.deleteme';
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString isEmpty. 
			stdOutContents := '/tmp/testShellCommandWithStreamRedirects.deleteme' asFileReference readStreamDo: [ :str | str contents ] .
			self assert: (stdOutContents includesSubstring: 'Pharo').						
		].
	'/tmp/testShellCommandWithStreamRedirects.deleteme' asFileReference ensureDelete. 
		 
	
	
	
]

{ #category : #'tests - signals' }
OSSUnixSubprocessTest >> testSigTerm [

	| process exited streamsInfo |
	
	"We set the sunit test timeout to 30 seconds.
	Otherwise default sunit test timeout is 10 seconds.
	This is for Pharo version >= 6.0"
	(self respondsTo: #timeLimit:) ifTrue: [ 
		self timeLimit: 30 seconds.
	].
	
	exited := false.
	streamsInfo := self getStreamsInfoForRunningTest.
	process := self newCommand.
	[
	process 
		command: 'tail';
		arguments: (Array with: '-f' with: Smalltalk image changesName);
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: (Delay forMilliseconds: 500) 
		doing: [ :aProcess :outStream :errStream |  
		 	outStream upToEnd.
			errStream upToEnd.
		]
		onExitDo: [ :aProcess :outStream :errStream  |
			process closeAndCleanStreams.
			exited := true.
			self assert: aProcess exitStatusInterpreter printString equals: 'exit due to signal 15'
		].
	"The problem here is that we simply do a #fork this closure will continue to be executed while other test run. And so, all the test checking for zombies or opened files will fail because we can have this forked process that did not yet finish. A workaround is to simply run this closures with a higher priority so that there are less chances of other tests to be running. Another possibility would be to reject those 'tail' processes from #numberOfZombiesProcesses and #numberOfOpenFiles as all the tests that use #fork use the 'tail' OS command."	
	] forkAt: Processor userInterruptPriority.

	(Delay forSeconds: 2) wait. 
	process sigterm. 
	(Delay forSeconds: 10) wait. 
	self assert: exited.	
	self assertStreamsInfoWithPrevious: streamsInfo.

]

{ #category : #'tests - signals' }
OSSUnixSubprocessTest >> testSigTermInsideLoop [

	| process exited streamsInfo |
	
	exited := false.
	streamsInfo := self getStreamsInfoForRunningTest.
	process := self newCommand.
	
	process 
		command: 'tail';
		arguments: (Array with: '-f' with: Smalltalk image changesName);
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: (Delay forMilliseconds: 500) 
		doing: [ :aProcess :outStream :errStream |  
		 	"Imagine here that you have some condition...say.. elapsedTime > 1 h .. 
			or ... stdOutStream size > 1MB  or whatever..  "
			
			"#sigterm will throw an error (no such process) if the process with the given pid doesn't exist. Because of the looping of this method it COULD happen that we send #sigterm again even if the process was already killed in the previous loop. So we simply make sure the process is running before doing the #sigterm"
			aProcess isRunning ifTrue: [ aProcess sigterm. ]
 	]
		onExitDo: [ :aProcess :outStream :errStream  |
			process closeAndCleanStreams.
			exited := true.
			self assert: aProcess exitStatusInterpreter printString equals: 'exit due to signal 15'
		].

	self assert: exited.	
	self assertStreamsInfoWithPrevious: streamsInfo.

]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testStopWaitingWithPolling [
	| process counter oldZombies |
	process := self newCommand.
	oldZombies := self numberOfZombiesProcesses.
	counter := 0.
	[
		process
			command: 'tail';
			arguments:  (Array with: '-f' with: Smalltalk image imagePath);
			redirectStdout;
			runAndWaitPollingEvery: (Delay forMilliseconds: 50)  retrievingStreams: true onExitDo: [ :command :outString :errString |
				"The counter is to demonstrate that the exit happens only once we did the #stopWaiting
				and not before"
				self assert: counter equals: 0. 
				self assert: process exitStatus isNil.
				"Since we did not wait for the child to finish we must do a sigterm to avoid zombies
				when running the tests"
				command sigterm.
				"Not sure about while this delay but it seems it's needed so that the next queryExitStatus
				does collect exit status and hence avoid zombies"
				(Delay forSeconds: 4) wait.
				command queryExitStatus.
				self assert: self numberOfZombiesProcesses equals: oldZombies.
				
			]			
	"The problem here is that we simply do a #fork this closure will continue to be executed while other test run. And so, all the test checking for zombies or opened files will fail because we can have this forked process that did not yet finish. A workaround is to simply run this closures with a higher priority so that there are less chances of other tests to be running. Another possibility would be to reject those 'tail' processes from #numberOfZombiesProcesses and #numberOfOpenFiles as all the tests that use #fork use the 'tail' OS command."	
	] forkAt: Processor userInterruptPriority.


	(Delay forSeconds: 3) wait.
	"Just to demonstrate that tail will run forever until explicitly closed".
	self assert: process isRunning. 
	process stopWaiting.
	
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testStopWaitingWithSigchld [
	| process counter oldZombies |
	process := self newCommand.
	oldZombies := self numberOfZombiesProcesses.
	counter := 0.
	[
	process
		command: 'tail';
		arguments:  (Array with: '-f' with: Smalltalk image imagePath);
		redirectStdout;
		runAndWaitPollingEvery: (Delay forMilliseconds: 50)  retrievingStreams: true onExitDo: [ :command :outString :errString |
			"The counter is to demonstrate that the exit happens only once we did the #stopWaiting
			and not before"
			self assert: counter equals: 0. 
			self assert: command exitStatus isNil.
			"Since we did not wait for the child to finish we must do a sigterm to avoid zombies
			when running the tests"
			command sigterm.
			"Not sure about while this delay but it seems it's needed so that the next queryExitStatus
			does collect exit status and hence avoid zombies"
			(Delay forSeconds: 4) wait.
			command queryExitStatus.
			self assert: self numberOfZombiesProcesses equals: oldZombies.
		]
	"The problem here is that we simply do a #fork this closure will continue to be executed while other test run. And so, all the test checking for zombies or opened files will fail because we can have this forked process that did not yet finish. A workaround is to simply run this closures with a higher priority so that there are less chances of other tests to be running. Another possibility would be to reject those 'tail' processes from #numberOfZombiesProcesses and #numberOfOpenFiles as all the tests that use #fork use the 'tail' OS command."	
	] forkAt: Processor userInterruptPriority.				

	(Delay forSeconds: 3) wait.
	"Just to demonstrate that tail will run forever until explicitly closed".
	self assert: process isRunning. 
	process stopWaiting.
	
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testWaitForExit [
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'3'}.
	
	command run. 
	self assert: command pid > 0.
	self assert: [ command waitForExit ] timeToRun asSeconds >= 2.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testWaitForExitPolling [
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'3'}.
	
	command run. 
	self assert: command pid > 0.
	self assert: [ command waitForExitPolling ] timeToRun asSeconds >= 2.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testWaitForExitPollingEvery [
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'3'}.
	
	command run. 
	self assert: command pid > 0.
	self assert: [ command waitForExitPollingEvery: (Delay forSeconds: 1) ] timeToRun asSeconds >= 2.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
]

{ #category : #'tests - high API' }
OSSUnixSubprocessTest >> testWaitForExitPollingEveryDoing [
	| streamsInfo totalRead |
	totalRead := String new writeStream.
	streamsInfo := self getStreamsInfoForRunningTest.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: (Delay forMilliseconds: 50) 
		doing: [ :process :outStream :errStream |  
			| read | 
			read := outStream upToEnd.
			totalRead nextPutAll: read.
		]
		onExitDo: [ :process :outStream :errStream  |
			self assert: (totalRead contents includesSubstring: Smalltalk image imagePath).
			process closeAndCleanStreams.
			self assertStreamsInfoWithPrevious: streamsInfo.
		].

	
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testWaitForExitWithTimeoutWillFailIfProcessDoesNotFinish [
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'2'}.
	
	command run.
	
	self
		should: [ command waitForExitWithTimeout: 10 milliSeconds ]
		raise: OSSTimeout.
	self assert: command isRunning.
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testWaitForExitWithTimeoutWillNotTimeoutIfProcessFinishes [
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'1'}.
	
	command run.
	command waitForExitWithTimeout: 2 seconds.
	
	self assert: command pid > 0.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
]

{ #category : #'tests - wait' }
OSSUnixSubprocessTest >> testWaitpidIsNoneBocking [
	| command childStatus | 
	
	command := self newCommand
					command: '/bin/sleep';
					arguments: {'5'}.
	
	command run. 
	self assert: command pid > 0.
	(Duration seconds: 1) wait.
	self assert: [ childStatus := command exitStatusInterpreter ] timeToRun asSeconds < 1.
	self assert: childStatus value isNil.
	command waitForExit.
]

{ #category : #'tests - pwd' }
OSSUnixSubprocessTest >> testWorkingDirectory [
	| oldWorkingDirectory | 

	oldWorkingDirectory := self systemAccessor getcwd.
	(FileSystem workingDirectory / 'testing') ensureCreateDirectory.
	
	self newCommand
		shellCommand: 'pwd';
		workingDirectory: (FileSystem workingDirectory / 'testing') fullName;
		redirectStdout;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: (FileSystem workingDirectory / 'testing') fullName.	
		].
 
	self assert: self systemAccessor getcwd trimmed equals: oldWorkingDirectory trimmed.
		 
	(FileSystem workingDirectory / 'testing') ensureDelete.
	

]

{ #category : #helpers }
OSSUnixSubprocessTest >> withNonAsciiDirectoryDo: aBlock [ 
	| directory |
	directory := FileLocator temp / (self class name , '-éoï-' , UUIDGenerator next asString).
	directory ensureCreateDirectory.
	[ aBlock cull: directory asFileReference ]
	ensure: [ directory ensureDeleteAll ]
]
