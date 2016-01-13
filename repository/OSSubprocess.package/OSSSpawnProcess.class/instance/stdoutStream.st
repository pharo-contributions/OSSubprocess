pipes
stdoutStream
	^ stdoutPipe ifNotNil: [ stdoutPipe openReadStreamWithName: 'pipeStdoutReader' ].
	