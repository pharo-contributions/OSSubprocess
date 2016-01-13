argv building
argVArguments
	^ OrderedCollection new
		add: self command;
		addAll: self arguments;
		add: 0; "shell arguments are '\0' terminated"
		yourself