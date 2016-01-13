streams
stderrStreamContents
	^ stderrStream ifNil: [ '' ] ifNotNil: [ stderrStream upToEnd ]