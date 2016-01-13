tests - env
testAddOnlyOneVariable
	| command | 
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					environmentAt: 'EDITOR' put: 'vi'.

	self assert: command envVariables size equals: 1.
	
	
