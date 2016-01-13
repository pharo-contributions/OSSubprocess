child status
succeeded
	^ self completed and: [ self exitStatusInterpreter exitStatus = 0 ]