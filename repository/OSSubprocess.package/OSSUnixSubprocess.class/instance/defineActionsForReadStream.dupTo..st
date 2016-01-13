close and dup2
defineActionsForReadStream: aReadStream dupTo: aFileDescriptor
	aReadStream ifNotNil: [ 
		aReadStream ossIsPipe 
			ifTrue: [  
				self posixSpawnFileActionsAddClose: aReadStream writeEndFileDescriptor.
				self posixSpawnFileActionsAddDup2: aReadStream readEndFileDescriptor newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: aReadStream readEndFileDescriptor.	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aReadStream. 
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]