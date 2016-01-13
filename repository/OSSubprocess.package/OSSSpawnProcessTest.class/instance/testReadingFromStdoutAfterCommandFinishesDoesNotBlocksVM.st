tests - streams
testReadingFromStdoutAfterCommandFinishesDoesNotBlocksVM
	| command customPipe | 
	customPipe := OSSSystemAccessor current makePipe.
	command := OSSSpawnProcess new
					command: '/bin/sleep';
					arguments: (Array with: '2');
					stdoutPipe: customPipe.
	self shouldnt: [ command run ] raise: Error. 
	command waitForChild.
	"Even with a blocking pipe, if the command has finished, we have
	all data ready to read and ehnce it's not blocking"
	self assert:[ command stdoutStream upToEndOfFile ] timeToRun seconds <= 1. 
	