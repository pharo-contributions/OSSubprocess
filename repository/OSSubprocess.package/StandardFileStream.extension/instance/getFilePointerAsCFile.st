*OSSubprocess
getFilePointerAsCFile

	| pointerSize secondFieldStart secondFieldEnd |
	pointerSize := FFIExternalType pointerSize.
	secondFieldStart := pointerSize + 1.
	secondFieldEnd := secondFieldStart + pointerSize - 1.
	^ OSSCFile new 
		setHandle: (ExternalData 
							fromHandle: ((fileID copyFrom: secondFieldStart to: secondFieldEnd) asExternalPointer  ) 
							type: ExternalType void asPointerType);
		yourself
	


