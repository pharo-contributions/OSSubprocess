tests
testWrongMode
	| command | 
	
	command := OSSPopenCommand new 
					mode: 'a'; "modes are either 'r' or 'w' "
					command: 'ls'.
				
	self should: [ command run ] raise: Error.
