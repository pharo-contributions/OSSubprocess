helpers
newCommand
	| command |
	command := self commandClass new.
	command defaultReadStreamCreationBlock: [ command createTempFileToBeUsedAsReadStreamOn: '/tmp' ].
	command defaultWriteStreamCreationBlock: [ command createTempFileToBeUsedAsWriteStreamOn: '/tmp' ].
	^ command 
	