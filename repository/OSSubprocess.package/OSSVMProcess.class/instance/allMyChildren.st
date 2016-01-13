childs management
allMyChildren

	^ Dictionary withAll: (childProcessList collect: [ :process | process pid -> process ])