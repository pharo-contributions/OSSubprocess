"
OSSUnixSubprocess is the main interface for spwaning subprocesses in a Unix OS. 

A process consist at minimun of a program/command to be executed (a Unix binary..could be cat , ls, cp,  custom shell scripts, etc etc.  ) and an optional list of arguments that will be passed to that program.

This class also allows you to define streams  (either StandardFileStream or OSSPipe) that will be mapped to the underlying standard streams stdout/stderr/stdin. This way it provides an API for reading and writing from those. In addition, it takes care of opening, closing, cleaning and all the rest of streams operations. 

It also provides code for checking the status or waiting the exit of the OS process. Different strategies are supported (SIGCHLD based or delay polling). See the different methods in the protocol 'running'.' In addition, once the subprocess was started, the subprocess instance is registered in OSSVMProcess which takes care of handling the child death via the childWatcher. 

Some additional features involved env variable settings (environmentAt:put:) for the child, defining a working directory (#workingDirectory: ), facilities for shell commands, etc.

To achieve it's goals, this class relies on OSSUnixSystemAccessor for accessing Unix system calls. 

As for  implementation details to spwan processes this class relies on the posix_spwan() family of functions which we call via FFI. 

The following is ONE example of ONE possible usage. We define and set settings which are actually the default, so they wouldn't make sense..but just for showing the most of the API:

OSSUnixSubprocess new	
	command: 'ls';
	arguments: (Array with: Smalltalk image imagePath);
	defaultWriteStreamCreationBlock: [ OSSVMProcess vmProcess systemAccessor makeNonBlockingPipe ];
	redirectStdout; ""automatic default stream creation...above closure.""
	redirectStderrTo: '/tmp/stderrFile.txt' asFileReference writeStream; ""custom stream creation""
	createMissingStandardStreams: false; ""therefore won't create stdin stream""
	workingDirectory: '/home'; ""set working directory for child""
	environmentAt: 'HOME' put: '/tmp/home';
	addAllEnvVariablesFromParentWithoutOverride; ""we will inherit then all but $HOME""
	runAndWaitOnExitDo: [ :command :outString :errString |
		self assert: (outString includesSubstring: Smalltalk image imagePath).	
		self assert: command isSuccess.
		self assert: errString isEmpty. 
	]
	 




"
Class {
	#name : #OSSUnixSubprocess,
	#superclass : #Object,
	#instVars : [
		'command',
		'arguments',
		'pointers',
		'posixSpawnFileActionsT',
		'exitStatus',
		'envVariables',
		'stderrStream',
		'stdinStream',
		'stdoutStream',
		'createMissingStandardStreams',
		'defaultWriteStreamCreationBlock',
		'defaultReadStreamCreationBlock',
		'pid',
		'retrievedStdout',
		'retrievedStderr',
		'mutexForSigchld',
		'shouldContinueWaiting',
		'terminateOnShutdown',
		'workingDirectory',
		'waitPidCriticalSemaphore',
		'encoding'
	],
	#pools : [
		'LibCSignalSharedPool'
	],
	#category : #OSSubprocess
}

