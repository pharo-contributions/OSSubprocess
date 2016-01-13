close and dup2
defineActionsForWriteStream: aWriteStream dupTo: aFileDescriptor
	aWriteStream ifNotNil: [ 
		aWriteStream ossIsPipe 
			ifTrue: [  
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aWriteStream reader basicFileID).
				self posixSpawnFileActionsAddDup2: (self systemAccessor primUnixFileNumber: aWriteStream writer basicFileID) newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aWriteStream writer basicFileID).	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aWriteStream. 
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]