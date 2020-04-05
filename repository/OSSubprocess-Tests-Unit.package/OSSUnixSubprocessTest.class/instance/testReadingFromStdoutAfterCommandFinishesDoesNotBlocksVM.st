tests - streams
testReadingFromStdoutAfterCommandFinishesDoesNotBlocksVM
	| command streamsInfo | 
	
	"We set the sunit test timeout to 30 seconds.
	Otherwise default sunit test timeout is 10 seconds.
	This is for Pharo version >= 6.0"
	(self respondsTo: #timeLimit:) ifTrue: [ 
		self timeLimit: 30 seconds.
	].
	
	streamsInfo := self getStreamsInfoForRunningTest.
	command := self newCommand
					command: '/bin/sleep';
					arguments: (Array with: '1');
					redirectStdout;
					runAndWait.
					
	"Even with a blocking stream, if the command has finished, we have
	all data ready to read and hence it's not blocking"
	self assert:[ command stdoutStream upToEndOfFile ] timeToRun seconds <= 5. 
	command closeAndCleanStreams.
	self assertStreamsInfoWithPrevious: streamsInfo.
	

	