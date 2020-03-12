tests - shell
testBasicShellCommandWithNonAsciiCharacters
	
	self withNonAsciiDirectoryDo: [ :dir |
		(dir / 'ok.txt') ensureCreateFile.
		self newCommand
			shellCommand: 'ls ', dir fullName;
			redirectStdout;
			runAndWaitOnExitDo: [ :command :outString |
				self assert: (outString includesSubstring: 'ok.txt').						
		]
	]