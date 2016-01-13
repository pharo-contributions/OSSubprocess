streams
shouldCreateStreamFor: aStream ifTrue: aBlock

	(aStream isNil and: [ createMissingStandardStreams ]) 
		ifTrue: [ aBlock value ]