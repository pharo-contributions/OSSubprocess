childs management
exitedChildren
	"Answer child processes which have exited and are no longer running."

	"OSSVMProcess vmProcess exitedChildren"

	^ accessProtect critical: [ childProcessList select: [ :process | process isComplete ]].
