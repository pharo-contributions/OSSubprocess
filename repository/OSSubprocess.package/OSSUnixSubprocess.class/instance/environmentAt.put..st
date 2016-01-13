env building
environmentAt: aVariableName put: aValue
	(aVariableName isString and: [ aValue isString ])
		ifFalse: [ self error: 'Variable names and values must be strings' ].
	envVariables at: aVariableName put: aValue