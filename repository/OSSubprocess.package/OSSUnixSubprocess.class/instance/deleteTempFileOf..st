cleaning
deleteTempFileOf: aStream
	aStream ifNotNil: [ 
		aStream isPipe ifFalse: [ aStream fullName asFileReference ensureDelete ] 
	]
	

