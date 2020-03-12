tests
testChangeDirWithNonExistingDir
	| oldDir |
	oldDir := self systemAccessor getcwd.
	[ OSSVMProcess vmProcess
		lockCwdWithValue: '/tmpWhatever'
		encoding: #utf8
		during: [  ] ]
	on: Error
	do: [ :ex | self assert: (ex printString includesSubstring: 'does not exist') ].
	self assert: self systemAccessor getcwd equals: oldDir