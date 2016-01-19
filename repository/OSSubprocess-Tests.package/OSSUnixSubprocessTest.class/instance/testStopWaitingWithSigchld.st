tests - wait
testStopWaitingWithSigchld
	| process counter oldZombies |
	process := self newCommand.
	oldZombies := self numberOfZombiesProcesses.
	[
	process
		command: 'tail';
		arguments:  (Array with: '-f' with: Smalltalk image imagePath);
		redirectStdout;
		runAndWaitPollingEvery: (Delay forMilliseconds: 50)  retrievingStreams: true onExitDo: [ :command :outString :errString |
			"The counter is to demonstrate that the exit happens only once we did the #stopWaiting
			and not before"
			self assert: counter equals: 0. 
			self assert: process exitStatus isNil.
			"Since we did not wait for the child to finish we must do a sigterm to avoid zombies
			when running the tests"
			process sigterm.
			(Delay forSeconds: 1) wait.
			self assert: self numberOfZombiesProcesses equals: oldZombies.
		]
	] fork.				

	(Delay forSeconds: 3) wait.
	"Just to demonstrate that tail will run forever until explicitly closed".
	self assert: process isRunning. 
	counter := 0.
	process stopWaiting.
	