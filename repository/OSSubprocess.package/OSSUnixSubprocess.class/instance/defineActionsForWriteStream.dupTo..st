close and dup2
defineActionsForWriteStream: aWriteStream dupTo: aFileDescriptor
	aWriteStream ifNotNil: [ 
		aWriteStream ossIsPipe 
			ifTrue: [  
				self posixSpawnFileActionsAddClose: aWriteStream readEndFileDescriptor.
				self posixSpawnFileActionsAddDup2: aWriteStream writeEndFileDescriptor newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: aWriteStream writeEndFileDescriptor.	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aWriteStream. 
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]