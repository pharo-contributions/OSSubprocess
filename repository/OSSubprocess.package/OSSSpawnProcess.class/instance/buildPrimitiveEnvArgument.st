env building
buildPrimitiveEnvArgument
	| envPointer |
	envPointer := ExternalAddress loadSymbol: 'environ' from: LibC.
	^ envPointer
	
