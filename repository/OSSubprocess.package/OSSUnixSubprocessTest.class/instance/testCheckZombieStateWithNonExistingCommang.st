tests - child status
testCheckZombieStateWithNonExistingCommang
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: 'whatever'.
				
	self should: [ command run ] raise: Error.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
	