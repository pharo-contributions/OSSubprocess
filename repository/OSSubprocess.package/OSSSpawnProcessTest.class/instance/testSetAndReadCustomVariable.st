tests - env
testSetAndReadCustomVariable
	| command | 

 	'/tmp/testSetAndReadCustomVariable' asFileReference ensureDelete.
	command := OSSSpawnProcess new 
					command: '/bin/sh';
					arguments: (Array with: '-c' with: 'echo ${WHATEVER} 2>&1 > /tmp/testSetAndReadCustomVariable ' );
					environmentAt: 'WHATEVER' put: 'hello'.

	self shouldnt: [ command run ] raise: Error. 
	command waitForChild.
	self assert: ('/tmp/testSetAndReadCustomVariable' asFileReference readStream contents) trimmed equals: 'hello'