pipes
createPipe
	| pipePointer returnValue fileDescriptors |
	pipePointer := NativeBoost allocate: 8.
	self registerPointer: pipePointer. 
	returnValue := self primitivePipe: pipePointer.	
	(returnValue = -1) ifTrue: [ 
		self primitivePerror: 'pipe()'.
		self error: 'Failed in pipe() call. You may want to check errors in stderr' 
	]. 
	fileDescriptors := Array new: 2.
	fileDescriptors at: 1 put: (pipePointer nbUInt32AtOffset: 0).
	fileDescriptors at: 2 put: (pipePointer nbUInt32AtOffset: 4).
	^ fileDescriptors