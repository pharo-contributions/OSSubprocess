private-primitives
primitivePopen: aCommandString mode: aMode

	^ self ffiCall: #( OSSCFile popen(String aCommandString, String aMode) ) 	
		
