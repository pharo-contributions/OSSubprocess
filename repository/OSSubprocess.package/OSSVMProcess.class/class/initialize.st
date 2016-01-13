initialize - release
initialize
	self initializeVMProcessInstance. 
	Smalltalk addToStartUpList: OSSVMProcess.
	Smalltalk addToShutDownList: OSSVMProcess.
