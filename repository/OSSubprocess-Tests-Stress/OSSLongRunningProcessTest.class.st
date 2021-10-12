Class {
	#name : #OSSLongRunningProcessTest,
	#superclass : #OSSAbstractUnixSubprocessTest,
	#category : 'OSSubprocess-Tests-Stress'
}

{ #category : #tests }
OSSLongRunningProcessTest >> doTestProcessEventuallyFinishesForSeconds: aDuration [

	| command |
	"We set the sunit test timeout to 2 times the sleep duration.
	Otherwise default sunit test timeout is 1 minute.
	This is for Pharo version >= 6.0"
	(self respondsTo: #timeLimit:) ifTrue: [ 
		self timeLimit: aDuration * 2.
	].

	command := self newCommand
		command: '/bin/sleep';
		arguments: { aDuration asSeconds asString };
		yourself.
	command run.
	
	"We should wait and finish without a timeout exception"
	command waitForExitWithTimeout: aDuration * 2.
]

{ #category : #tests }
OSSLongRunningProcessTest >> test100SecondProcessEventuallyFinishes [

	self doTestProcessEventuallyFinishesForSeconds: 100 second
]

{ #category : #tests }
OSSLongRunningProcessTest >> test10SecondProcessEventuallyFinishes [

	self doTestProcessEventuallyFinishesForSeconds: 10 second
]

{ #category : #tests }
OSSLongRunningProcessTest >> test1SecondProcessEventuallyFinishes [

	self doTestProcessEventuallyFinishesForSeconds: 1 second
]

{ #category : #tests }
OSSLongRunningProcessTest >> test300SecondProcessEventuallyFinishes [
	"Wait for five minutes.
	Times > 10 minutes make travis timeout."
	self doTestProcessEventuallyFinishesForSeconds: 300 second
]
