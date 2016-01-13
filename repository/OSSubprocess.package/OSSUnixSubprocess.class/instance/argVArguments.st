argv building
argVArguments
	^ OrderedCollection new
		add: command;
		addAll: (arguments ifNil: [#()]);
		add: 0; "shell arguments are '\0' terminated"
		yourself