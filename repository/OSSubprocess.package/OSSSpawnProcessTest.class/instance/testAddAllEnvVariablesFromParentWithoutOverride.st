tests - env
testAddAllEnvVariablesFromParentWithoutOverride
	| command | 
	"Here we assume that the parent process will have the $PATH defined."
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					environmentAt: 'PATH' put: 'whatever';
					addAllEnvVariablesFromParentWithoutOverride. 

	self assert: command envVariables size equals: (OSSSpawnProcess new defaultEnvVariablesDictionary keys size).
	self assert: (command envVariables at: 'PATH') equals: 'whatever'
	
	
