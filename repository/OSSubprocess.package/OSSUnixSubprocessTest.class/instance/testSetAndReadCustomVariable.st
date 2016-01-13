tests - env
testSetAndReadCustomVariable
	| command | 

 	'/tmp/testSetAndReadCustomVariable' asFileReference ensureDelete.
	command := self newCommand 
					bashCommand: 'echo ${WHATEVER} 2>&1 > /tmp/testSetAndReadCustomVariable ';
					environmentAt: 'WHATEVER' put: 'hello';
					runAndWait.
					
	self assert: ('/tmp/testSetAndReadCustomVariable' asFileReference readStreamDo: [ :str | str contents ]) trimmed equals: 'hello'.
	'/tmp/testSetAndReadCustomVariable' asFileReference ensureDelete. 