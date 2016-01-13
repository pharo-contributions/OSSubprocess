child watching
initializeChildWatcher
	"This is a process which waits for the death of a child processes. Use SIGCHLD events rather than a Delay to poll"

	| processSynchronizationDelay |
	processSynchronizationDelay := Delay forMilliseconds: 20.
	childWatcher	 ifNil: [
		childWatcher := [[
							self sigChldSemaphore wait.
							processSynchronizationDelay wait. "Avoids lost signals in heavy process switching"
							self updateActiveChildrenAndNotifyDead.
							] repeat] newProcess.

		childWatcher resume.
		"name selected to look reasonable in the process browser"
		childWatcher name: ((ReadStream on: childWatcher hash asString) next: 5)
				, ': the OSSubprocess child watcher'
	]
