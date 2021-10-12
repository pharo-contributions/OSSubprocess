Class {
	#name : #OSSVMProcessTest,
	#superclass : #OSSAbstractUnixSubprocessTest,
	#category : 'OSSubprocess-Tests-Unit'
}

{ #category : #accessing }
OSSVMProcessTest >> runCaseManaged [
	"testChangeDirWithNonAsciiCharacters test has to download the unicode table that can take some time.
	Disable test timeout."
	^ self runCase
]

{ #category : #tests }
OSSVMProcessTest >> testChangeDir [
	| oldDir | 
	oldDir := self systemAccessor getcwd.
	OSSVMProcess vmProcess
		lockCwdWithValue: '/tmp'
		encoding: #utf8 
		during: [
			"Grrr in latest OSX /tmp is mapped to /private/tmp..."
			self assert: ((self systemAccessor getcwd = '/tmp') or: [ self systemAccessor getcwd = '/private/tmp' ]).
		].
	self assert: self systemAccessor getcwd equals: oldDir
				
]

{ #category : #tests }
OSSVMProcessTest >> testChangeDirWithNonAsciiCharacters [
	| oldDir newDir duringSystemCwd | 
	oldDir := self systemAccessor getcwd.
	newDir := FileLocator temp / 'strangË foldér namê'.
	newDir ensureCreateDirectory.

	OSSVMProcess vmProcess
		lockCwdWithValue: newDir fullName
		encoding: #utf8
		during: [ duringSystemCwd := self systemAccessor getcwd ].
	duringSystemCwd := UnicodeNormalizer new toNFC: duringSystemCwd.

	"Grrr in latest OSX /tmp is mapped to /private/tmp..."
	self assert: ((duringSystemCwd = newDir fullName) or: [ duringSystemCwd = ('/private' , newDir fullName) ]).
	self assert: self systemAccessor getcwd equals: oldDir.
	newDir ensureDelete.
]

{ #category : #tests }
OSSVMProcessTest >> testChangeDirWithNonExistingDir [
	| oldDir |
	oldDir := self systemAccessor getcwd.
	[ OSSVMProcess vmProcess
		lockCwdWithValue: '/tmpWhatever'
		encoding: #utf8
		during: [  ] ]
	on: Error
	do: [ :ex | self assert: (ex printString includesSubstring: 'does not exist') ].
	self assert: self systemAccessor getcwd equals: oldDir
]

{ #category : #tests }
OSSVMProcessTest >> testChildrenCollectionsWithOneProcessBeforeAndAfter [
	| command | 
	OSSVMProcess vmProcess initializeAllMyChildren. 
	command := self newCommand 
		command: '/bin/sleep';
		arguments: {'2'}.
	
	command run. 
	
	self assert: OSSVMProcess vmProcess allMyChildren size equals: 1.
	self assert: OSSVMProcess vmProcess allMyChildren first == command.
	self assert: OSSVMProcess vmProcess activeChildren size equals: 1.
	self assert: OSSVMProcess vmProcess activeChildren first == command.
	self assert: OSSVMProcess vmProcess exitedChildren isEmpty.
	self assert: OSSVMProcess vmProcess childPids size equals: 1.
	self assert: OSSVMProcess vmProcess childPids first equals: command pid.
	
	command waitForExit. 
	
	self assert: OSSVMProcess vmProcess allMyChildren size equals: 1.
	self assert: OSSVMProcess vmProcess allMyChildren first == command.
	self assert: OSSVMProcess vmProcess activeChildren size equals: 0.
	self assert: OSSVMProcess vmProcess exitedChildren size equals: 1.
	self assert: OSSVMProcess vmProcess exitedChildren first == command.
	self assert: OSSVMProcess vmProcess childPids size equals: 1.
	self assert: OSSVMProcess vmProcess childPids first equals: command pid.
			

]

{ #category : #tests }
OSSVMProcessTest >> testInitializeChildren [

	OSSVMProcess vmProcess initializeAllMyChildren.
	
	self assert: OSSVMProcess vmProcess allMyChildren isEmpty.
	self assert: OSSVMProcess vmProcess activeChildren isEmpty.
	self assert: OSSVMProcess vmProcess exitedChildren isEmpty.
	self assert: OSSVMProcess vmProcess childPids isEmpty.
	
	
			

]

{ #category : #tests }
OSSVMProcessTest >> testPruneExitedChildrenAfter [
	| command | 
	OSSVMProcess vmProcess initializeAllMyChildren. 
	command := self newCommand 
		command: '/bin/ls'.
	command runAndWait. 
	
	self assert: OSSVMProcess vmProcess exitedChildren size equals: 1.
	OSSVMProcess vmProcess pruneExitedChildrenAfter: 0. 
	
	self assert: OSSVMProcess vmProcess allMyChildren isEmpty.
	self assert: OSSVMProcess vmProcess activeChildren isEmpty.
	self assert: OSSVMProcess vmProcess exitedChildren isEmpty.
	self assert: OSSVMProcess vmProcess childPids isEmpty.
	
	
]
