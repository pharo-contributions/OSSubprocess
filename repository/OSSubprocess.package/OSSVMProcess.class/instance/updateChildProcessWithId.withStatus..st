child watching
updateChildProcessWithId: aChildPid withStatus: status
	
	| childProcess |
	childProcess := self activeChildren
		detect: [ :child | child pid = aChildPid ]
		ifNone: [ ^ self earlyFinishedProcesses at: aChildPid put: status ].
	childProcess setExitStatus: status.
	childProcess processHasExitNotification.