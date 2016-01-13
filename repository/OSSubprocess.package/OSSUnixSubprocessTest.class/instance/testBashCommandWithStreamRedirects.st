tests - bash
testBashCommandWithStreamRedirects
	| stdOutContents | 

	self newCommand
		bashCommand: 'ps -fea | grep Pharo > /tmp/testBashCommandWithStreamRedirects.deleteme';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString isEmpty. 
			stdOutContents := '/tmp/testBashCommandWithStreamRedirects.deleteme' asFileReference readStreamDo: [ :str | str contents ] .
			self assert: (stdOutContents includesSubstring: 'Pharo').						
		].
	'/tmp/testBashCommandWithStreamRedirects.deleteme' asFileReference ensureDelete. 
		 
	
	
	