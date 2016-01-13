cwd
lockCwdWithValue: cwdNewValue during: aBlock

	| completed |
	completed :=  Semaphore new. 
	[ 
		| oldCwd |
		oldCwd := self systemAccessor getcwd.
		[
			self systemAccessor chdir: cwdNewValue.
			mutexForCwd critical: aBlock.
		]
		ensure: [ 
			self systemAccessor chdir: oldCwd.
			completed signal.	
		]
	] forkAt: Processor userInterruptPriority.
	completed wait.
	