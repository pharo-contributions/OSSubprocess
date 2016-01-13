initialize - release
initialize
	"Set my instance variables to reflect the state of the OS process in which 
	this Smalltalk virtual machine is. executing."

	accessProtect := Semaphore forMutualExclusion.
	childProcessList := OrderedCollection new.
	systemAccessor := OSSSystemAccessor new. 
	pid := systemAccessor getVMPid.