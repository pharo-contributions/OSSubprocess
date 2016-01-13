tests - bash
testBasicBashCommand
	| command | 
	
	command := self newCommand
					bashCommand: 'ls'.
	
	command runAndWait.
	