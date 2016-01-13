cwd
lockCwdWithValue: cwdNewValue during: aBlock

	| completed |
	completed :=  Semaphore new. 
	[ 
		| oldCwd |
		oldCwd := self getcwd.
		[
			self chdir: cwdNewValue.
			mutexForCwd critical: aBlock.
		]
		ensure: [ 
			self chdir: oldCwd.
			completed signal.	
		]
	] forkAt: Processor userInterruptPriority.
	completed wait.
	