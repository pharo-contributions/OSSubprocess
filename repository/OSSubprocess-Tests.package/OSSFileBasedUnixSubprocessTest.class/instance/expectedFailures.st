failures
expectedFailures
	| failures | 
	failures := OrderedCollection new.
	
	"testReadingFromStdoutAfterCommandFinishesDoesNotBlocksVM fails on Travis on OSX. It looks like if another test would have run while this one was sleeping and hence in #assertStreamsInfoWithPrevious: it fails because there are 2 new not-closed files...which I suspect that those are from another running test..."
	Smalltalk platform isMacOS ifTrue: [ failures add: 'testReadingFromStdoutAfterCommandFinishesDoesNotBlocksVM' ].
	
	Smalltalk platform isUnix ifTrue: [ failures add: 'testBasicCommandWriteToStdin' ].
	"testBasicCommandWriteToStdin  fails because of what the documentation says:
	> **Important** We have found some problems when using regular files for the `stdin`. While we do not strictly forbid that, we recommend you do so only if you know very well what you are doing. Otherwise, use blocking pipes for `stdin` (default behavior).

"