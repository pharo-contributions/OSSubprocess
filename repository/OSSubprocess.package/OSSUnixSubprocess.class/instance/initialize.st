initialize - release
initialize
	super initialize.
	envVariables := Dictionary new. 
	createMissingStandardStreams := false.
	isBash := false