env building
buildPrimitiveEnvArgument
	| envPointer |
	envPointer := NBExternalAddress value: ((NativeBoost loadSymbol: 'environ' fromModule: NativeBoost CLibrary) nbUInt32AtOffset: 0).
	^ envPointer
	