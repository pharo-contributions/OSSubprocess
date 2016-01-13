pipes
makePipeWithReadBlocking: aBoolean
	| pipePointer returnValue fileDescriptors |
	pipePointer := ExternalAddress allocate: 8.
	[
		returnValue := self primitivePipe: pipePointer.	
		(returnValue = -1) ifTrue: [ self perror: 'pipe()' ]. 
		fileDescriptors := Array new: 2.
		fileDescriptors at: 1 put: (pipePointer nbUInt32AtOffset: 0).
		fileDescriptors at: 2 put: (pipePointer nbUInt32AtOffset: 4).
		^ OSSPipe newWith: fileDescriptors readBlocking: aBoolean. 
	] ensure:[
		pipePointer free.
	]