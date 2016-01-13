initialize - release
initialize
	super initialize.
	envVariables := Dictionary new. 
	createPipesForMissingStreams := false.