printing
printOn: aStream

	aStream
		nextPutAll: self class name asString;
		nextPut: $(;
		nextPutAll: 'Command: ';
		nextPutAll: command asString;
		nextPutAll: '; Status: ';
		nextPutAll: self exitStatus asString;
		nextPut: $)