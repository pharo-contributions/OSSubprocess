errors
perror: aMessage
	self primitivePerror: aMessage.
	self error: 'Error: ', aMessage,' You may want to check errors in stderr'