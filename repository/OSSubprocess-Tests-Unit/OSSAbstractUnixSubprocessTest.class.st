Class {
	#name : #OSSAbstractUnixSubprocessTest,
	#superclass : #TestCase,
	#category : 'OSSubprocess-Tests-Unit'
}

{ #category : #helpers }
OSSAbstractUnixSubprocessTest >> commandClass [
	^ OSSUnixSubprocess 
]

{ #category : #'instance creation' }
OSSAbstractUnixSubprocessTest >> newCommand [
	
	^ self commandClass new
]

{ #category : #private }
OSSAbstractUnixSubprocessTest >> systemAccessor [
	^ OSSVMProcess vmProcess systemAccessor
]
