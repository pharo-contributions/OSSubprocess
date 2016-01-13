tests - env
testSetCustomVariableOutsideBashAndPassedToCommand
	" This test demonstrates that we do not expand variables automatically. So if you don't use bash, or any other special command that
	will search for special variables (like git searching $GIT_EDITOR), these will not be resolved. 
	If you want that, then you must execute the command with the arguments already expandaded. That is, for example,
	in this case, you should pass the argument 'hello' rather than ${WHATEVER} "
	| command outputString | 
	
 	command := OSSSpawnProcess new 
					command: '/bin/echo';
					arguments: (Array with: '${WHATEVER}');
					environmentAt: 'WHATEVER' put: 'hello'.

	self shouldnt: [ command run ] raise: Error. 
	outputString := command stdoutStream upToEndOfFile.
	self assert: outputString trimmed equals: '${WHATEVER}'. 