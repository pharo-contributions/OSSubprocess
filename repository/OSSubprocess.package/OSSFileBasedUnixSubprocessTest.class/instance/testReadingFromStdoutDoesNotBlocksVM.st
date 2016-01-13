tests
testReadingFromStdoutDoesNotBlocksVM
	| command customStream | 
	"With files, the reading from stdout does not lock the VM"
	customStream := OSSUnixSubprocess new createADefaultWriteStream.
	command := self newCommand
					command: '/bin/sleep';
					arguments: (Array with: '4');
					stdoutStream: customStream.
	
	command run. 
	self assert:[ command stdoutStream upToEnd ] timeToRun seconds <= 1. 
	