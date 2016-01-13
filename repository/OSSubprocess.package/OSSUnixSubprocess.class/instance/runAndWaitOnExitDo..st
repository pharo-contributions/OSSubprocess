running
runAndWaitOnExitDo: aClosure
	self run.
	self waitForExit.
	self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
	self retrieveWhatIsAvailableOn: stderrStream andAddItTo: retrievedStderr.
	self closeAndCleanStreams.
	aClosure cull: self cull: retrievedStdout contents cull: retrievedStderr contents.
	