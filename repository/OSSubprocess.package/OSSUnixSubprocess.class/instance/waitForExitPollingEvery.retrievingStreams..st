waiting
waitForExitPollingEvery: aDelay retrievingStreams: retrieveStreams
	" IMPORTANT: read first the commend of #waitForExit. 
	
	This method does NOT use #runAndWait nor #waitForExit. Instead, it does an image-based polling to check status of child process. 
	Note that the loop does send #queryExitStatus which is the method that indeeds does the waitpid() to check it.
	This is not strictly necessary because the childWatcher of the OSSVMProcess
	takes care of capturing SIGCHDL and update exitStatus. 
	However, as a more reliable solution, we can also check exit status here in case there are missed SIGCHLD or whatever.
	
	Finally, if retrieveStreams is true, we read from stdout/stderr as part of the loop and
	append the answers in retrievedStdout / retrievedStderr.
	And this solves the deadlock mentioned in #waitForChild.
	
	This method (with retrieveStreams in true) should be used when mapping stdout / stderr with pipes
	and the command to be executed may write a lot to it. Does not make much sense to be used with regular files. 
	
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