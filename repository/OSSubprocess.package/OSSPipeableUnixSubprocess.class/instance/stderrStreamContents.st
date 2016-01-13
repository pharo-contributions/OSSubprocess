streams
stderrStreamContents
	^ stderrStream ifNil: [ '' ] ifNotNil: [ stderrStream upToEndOfFile ]