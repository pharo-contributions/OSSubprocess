streams
retrieveWhatIsAvailableOn: aStream andAddItTo: accumulatingStream
	aStream 
		ifNotNil: [ :str | 
			str ossIsPipe ifFalse: [ str reopen. ].
			accumulatingStream nextPutAll: str upToEnd 
		].