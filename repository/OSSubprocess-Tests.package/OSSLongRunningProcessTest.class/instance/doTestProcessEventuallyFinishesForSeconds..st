tests
doTestProcessEventuallyFinishesForSeconds: aDuration

	| command |
	command := self newCommand
		command: '/bin/sleep';
		arguments: { aDuration asSeconds asString };
		yourself.
	command run.
	
	"We should wait and finish without a timeout exception"
	command waitForExitWithTimeout: aDuration * 2.