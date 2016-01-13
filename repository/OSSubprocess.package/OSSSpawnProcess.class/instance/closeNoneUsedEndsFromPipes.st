cleaning
closeNoneUsedEndsFromPipes
	stdinPipe ifNotNil: [ stdinPipe closeReadEnd ].
	stdoutPipe ifNotNil: [ stdoutPipe closeWriteEnd ].
	stderrPipe ifNotNil: [ stderrPipe closeWriteEnd ].
	
	