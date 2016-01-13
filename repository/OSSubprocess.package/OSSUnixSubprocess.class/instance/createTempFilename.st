temp files
createTempFilename
	^ self class name , '-p', OSSVMProcess vmProcess pid asString, '-', UUID new printString, '.deleteme'
	