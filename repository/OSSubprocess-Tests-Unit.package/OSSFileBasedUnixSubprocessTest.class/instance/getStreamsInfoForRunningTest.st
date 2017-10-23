helpers
getStreamsInfoForRunningTest
	"We obtain the open tmp files before the open files because apparently getting the entries of /tmp using
	    '/tmp' asFileReference entries
	
	opens a file descriptor and lets the FD open. Thus #numberOfOpenFiles, using lsof, detects /tmp as an open file and makes the test fail.
	
	This happens only in travis under Ubuntu.
	"
	| openTmpFiles |
	openTmpFiles := self numberOfExistingTempStreamFiles.
	^ Array with: self numberOfOpenFiles with: openTmpFiles