helpers
withNonAsciiDirectoryDo: aBlock 
	| directory |
	directory := FileLocator temp / (self class name , '-éoï-' , UUIDGenerator next asString).
	directory ensureCreateDirectory.
	[ aBlock cull: directory asFileReference ]
	ensure: [ directory ensureDeleteAll ]