streams
stdoutStreamContents
	^ stdoutStream ifNil: [ '' ] ifNotNil: [ stdoutStream upToEnd ]