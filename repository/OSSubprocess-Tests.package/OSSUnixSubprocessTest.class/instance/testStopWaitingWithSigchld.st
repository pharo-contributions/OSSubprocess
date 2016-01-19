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
			self assert: command exitStatus isNil.
			"Since we did not wait for the child to finish we must do a sigterm to avoid zombies
			when running the tests"
			command sigterm.
			"Not sure about while this delay but it seems it's needed so that the next queryExitStatus
			does collect exit status and hence avoid zombies"
			(Delay forSeconds: 2) wait.
			command queryExitStatus.
			self assert: self numberOfZombiesProcesses equals: oldZombies.
		]
	] fork.				

	(Delay forSeconds: 3) wait.
	"Just to demonstrate that tail will run forever until explicitly closed".
	self assert: process isRunning. 
	counter := 0.
	process stopWaiting.
	