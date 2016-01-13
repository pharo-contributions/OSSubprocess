settings
createMissingStandardStreams: aBoolean
	"If we don't create streams for the standard streams of the child process,
	then the child will be used the inherit standard files from the parent. "
	createMissingStandardStreams := aBoolean