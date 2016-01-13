private - hacks
getFilePointerAsCFile
	^ OSSCFile new 
		handle: ((self fileID copyFrom: 5 to: 8) reversed asInteger);
		yourself
	