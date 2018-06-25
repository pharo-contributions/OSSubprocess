tests
launchAndWaitForProcessesToFinish: numberOfProcesses

	"We set the sunit test timeout to 2 times the sleep duration.
	Otherwise default sunit test timeout is 1 minute."
	
	| processes |
	"We set the sunit test timeout to 1 second per process.
	Otherwise default sunit test timeout is 1 minute.
	This is for Pharo version >= 6.0"
	(self respondsTo: #timeLimit:) ifTrue: [ 
		self timeLimit: numberOfProcesses seconds.
	].

	
	processes := (1 to: numberOfProcesses) collect: [ :index |
		self newCommand
			command: '/bin/sleep';
			arguments: { '1s' };
			yourself ].
	
	processes do: #run.
	
	processes do: [ :command | command waitForExitWithTimeout: 5 seconds ]
