close and dup2
defineActionsForWriteStream: aWriteStream dupTo: aFileDescriptor
	aWriteStream ifNotNil: [ 
		aWriteStream ossIsPipe 
			ifTrue: [  
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aWriteStream reader fileID).
				self posixSpawnFileActionsAddDup2: (self systemAccessor primUnixFileNumber: aWriteStream writer fileID) newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aWriteStream writer fileID).	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aWriteStream. 
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]