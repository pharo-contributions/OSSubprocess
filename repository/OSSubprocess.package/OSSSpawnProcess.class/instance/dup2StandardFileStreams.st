close and dup
dup2StandardFileStreams
	self createAndSetStdinPipe.
	self createAndSetStdoutPipe.
	self createAndSetStderrPipe