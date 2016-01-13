streams
stdoutStreamContents
	^ stdoutStream ifNil: [ '' ] ifNotNil: [ stdoutStream upToEndOfFile ]