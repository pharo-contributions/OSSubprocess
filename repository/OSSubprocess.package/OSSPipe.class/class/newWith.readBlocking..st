instance creation
newWith: fileIDsArray readBlocking: aBoolean
	^ self basicNew 
			initializeWith: fileIDsArray readBlocking: aBoolean
			yourself

