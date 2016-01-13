helper
newCommand
	
	^ self commandClass new
			"For pipes, we can use a pipe for both reading or writing"
			defaultReadStreamCreationBlock: [OSSSystemAccessor current makeNonBlockingPipe];
			defaultWriteStreamCreationBlock: [OSSSystemAccessor current makeNonBlockingPipe];
			yourself 
	
	