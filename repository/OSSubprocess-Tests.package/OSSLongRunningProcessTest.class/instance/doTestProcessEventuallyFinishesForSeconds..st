tests
doTestProcessEventuallyFinishesForSeconds: aDuration

	| command |
	"We set the sunit test timeout to 2 times the sleep duration.
	Otherwise default sunit test timeout is 1 minute."
	self timeLimit: aDuration * 2.
	
	command := self newCommand
		command: '/bin/sleep';
		arguments: { aDuration asSeconds asString };
		yourself.
	command run.
	
	"We should wait and finish without a timeout exception"
	command waitForExitWithTimeout: aDuration * 2.