NOT MANAGED
primitiveSysconf: aNumber
	
	^ self ffiCall: #( long sysconf(int aNumber) )

