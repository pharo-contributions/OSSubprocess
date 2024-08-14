"
OSSUnixSystemAccessor provides access to the operating system in which the Pharo VM is currently running.  There is only one instance of this class, holded by 'OSSVMProcess vmProcess'  which depends on it  to provide access to the operating system process which they represent.

This class provides GENERAL funcionallity for managing files, errors, environments variables, waiting calls, etc etc. Ideally, 100% of its functionallity should be implemented via FFI calls. However, we still use some OSProcess primitives which would be a bit complicaated to implement via FFI (mostly because they access macros, or constants, or things related to a the C pre-processor that we do not have at FFI level). 

The functionallity that is NOT GENERAL (like the call to posix_spawn() family of functions), should not be here but in the concrete place such as OSSUnixSubprocess. 

For the parts that are based on FFI calls, we split each call in two sides. The first side is the method that does the FFI call (under a 'XXX - primitives' protocol, for example, #primitiveFileno:). The other side, is wrapper method that calls the primitive internally but also takes care about managing possible errors of it, informing those, etc (for example, #fileno:). Therefore, is very much likely that the ""code users"" of this class, will be using the latter side (wrappers) of the methods and not the primitive ones.

!! Management of dead processes

New processes are created as childs of the current process. The method #waitpidNoHang: is used to query the exit status of processes.
However, since we use the waitpid() function using WNOHANG, it returns a finished process id that is not necessarily the one that is asked for.
Becayse of this, the Accessor contains a map of process exit statuses.
If the asked process is the one returned by waitpid, we return the corresponding exit status, otherwise we store that value in the map for later accesses.
"
Class {
	#name : 'OSSUnixSystemAccessor',
	#superclass : 'Object',
	#instVars : [
		'finishedChildProcesses'
	],
	#classVars : [
		'VMProcessSystemAcessor'
	],
	#pools : [
		'LibCWaitSharedPool'
	],
	#category : 'OSSubprocess',
	#package : 'OSSubprocess'
}

