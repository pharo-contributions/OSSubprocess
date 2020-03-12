settings
arguments: anObject
	arguments := anObject collect: [ :each | (each encodeWith: encoding) asString ]