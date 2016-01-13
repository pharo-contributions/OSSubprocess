errors
strerror: aReturnValue message: aMessage
	| internalError | 
	internalError := self primitiveStrerror: aReturnValue.
	self error: 'Error: ', aMessage, ', code: ', aReturnValue asString, ', description: ', internalError