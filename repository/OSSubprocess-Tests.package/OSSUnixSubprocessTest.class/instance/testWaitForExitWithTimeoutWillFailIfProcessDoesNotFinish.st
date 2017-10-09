tests - wait
testWaitForExitWithTimeoutWillFailIfProcessDoesNotFinish
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'2'}.
	
	command run.
	
	self
		should: [ command waitForExitWithTimeout: 10 milliSeconds ]
		raise: OSSTimeout.
	self assert: command isRunning.