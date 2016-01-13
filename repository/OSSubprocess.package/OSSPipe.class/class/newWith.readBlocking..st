instance creation
newWith: fileDescriptors readBlocking: aBoolean
	^ self basicNew 
			initializeWith: fileDescriptors readBlocking: aBoolean
			yourself

