tests - env
testAddAllEnvVariablesFromParent
	| command | 
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					environmentAt: 'WHATEVER' put: 'vi';
					addAllEnvVariablesFromParentWithoutOverride. 

	self assert: command envVariables size equals: (OSSSpawnProcess new defaultEnvVariablesDictionary keys size) + 1.
	
	
