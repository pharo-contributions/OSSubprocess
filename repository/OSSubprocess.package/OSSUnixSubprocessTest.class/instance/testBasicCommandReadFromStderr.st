tests - streams
testBasicCommandReadFromStderr
	| numberOfOpenFiles |
	numberOfOpenFiles := self numberOfOpenFiles.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: '-' with: 'foo');
		createAndSetStderrStream;
		runAndWaitOnExitDo: [ :command :outString :errString |
			self assert: (errString includesSubstring: 'foo: No such file or directory').
			self assert: command stdoutStream isNil.
			self assert: command stderrStream closed.
			self assert: self numberOfOpenFiles equals: numberOfOpenFiles	
		].
	
	