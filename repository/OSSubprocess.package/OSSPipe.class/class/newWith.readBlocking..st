instance creation
newWith: fileDescriptors readBlocking: aBoolean
	^ self new 
			initializeWith: fileDescriptors readBlocking: aBoolean
			yourself