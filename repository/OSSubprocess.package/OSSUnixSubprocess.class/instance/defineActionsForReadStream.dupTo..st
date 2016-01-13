close and dup2
defineActionsForReadStream: aReadStream dupTo: aFileDescriptor
	aReadStream ifNotNil: [ 
		aReadStream ossIsPipe 
			ifTrue: [  
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aReadStream writer fileID).
				self posixSpawnFileActionsAddDup2: (self systemAccessor primUnixFileNumber: aReadStream reader fileID) newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: (self systemAccessor primUnixFileNumber: aReadStream reader fileID).	
			] 
			ifFalse: [ 
				| fileDesc |
				fileDesc := self getFdFromStream: aReadStream. 
				self posixSpawnFileActionsAddDup2: fileDesc newFileDescritpion: aFileDescriptor.
				self posixSpawnFileActionsAddClose: fileDesc.
			
			]
	]