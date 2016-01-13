pipes
shouldCreatePipeFor: aPipe ifTrue: aBlock

	(aPipe isNil and: [ createPipesForMissingStreams ]) 
		ifTrue: [ aBlock value ]