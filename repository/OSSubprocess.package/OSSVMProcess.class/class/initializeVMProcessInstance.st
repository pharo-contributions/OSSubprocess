initialize - release
initializeVMProcessInstance
	VMProcess isNil 
		ifTrue: [ VMProcess := self basicNew. ]
		ifFalse: [ VMProcess updateFromNewSession. ].
	VMProcess initialize.