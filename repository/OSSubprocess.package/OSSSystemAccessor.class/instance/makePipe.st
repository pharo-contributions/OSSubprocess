pipes
makePipe
	| pipePointer returnValue fileDescriptors |
	pipePointer := NativeBoost allocate: 8.
	[
		returnValue := self primitivePipe: pipePointer.	
		(returnValue = -1) ifTrue: [ self perror: 'pipe()' ]. 
		fileDescriptors := Array new: 2.
		fileDescriptors at: 1 put: (pipePointer nbUInt32AtOffset: 0).
		fileDescriptors at: 2 put: (pipePointer nbUInt32AtOffset: 4).
		^ OSSPipe newWith: fileDescriptors
	] ensure:[
		pipePointer free.
	]