instance creation
newWith: fileDescriptors
	^ self new 
			initializeWith: fileDescriptors;
			yourself