"
OSSVMProcess represents the operating system process in which this Pharo VM is currently running. OSSVMProcess has a unique instance accessed via #vmProcess and it also uses a unique instance of  OSSUnixSystemAccessor  which provides access to the external operating system.

OSSVMProcess can answer some information about the OS process running the VM, such as running PID, children, etc etc. More can be added later. 

Another important task of this class is to keep track of all the launched children processes (instances of OSSUnixSubprocess). Whenever a process is started it's registered in OSSVMProcess and unregister in certain scenarios (see senders of #unregisterChildProcess:). We keep a  list of all our children, and ocasionally prune all those that have already been exited. 

This class takes care of running what we call the ""child watcher"" which is basically a way to monitor children status and collect exit code when they finish. This also  guarantees not to let zombies process (a child whose parent did not collected child exit status). Basically, we use a SIGCHLD handler to capture  a child death. For more details, see method #initializeChildWatcher.
 
"
Class {
	#name : #OSSVMProcess,
	#superclass : #Object,
	#instVars : [
		'accessProtect',
		'childProcessList',
		'systemAccessor',
		'pid',
		'childListTreshold',
		'sessionID',
		'mutexForCwd',
		'sigChldSemaphore',
		'childWatcher',
		'earlyFinishedProcesses'
	],
	#classVars : [
		'VMProcess'
	],
	#pools : [
		'LibCErrnoSharedPool',
		'LibCWaitSharedPool'
	],
	#category : #OSSubprocess
}

