tests - env
testInheritVarFromEnv
	| command | 
	command := OSSSpawnProcess new 
					command: '/bin/sh';
					arguments: (Array with: '-c' with: 'echo ${HOME} 2>&1 > /tmp/testReadUserDefinedEnvVar ' ).

	self shouldnt: [ command run ] raise: Error. 
	command waitForChild.
	self assert: ('/tmp/testReadUserDefinedEnvVar' asFileReference readStream contents) trimmed equals: (Smalltalk os environment at: 'HOME') trimmed