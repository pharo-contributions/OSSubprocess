tests - bash
testBashCommandWithStreamRedirects
	| command stdOutString stdOutContents | 
	
	command := OSSSpawnProcess new 
					bashCommand: 'ps -fea | grep Pharo > /tmp/testBashCommandWithStreamRedirects.deleteme ';
					createAndSetStdoutPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: stdOutString isEmpty. 
	stdOutContents := '/tmp/testBashCommandWithStreamRedirects.deleteme' asFileReference readStream contents.
	self assert: (stdOutContents includesSubstring: 'Pharo').	
	