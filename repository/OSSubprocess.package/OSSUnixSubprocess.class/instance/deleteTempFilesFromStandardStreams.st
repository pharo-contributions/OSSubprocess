cleaning
deleteTempFilesFromStandardStreams
	self deleteTempFileOf: stdinStream.
	self deleteTempFileOf: stdoutStream.
	self deleteTempFileOf: stderrStream.
	
	

