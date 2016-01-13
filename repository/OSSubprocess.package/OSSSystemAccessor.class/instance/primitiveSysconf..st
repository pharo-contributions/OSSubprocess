NOT MANAGED
primitiveSysconf: aNumber
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode>
	^ self nbCall: #( long sysconf(int aNumber) )