{ #category : #'temp files' }
OSSUnixSubprocess class >> createTempFileToBeUsedAsReadStreamOn: aDirectoryPath [
	"Important: for some reason, if we use MultiByteFileStream instances, we have some test failures.
	So for the moment, until we fix or understand this, always use StandardFileStream instances.
	
	This is a simple facility method if the user wants to use regular files rather than pipes.
	In the customization of defaultReadStreamCreationBlock: or defaultWriteStreamCreationBlock: 
	the user may want to use this method to automatically create a temp file on a aDirectoryPath.
	If you want another way of building temp files, then simply do not use this method and
	set the closure you want in defaultReadStreamCreationBlock: or defaultWriteStreamCreationBlock: 
	
	"
	
	^ OldStandardFileStream forceNewFileNamed: (aDirectoryPath asFileReference / self createTempFilename) fullName
]

{ #category : #'temp files' }
OSSUnixSubprocess class >> createTempFileToBeUsedAsWriteStreamOn: aDirectoryPath [
	"See comment of #createTempFileToBeUsedAsReadStreamOn:."
	^  OldStandardFileStream forceNewFileNamed: (aDirectoryPath asFileReference / self createTempFilename) fullName
]

{ #category : #'temp files' }
OSSUnixSubprocess class >> createTempFilename [
	"Read comment of createTempFileToBeUsedAsReadStreamOn:.
	
	This answers just ONE WAY of defining a temp filename"
	
	^ self name , '-p', OSSVMProcess vmProcess pid asString, '-', UUID new printString, '.deleteme'
	
]

{ #category : #'env building' }
OSSUnixSubprocess >> addAllEnvVariablesFromParentWithoutOverride [
	"The user may have done an explicit set of a variable via #environmentAt:put: in which case
	we do not want to override it with the inherit one.
	This method allows to set all but overriden variables inherit from parent. "
	self defaultEnvVariablesDictionary keysAndValuesDo: [ :key :value |
		envVariables at: key ifAbsentPut: value.
	]
	
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> allocatePosixSpawnFilesActionStructure [
	"IMPORTANT:  It seems posix_spawn_file_actions_init() sometimes allocates AND initializes, and sometimes only initializes.
	For OSX I found it it also allocates memory, so only allocating for the pointer is enough.
	For Linux it seems we need to allocate the full structure of posix_spawn_file_actions_t.
	Wathing at the implementation of GNU libc (glibc) here: http://osxr.org:8080/glibc/source/posix/spawn.h?v=glibc-2.17 
	I found this struct definition:
	
	typedef struct
	 {
	   int __allocated;
	   int __used;
	   struct __spawn_action *__actions;
	   int __pad[16];
	 } posix_spawn_file_actions_t;
	
	We need a better solution to solve this kind of sizeof(). For the moment, see below how I estimate the size of this struct.  
	For more details see thread 'Help with FFI crash in latest Spur (only in Linux)'
	"
	OSPlatform current isMacOSX ifTrue: [ posixSpawnFileActionsT := ExternalAddress allocate: self systemAccessor sizeOfPointer. ].
	OSPlatform current isUnix ifTrue: [ posixSpawnFileActionsT := ExternalAddress allocate: (self systemAccessor sizeOfPointer + (self systemAccessor sizeOfInt * 2) + (16 * self systemAccessor sizeOfInt)). ].
]

{ #category : #'argv building' }
OSSUnixSubprocess >> argVArguments [
	"Answers the whole list of argV including the command as the first argument and a
	null terminated."
	^ OrderedCollection new
		add: command;
		addAll: (arguments ifNil: [#()]);
		add: 0; "shell arguments are '\0' terminated"
		yourself
]

{ #category : #settings }
OSSUnixSubprocess >> arguments: anObject [
	arguments := anObject collect: [ :each | (each encodeWith: encoding) asString ]
]

{ #category : #'argv building' }
OSSUnixSubprocess >> buildPrimitiveArgVArgument [
	"Takes care of allocating and building the array of arguments as expected
	by the posix_spawn() function. 
	Answers the array ready to be used."
	| bufferPointer |
	bufferPointer := ExternalAddress allocate: self argVArguments size * self systemAccessor sizeOfPointer.
	self registerPointer: bufferPointer.
	self collectArgumentPointersInto: bufferPointer.
	 ^ bufferPointer
]

{ #category : #'env building' }
OSSUnixSubprocess >> buildPrimitiveEnvArgument [
	"Builds the whole env argument as expected by posix_spawn(), taking into account the variables
	defined by the API #environmentAt:put:"
	| envPointer |
	"By default, if none variable was set, we add all the ones existing in parent"
	envVariables isEmpty ifTrue: [ self addAllEnvVariablesFromParentWithoutOverride ].
	"The +1 is because we will have a NULL at the end"
	envPointer := ExternalAddress allocate: (envVariables keys size + 1) * self systemAccessor sizeOfPointer.
	self registerPointer: envPointer.
	self collectEnvVariablesPointersInto: envPointer.
	^ envPointer
]

{ #category : #cleaning }
OSSUnixSubprocess >> cleanAndFixCopiedStreams [
	"If the stream is a pipe, we must close the end that we do not use at VM level (parent).
	If we are using regular files, we must reopen them otherwise we won't be able to read what the
	child has written "
	stdinStream ifNotNil: [ stdinStream ossIsPipe ifTrue: [ stdinStream closeReader ] ifFalse: [ stdinStream reopen. ] ].
	stdoutStream ifNotNil: [ stdoutStream ossIsPipe ifTrue: [ stdoutStream closeWriter ] ifFalse: [ stdoutStream reopen. ] ].
	stderrStream ifNotNil: [ stderrStream ossIsPipe ifTrue: [ stderrStream closeWriter ] ifFalse: [ stderrStream reopen. ] ].
	 
]

{ #category : #cleaning }
OSSUnixSubprocess >> cleanResources [
	"Clear all resources. This step is mandatory and happens immeditaly after the process has 
	started. And this must be called even if there is an error, since we must free pointers,
	close streams, etc etc. "
	self destroyPosixSpawnFileActionsT.
	self cleanAndFixCopiedStreams.
	self freePointers.
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> closeAllButStandardFileStreams [
	"Here I should loop and close all but fd 0 1 2"

	"do a loop with #posixSpawnFileActionsAddClose:"
	
	self flag: #toDo
]

{ #category : #cleaning }
OSSUnixSubprocess >> closeAndCleanStreams [
	"This method closes all the streams that have been opened and mapped to standard steams.
	They could be either pipes or regular temp files. In the case of files, we also remove those temp files"
	self closeStreams.
	self deleteTempFilesFromStandardStreams.
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> closeAndDup2FilesActions [
	"First, it initializes the structure for managing the file actions allowed by posix_spwan(). 
	Then defines and sets all actions we want. That is, closing or opening file descriptors,
	or doing a dup2() "
	self initPosixSpawnFileActionsT.
	self closeAllButStandardFileStreams.
	self defineActionsForStandardFileStreams.
	
]

{ #category : #streams }
OSSUnixSubprocess >> closeStderrStream [
	" Close stderrStream if needed"
	stderrStream ifNotNil: [ stderrStream close ]
]

{ #category : #streams }
OSSUnixSubprocess >> closeStdinStream [
	" Close stdinStream if needed"
	stdinStream ifNotNil: [ stdinStream close ]
]

{ #category : #streams }
OSSUnixSubprocess >> closeStdoutStream [
	" Close stdoutStream if needed"
	stdoutStream ifNotNil: [ stdoutStream close ]
]

{ #category : #cleaning }
OSSUnixSubprocess >> closeStreams [
	"Closes all the streams that have been opened and mapped to standard steams."
	self closeStdinStream.
	self closeStdoutStream.
	self closeStderrStream.
	
]

{ #category : #'argv building' }
OSSUnixSubprocess >> collectArgumentPointersInto: aPointer [
	"Allocates each string argument with a null terminated char and add them into aPointer"
	
	"#allButLast is because the last is 0."
	self argVArguments allButLast withIndexDo: [ :string :index |
		| pointer | "0 terminated"
		pointer := ExternalAddress allocate: string size + 1.
		self registerPointer: pointer.
		LibC memCopy: string to: pointer size: string size.
		pointer uint8AtOffset: string size put: 0. "string terminating null char"
		aPointer platformUnsignedLongAt: ((index - 1) * self systemAccessor sizeOfPointer) + 1 put: pointer value ].

	aPointer platformUnsignedLongAt: ((self argVArguments size - 1) * self systemAccessor sizeOfPointer) + 1 put: 0.
]

{ #category : #'env building' }
OSSUnixSubprocess >> collectEnvVariablesPointersInto: aPointer [
	"Creates the pair of KEY=VALUE string, allocating the memory and adding a null terminated char to each of the env.
	Each processed pair of KEY=VALUE is added to aPointer. "
	envVariables keys withIndexDo: [ :aKey :index |
		| string pointer | 
		string := aKey trimmed , '=', (envVariables at: aKey) trimmed. 
		"The +1 is because string must be NULL terminated"
		pointer := ExternalAddress allocate: string size + 1.
		self registerPointer: pointer.
		LibC memCopy: string to: pointer size: string size.
		pointer uint8AtOffset: string size put: 0. "string terminating null char"
		aPointer platformUnsignedLongAt: ((index - 1) * self systemAccessor sizeOfPointer) + 1 put: pointer value
	].
	"The array of pointers also needs to finish with a NULL"
	aPointer platformUnsignedLongAt: (envVariables keys size * self systemAccessor sizeOfPointer) + 1 put: 0

]

{ #category : #settings }
OSSUnixSubprocess >> command: aString [
	command := (aString encodeWith: encoding) asString
]

{ #category : #streams }
OSSUnixSubprocess >> createADefaultReadStream [
	"Creates a default read stream, most likely for stdin"
	^ defaultReadStreamCreationBlock value
]

{ #category : #streams }
OSSUnixSubprocess >> createADefaultWriteStream [
	"Creates a default write stream, most likely for stdout or stderr"
	^ defaultWriteStreamCreationBlock value
]

{ #category : #settings }
OSSUnixSubprocess >> createMissingStandardStreams: aBoolean [
	"If we don't create streams for the standard streams of the child process,
	then the child will be used the inherit standard files from the parent. 
	
	If aBoolean is true, then we will automatically create streams for mapping stdout/stderr/stdin.
	Note that we will create streams ONLY for those standard streams that had not already been set by
	another parts of the API (like #redirectStdoutTo:, or #createAndSetStdeoutStream, etc.).
	In addition, the type of streams that we will automatically create is defined by defaultReadStreamCreationBlock
	and defaultWriteStreamCreationBlock. So you can customize that to define the type of stream automatically created. 
	
	"
	createMissingStandardStreams := aBoolean
	
]

{ #category : #accessing }
OSSUnixSubprocess >> defaultEncoding [ 
	^ OSEnvironment current defaultEncoding 
]

{ #category : #'env building' }
OSSUnixSubprocess >> defaultEnvVariablesDictionary [
	"Get all the env vars inherit from the vmProcess as a dictionary"
	^ Smalltalk os environment asDictionary
]

{ #category : #settings }
OSSUnixSubprocess >> defaultReadStreamCreationBlock: aClosure [
	"Read the comment of #createMissingStandardStreams:"
	defaultReadStreamCreationBlock := aClosure
]

{ #category : #settings }
OSSUnixSubprocess >> defaultWriteStreamCreationBlock: aClosure [
	"Read the comment of createMissingStandardStreams:"
	defaultWriteStreamCreationBlock := aClosure
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> defineActionsForReadStream: aReadStream dupTo: aFileDescriptor [
	"Sets all needed actions (close() and dup2()) for a aReadStream (stdin) FOR THE CHILD.
	"
	aReadStream ifNotNil: [ 
		aReadStream ossIsPipe 
			ifTrue: [  
				"For pipes, in the child, we close write end (the child will read), 
				then dup2 the reader to stdin, and then close the reader too. "
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aReadStream writer basicFileID).
				self posixSpawnFileActionsAddDup2: (self systemAccessor primUnixFileNumber: aReadStream reader basicFileID) newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aReadStream reader basicFileID).	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aReadStream. 
				"For regular files, in the child, we dup2 the reader to stdin, and then close the reader too. "
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> defineActionsForStandardFileStreams [
	"Define close() and dup2() actions for standard file streams for the child process"
	self defineActionsForStdin.
	self defineActionsForStdout.
	self defineActionsForStderr.
		
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> defineActionsForStderr [
	"If needed, automatically create a stream (regular files or pipes) to be used for stderr, and then perform the needed close() and dup2()
	for the mapping in the child"
	self shouldCreateStreamFor: stderrStream ifTrue: [ self redirectStderr ].
	self defineActionsForWriteStream: stderrStream dupTo: 2
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> defineActionsForStdin [
	"If needed, automatically create a stream (regular files or pipes) to be used for stdin, and then perform the needed close() and dup2()
	for the mapping in the child"
	self shouldCreateStreamFor: stdinStream ifTrue: [ self redirectStdin ].
	self defineActionsForReadStream: stdinStream dupTo: 0
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> defineActionsForStdout [
	"If needed, automatically create a stream (regular files or pipes) to be used for stdout, and then perform the needed close() and dup2()
	for the mapping in the child"
	self shouldCreateStreamFor: stdoutStream ifTrue: [ self redirectStdout ].
	self defineActionsForWriteStream: stdoutStream dupTo: 1
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> defineActionsForWriteStream: aWriteStream dupTo: aFileDescriptor [
	"Sets all needed actions (close() and dup2()) for a aWriteStream (stdout or stderr) FOR THE CHILD
	"
	aWriteStream ifNotNil: [ 
		aWriteStream ossIsPipe 
			ifTrue: [  
				"For pipes, in the child, we close read end (the child will write), 
				then dup2 the writer to stderr or stdout, and then close the writer too. "
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aWriteStream reader basicFileID).
				self posixSpawnFileActionsAddDup2: (self systemAccessor primUnixFileNumber: aWriteStream writer basicFileID) newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aWriteStream writer basicFileID).	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aWriteStream. 
				"For regular files, in the child, we dup2 the writer to stdout or stderr, and then close the writer too. "
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]
]

{ #category : #cleaning }
OSSUnixSubprocess >> deleteTempFileOf: aStream [
	"Deletes the temp file associated to aStream"
	aStream ifNotNil: [ 
		aStream ossIsPipe ifFalse: [ aStream fullName asFileReference ensureDelete ] 
	]
	


]

{ #category : #cleaning }
OSSUnixSubprocess >> deleteTempFilesFromStandardStreams [
	"Delete all temp files that were associated to standard streams."
	self deleteTempFileOf: stdinStream.
	self deleteTempFileOf: stdoutStream.
	self deleteTempFileOf: stderrStream.
	
	


]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> destroyPosixSpawnFileActionsT [
	"This is part of the needed API of posix_spawn() family of functions and dismply destroys
	the struct initialized by #initPosixSpawnFileActionsT"
	posixSpawnFileActionsT ifNotNil: [ 
		| returnValue |
		returnValue := self primitivePosixSpawnFileActionsDestroy: posixSpawnFileActionsT. 
		returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_distroy()'. ].	
	].
]

{ #category : #settings }
OSSUnixSubprocess >> encoding: anEncoder [
	"Specify the encoder to use to encode/decode Strings given to/retrieved from the process.
	Default encoding for Unix-like systems is UTF-8".
	" self encoding: #utf8 "
	encoding := anEncoder
]

{ #category : #'env building' }
OSSUnixSubprocess >> envVariables [
	^ envVariables
]

{ #category : #'env building' }
OSSUnixSubprocess >> environmentAt: aVariableName put: aValue [
	"This is the expected API to allow users to define custom variables and values."
	(aVariableName isString and: [ aValue isString ])
		ifFalse: [ self error: 'Variable names and values must be strings' ].
	envVariables at: aVariableName put: aValue
]

{ #category : #status }
OSSUnixSubprocess >> exitStatus [
	"Answers the bit field integer representing the exit status exactly as returned from #queryExitStatus (waitpid()). "
	^ exitStatus
]

{ #category : #status }
OSSUnixSubprocess >> exitStatusInterpreter [
	"#exitStatus answers the bit field integer representing the exit status exactly as returned from #queryExitStatus (waitpid()).
	However, sometimes you want to decode the internal meaning of the integer to get more information about the status. 
	For those purposes, you can use this method and then query the result. 
	For more details, read class comment of OSSUnixProcessExitStatus "
	^ OSSUnixProcessExitStatus for: exitStatus
]

{ #category : #'private - support primitives' }
OSSUnixSubprocess >> ffiLibraryName [ 
	^ LibC
]

{ #category : #'pointers management' }
OSSUnixSubprocess >> freePointers [
	"Frees all registered pointers. This must be called just after process is launched whether it
	was successful or not to avoid memory leaks... Also, all users of FFI #allocate: kind of method
	should either explicitly send #free (inside a ensure:) or register the allocated pointer so that 
	it can be free here."
	self pointers do: [ :pointer | pointer free ].
	pointers := nil
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> getFdFromStream: aStream [
	^ self systemAccessor fileno: aStream getFilePointerAsCFile
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> initPosixSpawnFileActionsT [
	"This is part of the needed API of posix_spawn() family of functions and initializes
	the struct posix_spawn_file_actions_t"
	| returnValue |
	self allocatePosixSpawnFilesActionStructure.
	self registerPointer: posixSpawnFileActionsT.
	returnValue := self primitivePosixSpawnFileActionsInit: posixSpawnFileActionsT. 
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_init()' ].
]

{ #category : #'initialize - release' }
OSSUnixSubprocess >> initialize [
	super initialize.
	envVariables := Dictionary new. 
	createMissingStandardStreams := false.
	"By default, we create a none blocking pipe for writers (stdout and stderr). For reader, we prefer blocking pipes (stdin), otherwise the child will exit quickly. We also allow regular StandardFileStreams instances."
	defaultReadStreamCreationBlock := [self systemAccessor makeBlockingPipe].
	defaultWriteStreamCreationBlock := [self systemAccessor makeNonBlockingPipe].
	retrievedStdout := String new writeStream. 
	retrievedStderr := String new writeStream. 
	terminateOnShutdown := false.
	waitPidCriticalSemaphore := Semaphore forMutualExclusion.
	encoding := self defaultEncoding.

]

{ #category : #running }
OSSUnixSubprocess >> internalRun [
	"This is the real method that spwans the subprocess in the OS via the posix_spawn() function. 
	It first must deal with all the file acctions for close() and dup() in the child.
	Then spawns the process and sets the pid. 
	Finally, it registers the process in the OSSVMProcess vmProcess (so that the childWatcher considers this child).
	After this method is sent, we have to be sure to free resources (via #cleanResources)
	"
	
	| pidtPointer returnValue   |
	pidtPointer := ExternalAddress allocate: self systemAccessor sizeOfPointer.
	self registerPointer: pidtPointer.
	self closeAndDup2FilesActions.
	workingDirectory 
		ifNil: [ returnValue := self primitivePosixSpawn: pidtPointer command: command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument. ] 
		ifNotNil: [ 
			"This is a hack in order to support a #workingDirectory: kind of feature. 
			Please read the comment of lockCwdWithValue:during: "
			OSSVMProcess vmProcess
				lockCwdWithValue: workingDirectory
				encoding: encoding identifier
				during: [ returnValue := self primitivePosixSpawn: pidtPointer command: command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument. ]
		].
	(returnValue > 0) 
		ifTrue: [ self systemAccessor strerror: returnValue message: 'posix_spawn()'. ].
		
	"Pid is of type pid_t, which is mostly 32bits even in 64bit platforms"
	pid := pidtPointer unsignedLongAt: 1.
	OSSVMProcess vmProcess registerChildProcess: self.
	
]

{ #category : #status }
OSSUnixSubprocess >> isComplete [
	"Answers whether the process has been completed or not (to our best knowledge)"
	^ exitStatus notNil
]

{ #category : #status }
OSSUnixSubprocess >> isRunning [
	"Answers whether the process is still running or not (to our best knowledge)"
	^ pid notNil and: [ self isComplete not ]
]

{ #category : #status }
OSSUnixSubprocess >> isSuccess [
	"Answers whether the process has been completed successfuly (to our best knowledge)"
	^ self isComplete and: [ self exitStatusInterpreter exitStatus = 0 ]
]

{ #category : #terminating }
OSSUnixSubprocess >> kill [
	^ self sigkill
]

{ #category : #shell }
OSSUnixSubprocess >> loginShellCommand: aShellCommandString [
	"This is a simple facility method for the cases when the user wants to use a login shell as the program.
	See comments of shellCommand: for more information."
	self shellCommand: aShellCommandString.
	arguments := Array with: '-l' withAll: arguments.
]

{ #category : #accessing }
OSSUnixSubprocess >> pid [

	^ pid
]

{ #category : #'pointers management' }
OSSUnixSubprocess >> pointers [
	^ pointers ifNil: [ pointers := Set new ]
]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> posixSpawnFileActionsAddClose: aFileDescriptor [
	"Add a close() action for aFileDescriptor for the child process"
	| returnValue |
	returnValue := self primitivePosixSpawnFileActionsAddClose: posixSpawnFileActionsT fileDescription: aFileDescriptor.
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_adddclose()' ].
	^ returnValue


]

{ #category : #'close and dup2' }
OSSUnixSubprocess >> posixSpawnFileActionsAddDup2: oldFileDescription newFileDescritpion: newFileDescription [
	"Add a dup2() action for from oldFileDescription to newFileDescription, for the child process"
	| returnValue |
	returnValue := self primitivePosixSpawnFileActionsAddDup2: posixSpawnFileActionsT oldFileDescription: oldFileDescription newFileDescritpion: newFileDescription.
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_adddup2()' ].
	^ returnValue


]

{ #category : #'private - primitives' }
OSSUnixSubprocess >> primitivePosixSpawn: pidPointer command: commandString fileActions: fileActions attributes: attributes argPointer: argPointer envPointer: envPointer [

	 ^ self ffiCall: #( int posix_spawnp (void* pidPointer, String commandString, void* fileActions, void * attributes, void* argPointer, void* envPointer) ) 
				
]

{ #category : #'private - primitives' }
OSSUnixSubprocess >> primitivePosixSpawnFileActionsAddClose: fileActions fileDescription: fileDescriptionNumber [
	
	^ self ffiCall: #( int posix_spawn_file_actions_addclose ( void* fileActions, int fileDescriptionNumber) )
]

{ #category : #'private - primitives' }
OSSUnixSubprocess >> primitivePosixSpawnFileActionsAddDup2: fileActions oldFileDescription: oldFileDescription newFileDescritpion: newFileDescription [ 

	 ^ self ffiCall: #( int posix_spawn_file_actions_adddup2 ( void* fileActions, int oldFileDescription, int newFileDescription ) )
]

{ #category : #'private - primitives' }
OSSUnixSubprocess >> primitivePosixSpawnFileActionsDestroy: aPosixSpawnFileActionsT [ 
	
	^ self ffiCall: #( int posix_spawn_file_actions_destroy(void*  aPosixSpawnFileActionsT) )
	



]

{ #category : #'private - primitives' }
OSSUnixSubprocess >> primitivePosixSpawnFileActionsInit: aPosixSpawnFileActionsT [ 
	
	^ self ffiCall: #( int posix_spawn_file_actions_init(void* aPosixSpawnFileActionsT) )
	

]

{ #category : #printing }
OSSUnixSubprocess >> printOn: aStream [

	aStream
		nextPutAll: self class name asString;
		nextPut: $(;
		nextPutAll: 'Command: ';
		nextPutAll: command asString;
		nextPutAll: '; Pid: ';
		nextPutAll: pid asString;
		nextPutAll: '; Status: ';
		nextPutAll: self exitStatusInterpreter asString;
		nextPut: $)
]

{ #category : #status }
OSSUnixSubprocess >> processHasExitNotification [
	"This method is called from the OSSVMProcess when its child watcher detects that this process has
	exited (via the receive of SIGCHLD) and so it notifies to it (via #updateActiveChildrenAndNotifyDead).
	We signal mutexForSigchld so that the #runAndWait can now finish.
	Note that the mutexForSigchld could be nil if the waitForExit API was not used"
	mutexForSigchld ifNotNil: [ mutexForSigchld signal ]
]

{ #category : #status }
OSSUnixSubprocess >> queryExitStatus [

	^ exitStatus
]

{ #category : #streams }
OSSUnixSubprocess >> redirectStderr [
	"Creates a default stream and set it as stderr. 
	This method can be called directly by the user to note that he wants to map that standard stream,
	or by our own if createMissingStandardStreams is true."
	stderrStream := self createADefaultWriteStream 
]

{ #category : #streams }
OSSUnixSubprocess >> redirectStderrTo: aStream [
	stderrStream := aStream
]

{ #category : #streams }
OSSUnixSubprocess >> redirectStdin [
	"Creates a default stream and set it as stdin. 
	This method can be called directly by the user to note that he wants to map that standard stream,
	or by our own if createMissingStandardStreams is true."
	
	stdinStream := self createADefaultReadStream 
]

{ #category : #streams }
OSSUnixSubprocess >> redirectStdinTo: aStream [
	stdinStream := aStream
]

{ #category : #streams }
OSSUnixSubprocess >> redirectStdout [
	"Creates a default stream and set it as stdout. 
	This method can be called directly by the user to note that he wants to map that standard stream,
	or by our own if createMissingStandardStreams is true."
	
	stdoutStream := self createADefaultWriteStream 
]

{ #category : #streams }
OSSUnixSubprocess >> redirectStdoutTo: aStream [
	stdoutStream := aStream
]

{ #category : #'pointers management' }
OSSUnixSubprocess >> registerPointer: aPointer [
	"Register a pointer so that it is free automatically in #freePointers"
	self pointers add: aPointer
]

{ #category : #streams }
OSSUnixSubprocess >> retrieveWhatIsAvailableOn: aStream andAddItTo: accumulatingStream [
	"This is an internal method which should only be used IF the user will NOT
	retrieve contents himself from streams while the process is still running.
	The usecase of this method is #runAndWaitOnExitDo: and #waitForExitPollingEvery:retrievingStreams:
	in which we are sure the user will not be reading from the streams. 
	What this method does is to simply get what is available in aStream and write it in  accumulatingStream, which is 
	the one we are using for appending contents (so that it is available all togther when the process has exited)
	This is important because for example, for pipes, you cannot read something twice as you consume what you read. 
	
	 "
	aStream 
		ifNotNil: [ :str | 
			accumulatingStream nextPutAll: str upToEnd 
		].
]

{ #category : #running }
OSSUnixSubprocess >> run [
	"Main method for spwaning the process. It starts the subprocess, it cleans the needed resources for that, and answers,
	it does not wait for child. There are others high end API for running the process,
	but they will all end up sending this message for starting the subprocess."
	[ self internalRun ] ensure: [ 
		self cleanResources.
	]
]

{ #category : #running }
OSSUnixSubprocess >> runAndWait [
	"IMPORTANT: read first the comment of #waitForExit.
	
	This methods runs the subprocess AND waits until the child has exited. 
	"
	self run.
	self waitForExit.
	
]

{ #category : #running }
OSSUnixSubprocess >> runAndWaitOnExitDo: anExitClosure [
	"This is a high end API for #runAndWait. IMPORTANT: read the comment in #runAndWait to know when to use this API.
	The facility this method adds over #runAndWait is that when the process has finished it:
	1) Retrieves all contents from stdout and stderr (if they were defined)
	2) It automatically closes the streams mapped to stdout/stderr (if defined)
	3) It allows you to plug anExitClosure which will be evaluated with this subprocess and the contents of stdout and stderr. 
	
	With this method, the user does not need to do anything else. 
	"
	self run.
	self waitForExit.
	self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
	self retrieveWhatIsAvailableOn: stderrStream andAddItTo: retrievedStderr.
	self closeAndCleanStreams.
	anExitClosure cull: self cull: retrievedStdout contents cull: retrievedStderr contents.
	
]

{ #category : #running }
OSSUnixSubprocess >> runAndWaitPollingEvery: aDelay doing: aClosure onExitDo: onExitClosure [
	"IMPORTANT: first read the comment of #waitForExitPollingEvery:doing:
	
	This method runs the subprocess, then waits for it doing an image-based delay polling. 
	It does not automatically retrieve from streams nor closes them on exit. 
	The user must explicitly read from streams in aClosure otherwise it might 
	have the problem mentioned in the comment of #waitForExit.
	The user must also close streams at some point. Either inside the #onExitClosure
	or later, but should be done. 
		 
	"
	self run.
	self waitForExitPollingEvery: aDelay doing: aClosure.
	onExitClosure cull: self cull: stdoutStream cull: stderrStream.
	
]

{ #category : #running }
OSSUnixSubprocess >> runAndWaitPollingEvery: aDelay retrievingStreams: retrieveStreams onExitDo: onExitClosure [
	"IMPORTANT: first read the comment of #waitForExitPollingEvery:retrievingStreams:
	
	This method runs the subprocess, then waits for it doing an image-based delay polling. 
	If retrieveStreams is true, then as part of the polling loop, it also reads from the streams and
	appends the intemediate results in retrievedStdout / retrievedStderr. 
	Once the process has finished we evaluate onExitClosure.
	If retrieveStreams was true, before evaluating onExitClosure, we automatically close streams
	so that there is nothing else to be done for the user, and we also pass as arguments the
	retrievedStdout / retrievedStderr  to the closure.
	
	With this method, the user does not need to do anything else. 
	 
	"
	self run.
	self waitForExitPollingEvery: aDelay retrievingStreams: retrieveStreams.
	retrieveStreams 
		ifTrue: [ 
			self closeAndCleanStreams.
			onExitClosure cull: self cull: retrievedStdout contents cull: retrievedStderr contents.
		]
		ifFalse: [ 
			onExitClosure cull: self.
		]
	
	
]

{ #category : #status }
OSSUnixSubprocess >> setExitStatus: aStatus [
	"This method set's the current process exit status.
	If exitStatus was already set it will fail.
	
	This method is synchronized to avoid race conditions on the access to the exit status"
	waitPidCriticalSemaphore critical: [
		exitStatus ifNotNil: [ self error: 'Modification not allowed' ].
		exitStatus := aStatus
	]
		
]

{ #category : #shell }
OSSUnixSubprocess >> shell: aShellPath command: aShellCommandString [
	"Please read comment of #shellCommand:.
	This is the same as shellCommand: but with the addition that the use can define which shell to be used via 'aBasePath' "
	command := aShellPath.
	arguments := Array with: '-c' with: (aShellCommandString encodeWith: encoding) asString. 
]

{ #category : #shell }
OSSUnixSubprocess >> shellCommand [
	"We first try to use the SHELL defined in the OS by getting the env variable $SHELL. 
	If not found, then we fallback to /bin/sh"
	^ Smalltalk platform environment at: 'SHELL' ifAbsent: ['/bin/sh']
]

{ #category : #shell }
OSSUnixSubprocess >> shellCommand: aShellCommandString [
	"This is a simple facility method for the cases when the user wants to use shell as the program.
	This way, the user can directly send shellCommand: 'ls -la | grep Pharo > /tmp/test.txt ' with the whole string 
	rather than having to do set the command sh, send the '-c' argument, etc etc etc.
	We first try to use the SHELL defined in the OS by getting the env variable $SHELL. 
	If not found, then we fallback to /bin/sh"
	
	self shell: self shellCommand command: aShellCommandString. 
]

{ #category : #streams }
OSSUnixSubprocess >> shouldCreateStreamFor: aStream ifTrue: aBlock [
	"Internal method. 
	If aStream was not specified explicitly by the user, but createMissingStandardStreams is true,
	then it evaluates aBlock"
	(aStream isNil and: [ createMissingStandardStreams ]) 
		ifTrue: [ aBlock value ]
]

{ #category : #'system startup & shutdown' }
OSSUnixSubprocess >> shutDown: quitting [
	" IMPORTANT: read first the comment of OSSVMProcess >> shutDown:
	This method is called if this process is still running at the time a 'Quit image' is happening 
	in Pharo. If terminateOnShutdown is true, then we simply terminate the process via sigterm
	and collect it exit status.
	If it false, then we simply stop waiting for it, and allow to finish at OS level
	(althought it may become orphan process as the parent will be die).
	"
	quitting ifTrue: [ 
		terminateOnShutdown 
			ifTrue: [ 
				self terminate.
				"To avoid problems..let's wait until we have the	exit status"
				self waitForExitPolling.
			]
			ifFalse: [ self stopWaiting ]
	] 
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigabrt [
	"Send a SIGABRT signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGABRT
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigalrm [
	"Send a SIGALRM signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGALRM
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigchld [
	"Send a SIGCHLD signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGCHLD
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigcont [
	"Send a SIGCONT signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGCONT
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sighup [
	"Send a SIGHUP signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGHUP
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigint [
	"Send a SIGINT signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGINT
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigkill [
	"Send a SIGKILL signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGKILL
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigpipe [
	"Send a SIGPIPE signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGPIPE
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigquit [
	"Send a SIGQUIT signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGQUIT
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigstop [
	"Send a SIGSTOP signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGSTOP
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigterm [
	"Send a SIGTERM signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGTERM
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigusr1 [
	"Send a SIGUSR1 signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGUSR1
]

{ #category : #'OS signal sending' }
OSSUnixSubprocess >> sigusr2 [
	"Send a SIGUSR2 signal to the external process represented by self"

	^ self systemAccessor kill: self pid signal: SIGUSR2
]

{ #category : #streams }
OSSUnixSubprocess >> stderrStream [
	^ stderrStream
]

{ #category : #streams }
OSSUnixSubprocess >> stdinStream [
	^ stdinStream
]

{ #category : #streams }
OSSUnixSubprocess >> stdoutStream [
	^ stdoutStream
]

{ #category : #waiting }
OSSUnixSubprocess >> stopWaiting [
	"This will work only for the High Methods API that rely in the waiting provided by the framework. If the user
	user custom waiting, this won't work.
	The wait inside this framework could be done either from #waitForExit with mutexForSigchld or via  #waitForExitPollingEvery:doing:
	with the delay polling"
	mutexForSigchld ifNotNil: [ mutexForSigchld signal ].
	(shouldContinueWaiting = true) ifTrue: [ shouldContinueWaiting := false. ] 
	
]

{ #category : #accessing }
OSSUnixSubprocess >> systemAccessor [ 

	^ OSSVMProcess vmProcess systemAccessor
]

{ #category : #terminating }
OSSUnixSubprocess >> terminate [
	^ self sigterm
]

{ #category : #'system startup & shutdown' }
OSSUnixSubprocess >> terminateOnShutdown [
	" IMPORTANT: read first the comment of OSSVMProcess >> shutDown:
	If terminateOnShutdown is true, then the external process will be terminated if it was still
	running at the time a system quit image is happening.
	If false, then we will simply stop waiting for it and allow it to finish (thought it will likely become a orphan).
	"
	terminateOnShutdown := true
]

{ #category : #waiting }
OSSUnixSubprocess >> waitForExit [
	"The waiting in this case is efficient since it is NOT done with a delay polling but using the SIGCHLD handler of OSSVMProcess childWatcher. The childWatcher when received a SIGCHLD will detect the child 
	that died and will send #processHasExitNotification to such a child. 
	In #processHasExitNotification the child will signal this 'mutexForSigchld' and hence
	make the #waitForExit to proceed.  
	
	IMPORTANT: This kind of waiting could generate a deadlock when the user uses pipes 
	for mapping standard streams and the child writes a lot of stuff into it. Basically, there is a problem in
	general with waiting for an external process to exit before reading its output. If the external process 
	creates a large amount of output, and if the output is a pipe, it will block on writing to the pipe until
	 someone (our VM process) reads some data from the pipe to make room for the writing. That leads to cases where 
	we never read the output (because the external process did not exit) and the external process never exits 
	(because we have not read the data from the pipe).
	
	
	Therefore, use this method (and all its senders) only when using FileStreams for the standard streams, 
	when not defining standard streams at all, or when you know the command to be executed does not write much in stdout/stderr."

	exitStatus ifNotNil: [ ^ exitStatus ].

	mutexForSigchld := Semaphore new.
	mutexForSigchld wait. 
	^ exitStatus  
]

{ #category : #waiting }
OSSUnixSubprocess >> waitForExitPolling [
	"Read the comment of waitForExitPollingEvery:retrievingStreams:"
	^ self waitForExitPollingEvery: (Delay forMilliseconds: 50)
]

{ #category : #waiting }
OSSUnixSubprocess >> waitForExitPollingEvery: aDelay [ 
	"Read the comment of waitForExitPollingEvery:retrievingStreams:"
	^ self waitForExitPollingEvery: aDelay retrievingStreams: true
]

{ #category : #waiting }
OSSUnixSubprocess >> waitForExitPollingEvery: aDelay doing: aClosure [
	" IMPORTANT: read first the comment of #waitForExit. 
	
	This method does NOT use #runAndWait nor #waitForExit. Instead, it does an image-based polling to check status of child process. 
	Note that the loop does send #queryExitStatus which is the method that indeeds does the waitpid() to check it.
	This is not strictly necessary because the childWatcher of the OSSVMProcess
	takes care of capturing SIGCHDL and update exitStatus. 
	However, as a more reliable solution, we can also check exit status here in case there are missed SIGCHLD or whatever.
	
	As part of the loop, besides checking the exit status (#queryExitStatus) it also evaluates aClosure
	
	"
	shouldContinueWaiting := true.
	[
		"If the #shutDown: (shouldContinueWaiting was set to false) happened while this process was in the #wait 
		 then we simply check 'shouldContinueWaiting' here before doing the #queryExitStatus"
		shouldContinueWaiting 
			ifTrue: [ self queryExitStatus ]
			ifFalse: [ ^ nil ].
		"nil answer means the child has not yet finished" 
		(exitStatus isNil and: [ shouldContinueWaiting ])
	]
	whileTrue: [ 
		aDelay wait.
		aClosure cull: self cull: stdoutStream cull: stderrStream.
	].
	"We might have more contents in the streams that could have been written since the last 'aClosure value' and the moment #queryExitStatus answers non nil.
	So just in case we execute aClosure one more time"
	shouldContinueWaiting 
		ifTrue: [ aClosure cull: self cull: stdoutStream cull: stderrStream. ].
	^ exitStatus  
]

{ #category : #waiting }
OSSUnixSubprocess >> waitForExitPollingEvery: aDelay retrievingStreams: retrieveStreams [
	" IMPORTANT: read first the comment of #waitForExit. 
	Second, read the comment of #waitForExitPollingEvery:doing:
	
	If retrieveStreams is true, we read from stdout/stderr as part of the loop and
	append the answers in retrievedStdout / retrievedStderr.
	And this solves the deadlock mentioned in #waitForExit.
	
	This method (with retrieveStreams in true) should be used when mapping stdout / stderr with pipes
	and the command to be executed may write a lot to it. Does not make much sense to be used with regular files. 
	
	Answers the exit status of the child."
	^ self 
		waitForExitPollingEvery: aDelay
		doing: [ 
			retrieveStreams ifTrue: [ 
				self retrieveWhatIsAvailableOn: stdoutStream andAddItTo: retrievedStdout.
				self retrieveWhatIsAvailableOn: stderrStream andAddItTo: retrievedStderr.
			]
		] 
	
]

{ #category : #waiting }
OSSUnixSubprocess >> waitForExitWithTimeout: aDuration [
	"The waiting in this case is efficient since it is NOT done with a delay polling but using the SIGCHLD handler of OSSVMProcess childWatcher. The childWatcher when received a SIGCHLD will detect the child 
	that died and will send #processHasExitNotification to such a child. 
	In #processHasExitNotification the child will signal this 'mutexForSigchld' and hence
	make the #waitForExit to proceed.  
	
	IMPORTANT: This kind of waiting could generate a deadlock when the user uses pipes 
	for mapping standard streams and the child writes a lot of stuff into it. Basically, there is a problem in
	general with waiting for an external process to exit before reading its output. If the external process 
	creates a large amount of output, and if the output is a pipe, it will block on writing to the pipe until
	 someone (our VM process) reads some data from the pipe to make room for the writing. That leads to cases where 
	we never read the output (because the external process did not exit) and the external process never exits 
	(because we have not read the data from the pipe).
	
	
	Therefore, use this method (and all its senders) only when using FileStreams for the standard streams, 
	when not defining standard streams at all, or when you know the command to be executed does not write much in stdout/stderr."

	| expired |
	exitStatus ifNotNil: [ ^ exitStatus ].

	mutexForSigchld := Semaphore new.
	expired := mutexForSigchld waitTimeoutMSecs: aDuration asMilliSeconds.
	expired ifTrue: [ OSSTimeout signal: 'Process not finished after ', aDuration asString ].
	^ exitStatus  
]

{ #category : #settings }
OSSUnixSubprocess >> workingDirectory: aString [
	"This is a setting that allows defining a working directory for the OS process once started."
	"Working directory is not encoded when set because it is used as FileReference at some places.
	Instead, we encode it in #lockCwdWithValue:encoding:during:"
	workingDirectory := aString
]
