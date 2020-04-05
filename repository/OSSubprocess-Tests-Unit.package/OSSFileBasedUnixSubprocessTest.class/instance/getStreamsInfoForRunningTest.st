helpers
getStreamsInfoForRunningTest
	"We obtain the open tmp files before the open files because in Pharo 7 and ealier getting the entries of /tmp using

	    '/tmp' asFileReference entries

	leaves the /tmp file descriptor open. Thus #numberOfOpenFiles, using lsof, detects /tmp as an open file and makes the test fail.
	Fixed in Pharo 8."
	| openTmpFiles |
	openTmpFiles := self numberOfExistingTempStreamFiles.
	^ Array with: self numberOfOpenFiles with: openTmpFiles