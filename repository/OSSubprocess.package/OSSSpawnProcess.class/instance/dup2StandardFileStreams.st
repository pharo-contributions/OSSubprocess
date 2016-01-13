close and dup
dup2StandardFileStreams
	self createAndSetStdoutPipe.
	self createAndSetStderrPipe