{ #category : 'instance creation' }
OSSUnixSystemAccessor class >> forVMProcess [
	^ VMProcessSystemAcessor ifNil: [ VMProcessSystemAcessor := self basicNew initialize ]

]

{ #category : 'instance creation' }
OSSUnixSystemAccessor class >> new [

	self error: 'You cannot create instances of OSSUnixSystemAccessor. You can only access the correct instance via OSSVMProcess >> systemAccessor '.

]

{ #category : 'cwd' }
OSSUnixSystemAccessor >> chdir: aDirString encoding: encoding [
	"Changes the current working directory of the vmProcess to aDirString"
	| returnValue | 
	returnValue := self primitiveChdir: aDirString encoding: encoding.
	(returnValue = -1) ifTrue: [ self perror: 'chdir()' ].
	(returnValue = 0) ifFalse: [ self error: 'Unexpected return value from chdir() ', returnValue printString ].
	
]

{ #category : 'files' }
OSSUnixSystemAccessor >> closeFileDescriptor: aFileDescription [
	"It closes the stream associated to aFileDescriptor"
	| returnValue |
	returnValue := self primitiveClose: aFileDescription.
	(returnValue = -1) ifTrue:  [ self perror: 'close()' ].
	^ returnValue

]

{ #category : 'files' }
OSSUnixSystemAccessor >> feof: aCFile [
	"Answers whether a FILE* is at the end of the file or not. This is trustful for pipes too"
	| result |
	result := self primitiveFeof: aCFile.
	^ result ~= 0
	

]

{ #category : 'private - support primitives' }
OSSUnixSystemAccessor >> ffiLibraryName [ 
	^ LibC 
]

{ #category : 'files' }
OSSUnixSystemAccessor >> fflush: aCFile [
	"Flushes the file associated to the FILE* represented by aCFile"
	| returnValue |
	aCFile ifNil: [ self error: 'We disallow the fflush() of nil files since it will flush all open output streams' ].
	returnValue := self primitiveFflush: aCFile.
	(returnValue = 0) ifFalse: [ self perror: 'fflush()' ].
	
]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> fileDescriptorOpen: aFileDescription mode: aMode [
	| cFile |
	cFile := self primitiveFdopen: aFileDescription mode: aMode.
	cFile isNull ifTrue: [ self perror: 'fdopen()' ].
	^ cFile

]

{ #category : 'files' }
OSSUnixSystemAccessor >> fileno: aCFile [
	"Answers the file descriptor associated to the FILE* represented by aCFile"
	| returnValue |
	returnValue := self primitiveFileno: aCFile.
	(returnValue = -1) ifTrue: [ self perror: 'fileno()' ].
	^ returnValue "file descriptor"
]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> forwardSigChld [
	"Set a signal handler for SIGCHLD. Answer a new Semaphore, or nil if unable
	to set the handler (possibly because it has already been set)."

	^ self forwardSignal: self primSigChldNumber

]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> forwardSignal: signalNumber [ 
	"Set a signal handler in the VM which will signal a Smalltalk semaphore 
	at semaphoreIndex whenever an external signal signalNumber is received.
	Answer a new Semaphore, or nil if unable to set the handler (possibly
	because it has already been set). A Smalltalk process can wait on the
	Semaphore, and take action when a signal is detected. See man(7) signal
	for signal number definitions on your unix system."
	
	| sema index |
	sema := Semaphore new.
	index := Smalltalk registerExternalObject: sema.
	(self primForwardSignal: signalNumber toSemaphore: index)
		ifNil:
			[Smalltalk unregisterExternalObject: sema.
			^ nil].
	^ sema
]

{ #category : 'general' }
OSSUnixSystemAccessor >> getPid [
	"Answers the PID of the vmProcess"
	^ self primitiveGetpid
]

{ #category : 'cwd' }
OSSUnixSystemAccessor >> getcwd [ 
	"Returns the current working directory of the vmProcess"
	| buffer bytesRead |
	"Ideally, we should use a smaller buffer and then if the answer is NULL 
	and errno is ERANGE then try again with a larget buffer. But...since we cannot
	have access to errno.... we simply create a very large buffer that we trust that
	any path fill fit in it..."
	buffer := ExternalAddress allocate: 4096 + 1.
	[
	bytesRead := self primitiveGetcwd: buffer size: 4096 + 1.
	bytesRead ifNil: [ self perror: 'getcwd()'].
	] ensure: [ buffer free ].
	^ bytesRead
		
]

{ #category : 'initialization' }
OSSUnixSystemAccessor >> initialize [

	super initialize.
	finishedChildProcesses := Dictionary new
]

{ #category : 'signals' }
OSSUnixSystemAccessor >> kill: aPid signal: aSignal [
	"Sends aSignal to aPid"
	| answer | 
	answer := self primitiveKill: aPid signal: aSignal.
	(answer = -1) ifTrue: [ 
		self perror: 'kill()'.
	].
	(answer = 0) 
		ifTrue: [ ^ answer ]
		ifFalse: [ self error: 'Unkown answer for kill()' ]
]

{ #category : 'pipes' }
OSSUnixSystemAccessor >> makeBlockingPipe [
	" Create a pipes with blocking reads"
	^ self makePipeWithReadBlocking: true
]

{ #category : 'files' }
OSSUnixSystemAccessor >> makeFileNoneBocking: aFileId [
	"Make this stream to be none blocking. In Linux it means 
	calling fcntl() to set the file non-blocking (O_NONBLOCK)."
	self primSQFileSetNonBlocking: aFileId

]

{ #category : 'pipes' }
OSSUnixSystemAccessor >> makeNonBlockingPipe [
	"Creates a pipe with non blocking read"
	^ self makePipeWithReadBlocking: false
]

{ #category : 'pipes' }
OSSUnixSystemAccessor >> makePipeWithReadBlocking: aBoolean [
	"Originally, we created the pipes ourselves and the answer was an array of file descriptors.
	This was complicated because we have to then create our own sqFile structure and deal
	with with offsets and their sizeof(). 
	
	So now we use OSProcess primitive primCreatePipe which directly answers an array of sqFile structs
	specifially created for them. This way we avoid all the sqFile creation and management at image side. 	
	"

" ==================== OLD CODe =======================
	| pipePointer returnValue fileDescriptors |
	pipePointer := ExternalAddress allocate: 8.
	[
		returnValue := self primitivePipe: pipePointer.	
		(returnValue = -1) ifTrue: [ self perror: 'pipe()' ]. 
		fileDescriptors := Array new: 2.
		fileDescriptors at: 1 put: (pipePointer nbUInt32AtOffset: 0).
		fileDescriptors at: 2 put: (pipePointer nbUInt32AtOffset: 4).
		^ OSSPipe newWith: fileDescriptors readBlocking: aBoolean. 
	] ensure:[
		pipePointer free.
	]
 ==================== OLD CODe =======================
"

	| fileIDsArray |
	fileIDsArray := self primCreatePipe.
	^ OSSPipe newWith: fileIDsArray readBlocking: aBoolean. 

]

{ #category : 'errors' }
OSSUnixSystemAccessor >> perror: aMessage [
	"Prints the errno gloabl variable into the stderr together with aMessage string
	and then signal an error"
	self primitivePerror: aMessage.
	self error: 'Error: ', aMessage,' You may want to check errors in stderr'
]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> primCreatePipe [
	"Create a pipe, and answer an array of two file handles (SQFile data structures in interp.c)
	for the pipe reader and writer."

	<primitive: 'primitiveCreatePipe' module: 'UnixOSProcessPlugin'>
	^ nil
]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> primForwardSignal: signalNumber toSemaphore: semaphoreIndex [
	"Set a signal handler in the VM which will signal a Smalltalk semaphore at
	semaphoreIndex whenever an external signal sigNum is received. Answer the
	prior value of the signal handler. If semaphoreIndex is zero, the handler is
	unregistered, and the VM returns to its default behavior for handling that
	signal.

	The Smalltalk semaphore is expected to be kept at the same index location
	indefinitely during the lifetime of a Squeak session. If that is not the case, the
	handler must be unregistered prior to unregistering the Smalltalk semaphore."

	<primitive: 'primitiveForwardSignalToSemaphore' module: 'UnixOSProcessPlugin'>
	^ nil

]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> primSQFileSetNonBlocking: aSQFileStruct [
	"Pass a struct SQFile on the stack, and call fcntl() to set the file non-blocking."

	<primitive: 'primitiveSQFileSetNonBlocking' module: 'UnixOSProcessPlugin'>
	^ nil

]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> primSemaIndexFor: sigNum [
	"Answer the registration index of the semaphore currently associated with the
	signal handler for sigNum."

	<primitive: 'primitiveSemaIndexFor' module: 'UnixOSProcessPlugin'>
	^ nil

]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> primSigChldNumber [
	"Integer value corresponding to SIGCHLD"

	<primitive: 'primitiveSigChldNumber' module: 'UnixOSProcessPlugin'>
	^ nil

]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> primUnixFileNumber: aFileID [
	"Pass a struct SQFile on the stack, and answer the corresponding Unix file number."

	<primitive: 'primitiveUnixFileNumber' module: 'UnixOSProcessPlugin'>
	^ nil

]

{ #category : 'cwd - primitives' }
OSSUnixSystemAccessor >> primitiveChdir: aDirString encoding: encoding [
	| encodingOption |
	encodingOption := #optStringEncoding , encoding.
	^ self 
		ffiCall: #( int chdir(String aDirString) )
		options: { #optStringEncodingMandatory . encodingOption }.
]

{ #category : 'files - primitives' }
OSSUnixSystemAccessor >> primitiveClose: aFileDescription [ 
	
	^ self ffiCall: #( int close(int aFileDescription) )
	
]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> primitiveFdopen: aFileDescription mode: aMode [
	
	^ self ffiCall: #( OSSCFile fdopen(int aFileDescription, String aMode) )
	
]

{ #category : 'files - primitives' }
OSSUnixSystemAccessor >> primitiveFeof: filePointer [

	^ self ffiCall: #( int feof( OSSCFile filePointer) )

]

{ #category : 'files - primitives' }
OSSUnixSystemAccessor >> primitiveFflush: file [

	^ self ffiCall: #( int fflush( OSSCFile file) )

]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> primitiveFgetsInto: bufferPointer size: size file: file [ 
	"Not directly used for the moment but could be useful to test the reading without the
	SCAttachableFileStream using a code like this:
	
	buffer := NativeBoost allocate: 1001.
	(self primitiveFgetsInto: buffer  size: 1001 file: popenFile).
	self primitivePerror: 'fgets()'.
	buffer byteAt: 1001 put: 0.
	string := buffer readString.
	buffer free.
	string inspect. 
	
	"

	^ self ffiCall: #( String fgets(void* bufferPointer, int size, OSSCFile file) )

]

{ #category : 'files - primitives' }
OSSUnixSystemAccessor >> primitiveFileno: file [

	^ self ffiCall: #( int fileno( OSSCFile file) )

]

{ #category : 'cwd - primitives' }
OSSUnixSystemAccessor >> primitiveGetcwd: buffer size: size [
	
	^ self ffiCall: #( String getcwd(char *buffer, int size) )
	
]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> primitiveGetdtablesize [
	
	^ self ffiCall: #( int getdtablesize(void) )


]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> primitiveGetenv: variableName [
	
	^ self ffiCall: #( char * getenv(char* variableName) )
]

{ #category : 'general' }
OSSUnixSystemAccessor >> primitiveGetpid [

	^ self ffiCall: #( int getpid(void) )
	

]

{ #category : 'signals - primitives' }
OSSUnixSystemAccessor >> primitiveKill: aPid signal: aSignal [

	^ self ffiCall: #( int kill(int aPid, int aSignal) )
	
]

{ #category : 'errors - primitives' }
OSSUnixSystemAccessor >> primitivePerror: anErrorString [

	^ self ffiCall: #( void perror(String anErrorString) )

]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> primitivePipe: pipePointer [
	
	^ self ffiCall: #( int pipe(void* pipePointer) )
]

{ #category : 'errors - primitives' }
OSSUnixSystemAccessor >> primitiveStrerror: errorNumber [
	
	^ self ffiCall: #( String strerror( int errorNumber) )

]

{ #category : 'NOT CURRENTLY USED' }
OSSUnixSystemAccessor >> primitiveSysconf: aNumber [
	
	^ self ffiCall: #( long sysconf(int aNumber) )


]

{ #category : 'system - primitives' }
OSSUnixSystemAccessor >> primitiveSystem: commandString [
	 ^ self ffiCall: #(int system(char* commandString) ) 
		
]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> restoreSigChld [
	"Unset a SIGCHLD signal handler and unregister the Smalltalk semaphore.
	Answer the unregistered Semaphore, or nil if unable to restore the signal
	(possibly because no handler had been set)."

	^ self restoreSignal: self primSigChldNumber

]

{ #category : 'USING FROM OSPROCESS' }
OSSUnixSystemAccessor >> restoreSignal: signalNumber [ 
	"Unset a signal handler and unregister the Smalltalk semaphore. Answer
	the unregistered Semaphore, or nil if unable to restore the signal (possibly
	because no handler had been set)."

	| semaphoreIndex sema |
	semaphoreIndex := self primSemaIndexFor: signalNumber.
	semaphoreIndex ifNotNil:
		[sema := Smalltalk externalObjects at: semaphoreIndex ifAbsent: [].
		sema ifNotNil:
			[self primForwardSignal: signalNumber toSemaphore: nil.
			Smalltalk unregisterExternalObject: sema]].
	^ sema

]

{ #category : 'sizeof' }
OSSUnixSystemAccessor >> sizeOfInt [
	
	^ FFIExternalType sizeOf: #long
]

{ #category : 'sizeof' }
OSSUnixSystemAccessor >> sizeOfPointer [
	
	^ FFIExternalType pointerSize
	


]

{ #category : 'errors' }
OSSUnixSystemAccessor >> strerror: aReturnValue message: aMessage [
	"Get the string description of the error numnber aReturnValue and signal 
	and error with such a description together with aMessage string"
	| internalError | 
	internalError := self primitiveStrerror: aReturnValue.
	self error: 'Error: ', aMessage, ', code: ', aReturnValue asString, ', description: ', internalError
]

{ #category : 'system' }
OSSUnixSystemAccessor >> system: aCommandString [
	"Executes aCommandString in the OS via the system() call. Only used for testing."
	| returnValue |
	returnValue := self primitiveSystem: aCommandString.
	(returnValue = -1) ifTrue: [ 
		self perror: 'system()'	
	].
	^ returnValue 
]
