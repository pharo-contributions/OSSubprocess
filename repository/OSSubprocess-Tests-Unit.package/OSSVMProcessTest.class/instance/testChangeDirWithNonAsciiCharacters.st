tests
testChangeDirWithNonAsciiCharacters
	| oldDir newDir duringSystemCwd | 
	oldDir := self systemAccessor getcwd.
	newDir := FileLocator temp / 'strangË foldér namê'.
	newDir ensureCreateDirectory.

	OSSVMProcess vmProcess
		lockCwdWithValue: newDir fullName
		encoding: #utf8
		during: [ duringSystemCwd := self systemAccessor getcwd ].
	duringSystemCwd := UnicodeNormalizer new toNFC: duringSystemCwd.

	"Grrr in latest OSX /tmp is mapped to /private/tmp..."
	self assert: ((duringSystemCwd = newDir fullName) or: [ duringSystemCwd = ('/private' , newDir fullName) ]).
	self assert: self systemAccessor getcwd equals: oldDir.
	newDir ensureDelete.