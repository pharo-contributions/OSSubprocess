pipes
stderrStream
	^ stderrPipe ifNotNil: [ stderrPipe openReadStreamWithName: 'pipeStderrReader'].
	