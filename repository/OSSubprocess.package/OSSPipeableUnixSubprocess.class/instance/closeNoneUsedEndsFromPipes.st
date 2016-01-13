cleaning
closeNoneUsedEndsFromPipes

	stdinStream ifNotNil: [ stdinStream closeReader ].
	stdoutStream ifNotNil: [ stdoutStream closeWriter ].
	stderrStream ifNotNil: [ stderrStream closeWriter ].
	