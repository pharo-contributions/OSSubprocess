waiting
waitForExit
	mutexForSigchld := Semaphore new.
	mutexForSigchld wait. 
	^ exitStatus  