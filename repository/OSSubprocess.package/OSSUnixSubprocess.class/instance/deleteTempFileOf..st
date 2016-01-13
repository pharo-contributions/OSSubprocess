cleaning
deleteTempFileOf: aStream
	aStream ifNotNil: [ 
		aStream ossIsPipe ifFalse: [ aStream fullName asFileReference ensureDelete ] 
	]
	

