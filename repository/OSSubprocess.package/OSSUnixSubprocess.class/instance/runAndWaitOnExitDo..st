running
runAndWaitOnExitDo: aClosure
	| stdoutString stderrString |
	self run.
	self waitForChild.
	stdoutString := self stdoutStream 
									ifNil: [ '' ] 
									ifNotNil: [ :str | 
										str ossIsPipe ifFalse: [ str reopen. ].
										str upToEnd 
									].
	stderrString := self stderrStream 
								ifNil: [ '' ] 
								ifNotNil: [ :str | 
									str ossIsPipe ifFalse: [ str reopen. ].
									str upToEnd 
								].
	self closeAndCleanStreams.
	aClosure cull: self cull: stdoutString cull: stderrString.
	