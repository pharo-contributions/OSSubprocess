printing
printOn: aStream

	aStream
		nextPutAll: self class name asString;
		nextPut: $(;
		nextPutAll: 'Command: ';
		nextPutAll: command asString;
		nextPutAll: '; Pid: ';
		nextPutAll: pid asString;
		nextPutAll: '; Status: ';
		nextPutAll: self exitStatusInterpreter asString;
		nextPut: $)