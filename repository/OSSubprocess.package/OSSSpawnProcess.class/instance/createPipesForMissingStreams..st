settings
createPipesForMissingStreams: aBoolean
	"If we don't create pipes for the standard streams of the child process,
	then the child will be used the inherit standard files from the parent. "
	createPipesForMissingStreams := aBoolean