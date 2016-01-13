initialize - release
initialize
	super initialize.
	envVariables := Dictionary new. 
	createMissingStandardStreams := false.
	"By default, we create a none blocking pipe stream. However, we also allow
	blocking pipes and also regular StandardFileStreams instances.
	Also, For pipes, we can use a pipe for both reading or writing"
	defaultReadStreamCreationBlock := [self systemAccessor makeNonBlockingPipe].
	defaultWriteStreamCreationBlock := [self systemAccessor makeNonBlockingPipe].
	retrievedStdout := String new writeStream. 
	retrievedStderr := String new writeStream. 
	mutexForSigchld := Semaphore new.
	
		
