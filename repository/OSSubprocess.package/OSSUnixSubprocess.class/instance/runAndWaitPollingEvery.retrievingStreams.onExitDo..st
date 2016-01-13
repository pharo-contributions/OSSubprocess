running
runAndWaitPollingEvery: aDelay retrievingStreams: aBoolean onExitDo: aClosure
	self run.
	self waitForExitPollingEvery: aDelay retrievingStreams: aBoolean.
	aBoolean 
		ifTrue: [ 
			self closeAndCleanStreams.
			aClosure cull: self cull: retrievedStdout contents cull: retrievedStderr contents.
		]
		ifFalse: [ 
			aClosure cull: self.
		]
	
	