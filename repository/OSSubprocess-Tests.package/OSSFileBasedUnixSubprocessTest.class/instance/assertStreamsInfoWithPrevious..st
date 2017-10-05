helpers
assertStreamsInfoWithPrevious: beforeArray
	| afterArray |
	afterArray := self getStreamsInfoForRunningTest.
	self assert: beforeArray first = afterArray first description: 'Open files in working directory differ'.
	self assert: beforeArray second = afterArray second description: 'Open tmp files differ'.