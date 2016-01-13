childs management
pruneExitedChildrenAfter: size
	"Limit the size of the child process registry. Select the last entries, and unregister
	them if they are no longer active."

	"OSSVMProcess vmProcess pruneExitedChildrenAfter: 20"

	(accessProtect critical: [childProcessList allButFirst: size])
		do: [ :aProcess |
			aProcess isComplete ifTrue: [ self unregisterChildProcess: aProcess ]]
