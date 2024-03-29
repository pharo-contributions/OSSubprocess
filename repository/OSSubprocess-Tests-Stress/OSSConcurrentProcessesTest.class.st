Class {
	#name : #OSSConcurrentProcessesTest,
	#superclass : #OSSAbstractUnixSubprocessTest,
	#category : 'OSSubprocess-Tests-Stress'
}

{ #category : #tests }
OSSConcurrentProcessesTest >> launchAndWaitForProcessesToFinish: numberOfProcesses [

	"We set the sunit test timeout to 2 times the sleep duration.
	Otherwise default sunit test timeout is 1 minute."
	
	| processes |
	"We set the sunit test timeout to 1 second per process.
	Except for short running processes, where we keep the default timeout.
	This is for Pharo version >= 6.0"
	(self respondsTo: #timeLimit:) ifTrue: [ 
		self timeLimit: (numberOfProcesses seconds max: self defaultTimeLimit).
	].

	
	processes := (1 to: numberOfProcesses) collect: [ :index |
		self newCommand
			command: '/bin/sleep';
			arguments: { '1s' };
			yourself ].
	
	processes do: #run.
	
	processes do: [ :command | command waitForExitWithTimeout: 5 seconds ]

]

{ #category : #tests }
OSSConcurrentProcessesTest >> test100ProcessEventuallyFinishes [

	self launchAndWaitForProcessesToFinish: 100
]

{ #category : #tests }
OSSConcurrentProcessesTest >> test10ProcessEventuallyFinishes [

	self launchAndWaitForProcessesToFinish: 10
]

{ #category : #tests }
OSSConcurrentProcessesTest >> test1ProcessEventuallyFinishes [

	self launchAndWaitForProcessesToFinish: 1
]
