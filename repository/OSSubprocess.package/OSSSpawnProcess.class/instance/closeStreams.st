cleaning
closeStreams
	stdinPipe closeReadEnd.
	stdoutPipe closeWriteEnd.
	stderrPipe closeWriteEnd.
	
	