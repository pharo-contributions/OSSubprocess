pipes
stdinStream
	^ stdinPipe ifNotNil: [ stdinPipe openWriteStreamWithName: 'pipeStdinWriter' ].
	