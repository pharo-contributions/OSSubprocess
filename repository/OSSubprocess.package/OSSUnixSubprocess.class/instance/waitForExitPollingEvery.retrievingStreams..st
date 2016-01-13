waiting
waitForExitPollingEvery: aDelay retrievingStreams: aBoolean
	"Does an image-based polling to check status of child process. Note that the loop
	does NOT send #queryExitStatus which is the method that indeeds does the waitpid() to check it.
	Instead it simply checks agains it's instVar and this is because the childWatcher of the OSSVMProcess
	takes care of capturing SIGCHDL and update exitStatus. 
	Answers the exit status of the child."
	[
		"nil answer means the child has not yet finished" 
		exitStatus isNil
	]
	whileTrue: [ 
		aDelay wait.
		self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
		self retrieveWhatIsAvailableOn: stderrStream andAddItTo: stderrStream.
	].
	"Once more, just in case"
	self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
	self retrieveWhatIsAvailableOn: stderrStream andAddItTo: stderrStream.
	^ exitStatus  