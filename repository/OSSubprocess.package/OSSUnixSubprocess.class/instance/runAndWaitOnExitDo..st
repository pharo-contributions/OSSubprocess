running
runAndWaitOnExitDo: aClosure
	| stdoutString stderrString |
	self run.
	self waitForChild.
	stdoutString := self stdoutStreamContents.
	stderrString := self stderrStreamContents.
	self closeStreams.
	aClosure cull: self cull: stdoutString cull: stderrString.