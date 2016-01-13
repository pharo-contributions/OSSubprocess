waiting
waitForExitPollingEvery: aDelay retrievingStreams: aBoolean
	"Does an image-based polling to check status of child process. Note that the loop
	does send #queryExitStatus which is the method that indeeds does the waitpid() to check it.
	This is not strictly necessary because the childWatcher of the OSSVMProcess
	takes care of capturing SIGCHDL and update exitStatus. 
	However, as a more reliable solution, we can also check exit status here in case there are missed SIGCHLD or whatever.
	
	Answers the exit status of the child."
	[
		"nil answer means the child has not yet finished" 
		self queryExitStatus.
		exitStatus isNil.
	]
	whileTrue: [ 
		aDelay wait.
		self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
		self retrieveWhatIsAvailableOn: stderrStream andAddItTo: retrievedStderr.
	].
	"Once more, just in case"
	self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
	self retrieveWhatIsAvailableOn: stderrStream andAddItTo: retrievedStderr.
	^ exitStatus  