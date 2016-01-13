env building
buildPrimitiveEnvArgument
	| envPointer |
	"By default, if none variable was set, we add all the ones existing in parent"
	envVariables isEmpty ifTrue: [ self addAllEnvVariablesFromParentWithoutOverride ].
	"The +1 is because we will have a NULL at the end"
	envPointer := ExternalAddress allocate: (envVariables keys size + 1) * 4.
	self registerPointer: envPointer.
	self collectEnvVariablesPointersInto: envPointer.
	^ envPointer