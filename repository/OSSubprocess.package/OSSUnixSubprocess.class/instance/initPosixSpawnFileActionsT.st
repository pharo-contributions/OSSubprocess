close and dup2
initPosixSpawnFileActionsT
	| returnValue |
	posixSpawnFileActionsT := OSSPosixSpawnFileActionsT new 
										setHandle: (ExternalData 
													fromHandle: ((ExternalAddress allocate: 4) asExternalPointer  ) 
													type: ExternalType void asPointerType);
										yourself.
	returnValue := self primitivePosixSpawnFileActionsInit: posixSpawnFileActionsT. 
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_init()' ].