{ #category : #'initialize - release' }
OSSVMProcess class >> initialize [

	self initializeVMProcessInstance.
	SessionManager default registerToolClassNamed: self name
]

{ #category : #'initialize - release' }
OSSVMProcess class >> initializeVMProcessInstance [

	VMProcess ifNotNil: [
		VMProcess finalizePreviousSession.
		VMProcess := nil ].
	Smalltalk os isWindows ifFalse: [
		VMProcess := self basicNew initialize ]
]

{ #category : #'instance creation' }
OSSVMProcess class >> new [

	self error: 'Only one instance of OSSVMProcess or any of its subclasses should exist in the image. Use #vmProcess to obtain the singleton instance.'.

]

{ #category : #'system startup' }
OSSVMProcess class >> shutDown: quitting [
	self vmProcess shutDown: quitting
]

{ #category : #'system startup' }
OSSVMProcess class >> startUp: resuming [

	resuming ifTrue: [ self initializeVMProcessInstance ]
]

{ #category : #'OS Process' }
OSSVMProcess class >> tryToDisableOSProcessSigchldHandler [
	
	self flag: #fixIt. "hack!!!!"
	Smalltalk at: #OSProcess ifPresent: [ 
		(Smalltalk at: #OSProcess) thisOSProcess processAccessor restoreSigChld. 
		(Smalltalk at: #OSProcess) thisOSProcess processAccessor grimReaperProcess terminate.
		(Smalltalk at: #ThisOSProcess) shutDown: true.
		Smalltalk removeFromShutDownList: (Smalltalk at: #ThisOSProcess).
		Smalltalk removeFromStartUpList: (Smalltalk at: #ThisOSProcess).
	].
]

{ #category : #accessing }
OSSVMProcess class >> vmProcess [
	"Answer a single instance representing the OS process in 
	which this Smalltalk VM and image is executing."

	^ VMProcess
]

{ #category : #'childs management' }
OSSVMProcess >> activeChildren [
	"Answer child processes which are currently believed to be running."

	^ accessProtect critical: [ childProcessList select: [ :process | process isRunning ] ].

]

{ #category : #'childs management' }
OSSVMProcess >> allMyChildren [

	^ childProcessList
]

{ #category : #'child watching' }
OSSVMProcess >> checkFinishedChildren [
	"Does a waitpid() with the flag WNOHANG which makes the system call to answer immediatly rather than waiting until child has exited. 
	Answers nil if child has not yet exited or the exit status if it has.
	
	http://man7.org/linux/man-pages/man2/waitpid.2.html
	waitpid man's page is ambiguous with respect of the usage of the WNOHANG option.
	It looks like waitpid ignores the first argument if WNOHANG is specified, and returns with ANY child process id.
	This means that, in combination with the previous issue, it may happen that calling waitpid for process X will unregister process Y, what will make fail a subsequent call to waitpid from Y.
	"

	| waitedChildren childrenSize |
	"Skip checking if we have no children"
	waitedChildren := 0.
	childrenSize := self activeChildren size.
	[ waitedChildren < childrenSize ]
		whileTrue: [ | statusPointer |
			[ | status returnValue |
			statusPointer := ExternalAddress allocate: systemAccessor sizeOfInt.
			returnValue := self primitiveWaitpid: -1 statusPointer: statusPointer options: WNOHANG.

			"If return value is 0 then there are no more changes, we can exit"
			returnValue = 0
				ifTrue: [ ^ self ].

			"Only throw error in case it is an error other than no childs (represented as return -1 and errno=ECHILD)"
			returnValue = -1
				ifTrue: [ systemAccessor perror: 'waitpid()' ].
			waitedChildren := waitedChildren + 1.
			status := statusPointer platformLongAt: 1.
			self updateChildProcessWithId: returnValue withStatus: status ]
				ensure: [ statusPointer free ] ]
]

{ #category : #'childs management' }
OSSVMProcess >> childPids [

	^ childProcessList collect: [ :process | process pid ]

]

{ #category : #accessing }
OSSVMProcess >> earlyFinishedProcesses [
	
	^ earlyFinishedProcesses ifNil: [ earlyFinishedProcesses := Dictionary new ]
]

{ #category : #'childs management' }
OSSVMProcess >> exitedChildren [
	"Answer child processes which have exited and are no longer running."

	^ accessProtect critical: [ childProcessList select: [ :process | process isComplete ]].

]

{ #category : #'library path' }
OSSVMProcess >> ffiLibraryName [ 
	^ LibC
]

{ #category : #updating }
OSSVMProcess >> finalizePreviousSession [
	"This method is likely called at image startup and it's job is to finalize
	stuff related to the previous run and let everything clean so that 
	the unique instance vmProcess of OSSVMProcess can be initialized correctly at startup. "

	childWatcher ifNotNil: [
		childWatcher isTerminated ifFalse: [ childWatcher terminate ].
		childWatcher := nil ].
	sigChldSemaphore ifNotNil: [
		self systemAccessor restoreSigChld.
		sigChldSemaphore := nil ].
	"To understand why the #stopWaiting, first read the comment of #shutDown:.
	It could happen that when the shutDown happened, the child process was in
	the wait of #waitForExitPollingEvery:doing:. Therefore, until the next cycle
	of the loop it won't do the queryExitStatus. So we may still 	have this
	problem in image startup. So just in case we run it too in the startup code."
	self activeChildren do: [ :each | each stopWaiting ]
]

{ #category : #'initialize - release' }
OSSVMProcess >> initialize [
	"Set my instance variables to reflect the state of the OS process in which 
	this Smalltalk virtual machine is. executing."
	Smalltalk os isWindows ifTrue: [ ^ self ]. "Cannot be initialized nor used on Windows."

	accessProtect := Semaphore forMutualExclusion.
	mutexForCwd := Semaphore forMutualExclusion.
	self initializeAllMyChildren.
	systemAccessor := OSSUnixSystemAccessor forVMProcess. 
	pid := systemAccessor getPid.
	childListTreshold := 20. "Once child list gets bigger than this number, we delete all exited processes"
	self initializeSessionID.
	self initializeSignalHandlers.
	self initializeChildWatcher.
]

{ #category : #'initialize - release' }
OSSVMProcess >> initializeAllMyChildren [
	"Use a Dictionary if process identifiers are unique. On Windows, the
	process ID is not unique, so use an OrderedCollection instead."

	^ childProcessList := OrderedCollection new

]

{ #category : #'child watching' }
OSSVMProcess >> initializeChildWatcher [
	"This is a process which waits for the death of a child processes. Use SIGCHLD events rather than a Delay to poll."

	| processSynchronizationDelay |
	processSynchronizationDelay := Delay forMilliseconds: 30.
	childWatcher	 ifNil: [
		childWatcher := [[
				"OSProcess authors suspected that there were various ways in which OS signals
				could be missed under conditions of heavy load. For that reason, we use
				#waitTimeoutMSecs: with the semaphore, so that if a signal is missed,
				we time out and rescan occasionally anyway (#updateActiveChildrenAndNotifyDead
				sends queryExitStatus which sends waitpid() )
				"
				self sigChldSemaphore waitTimeoutMSecs: 1000.
				processSynchronizationDelay wait. "Avoids lost signals in heavy process switching"
				self checkFinishedChildren.
				] repeat] newProcess priority: Processor highIOPriority.

		childWatcher resume.
		"name selected to look reasonable in the process browser"
		childWatcher name: ((ReadStream on: childWatcher hash asString) next: 5)
				, ': the OSSubprocess child watcher'
	]

]

{ #category : #'initialize - release' }
OSSVMProcess >> initializeSessionID [
	| oldFile | 
	self flag: #fixMe. 
	"grrr I need the sessionID (first int of the SQFile). .. there is no primitive to get it. Since it is the same for all files
	lets try to grab it from a file we know there will be always there: the image file."
	oldFile := OldStandardFileStream oldFileNamed: Smalltalk image imagePath.
	sessionID := oldFile basicFileID copy first: (self systemAccessor sizeOfInt).
	oldFile close.
]

{ #category : #'initialize - release' }
OSSVMProcess >> initializeSignalHandlers [
	"#sigChldSemaphore will lazily create and register the semaphore if needed"
	self sigChldSemaphore.
	
]

{ #category : #cwd }
OSSVMProcess >> lockCwdWithValue: cwdNewValue encoding: encoding during: aBlock [
	"This method is a complete hack in order to support a #cmd: option in OSSUnixSubprocess. 
	OSSUnixSubprocess relies in posix_spawn() family of functions to spwan processes in the OS,
	and these functions do not allow specifying a starting working directory for the child process. 
	However, this is sometimes needed by subprocess.
	Therefore, we propose this hack. Basically, we change the current directory of the parent process (vmProcess) 
	BEFORE launching the subprocess. When the child is launched, it inherits the working directory of the parent.
	As soon as the child was launched, we rollback and put back the original working directory in the parent. 
	Because if this, it's very much likely that aBlock represents the launching of a child process.

	mutexForCwd is needed because we may have multiple children at the same time trying to change working
	directory (not thread safe..). So with mutexForCwd we sincronize this. 	

	Forking with userInterruptPriority is useful just in case there could be other Smalltalk process 
	using another code, trying to ALSO change the working directory (very very unlikely). So at least with 
	userInterruptPriority we make sure that we a higher priority than the rest of the normal user code
	and so we minimize that problem.
	
	"

	| completed |
	cwdNewValue asFileReference exists ifFalse: [ ^ self error: 'The directory: ', cwdNewValue, ' does not exist' ]. 
	completed :=  Semaphore new. 
	[ 
		| oldCwd |
		oldCwd := self systemAccessor getcwd.
		[
			self systemAccessor chdir: cwdNewValue encoding: encoding.
			mutexForCwd critical: aBlock.
		]
		ensure: [ 
			self systemAccessor chdir: oldCwd encoding: encoding.
			completed signal.	
		]
	] forkAt: Processor userInterruptPriority.
	completed wait.
	
]

{ #category : #accessing }
OSSVMProcess >> pid [
	^ pid
]

{ #category : #'child watching' }
OSSVMProcess >> primitiveWaitpid: aProcessId statusPointer: statusPointer options: optionBits [
	
	^ self ffiCall: #( int waitpid(int aProcessId, void* statusPointer, int optionBits) )
]

{ #category : #'childs management' }
OSSVMProcess >> pruneExitedChildrenAfter: size [
	"Limit the size of the child process registry. Select the last entries, and unregister
	them if they are no longer active."

	(accessProtect critical: [childProcessList allButFirst: size])
		do: [ :aProcess |
			aProcess isComplete ifTrue: [ self unregisterChildProcess: aProcess ]]

]

{ #category : #'childs management' }
OSSVMProcess >> registerChildProcess: anOSProcess [
	"Unregister anOSProcess, and trim the child process registry to prevent excessive
	accumulation of exited children.
	
	If the process finished before this registration, set it the exit status.
	Otherwise, register it"

	accessProtect critical: [ 
		self earlyFinishedProcesses
			at: anOSProcess pid
			ifPresent: [ :exitStatus |
				anOSProcess setExitStatus: exitStatus.
				self earlyFinishedProcesses removeKey: anOSProcess pid ]
			ifAbsent: [ childProcessList addFirst: anOSProcess ] ].
	self pruneExitedChildrenAfter: childListTreshold.
	^ anOSProcess
	
]

{ #category : #accessing }
OSSVMProcess >> sessionID [
	"The sessionID is something internal to the VM and it's used
	as part of the fileID structure (sqFile) of StandardFileStream. 
	We use it for some file operations"
	^ sessionID
]

{ #category : #'system startup & shutdown' }
OSSVMProcess >> shutDown: quitting [
	"If we have a process that do not stop automatically (like a tail -f) and it runs
	with #fork  (at Smalltalk level)	then that process will be continue running 
	after the image has stopped and started again. 
	If this process continues running, it may be waiting via a delay polling
	and that will throw an error since waitpid() will fail since the parent process 
	(the VM process) is NOT the parent anymore of the child process.
	And so.if the process fails, it makes the system startup to fail and we cannot
	open the image anymore. See https://github.com/marianopeck/OSSubprocess/issues/12
	So... to solve this we simply make all active childs to stop waiting so that the 
	next startup of the image has no problem. 
	
	"
	quitting ifTrue: [ self activeChildren do: [ :each | each shutDown: quitting ] ].
]

{ #category : #'child watching' }
OSSVMProcess >> sigChldSemaphore [
	"Answer the value of sigChldSemaphore.
	If nil, then register and create a semaphore to be signaled upon SIGCHLD.
	See #forwardSigChld for more details. "

	^ sigChldSemaphore ifNil: [sigChldSemaphore := self systemAccessor forwardSigChld].

]

{ #category : #accessing }
OSSVMProcess >> systemAccessor [
	^ systemAccessor 
]

{ #category : #'childs management' }
OSSVMProcess >> unregisterChildProcess: anOSProcess [

	"Unregister anOSProcess from the list of children"

	accessProtect critical: [childProcessList remove: anOSProcess ifAbsent: [] ].
	^ anOSProcess

]

{ #category : #'child watching' }
OSSVMProcess >> updateChildProcessWithId: aChildPid withStatus: status [
	
	| childProcess |
	childProcess := self activeChildren
		detect: [ :child | child pid = aChildPid ]
		ifNone: [ ^ self earlyFinishedProcesses at: aChildPid put: status ].
	childProcess setExitStatus: status.
	childProcess processHasExitNotification.
]
