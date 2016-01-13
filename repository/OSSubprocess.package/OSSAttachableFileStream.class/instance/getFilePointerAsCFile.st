private - hacks
getFilePointerAsCFile

	^ OSSCFile new 
		setHandle: (ExternalData 
							fromHandle: ((self basicFileID copyFrom: 5 to: 8) asExternalPointer  ) 
							type: ExternalType void asPointerType);
		yourself
	


