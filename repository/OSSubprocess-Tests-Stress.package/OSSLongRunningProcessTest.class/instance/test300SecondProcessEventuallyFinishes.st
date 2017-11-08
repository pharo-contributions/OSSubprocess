tests
test300SecondProcessEventuallyFinishes
	"Wait for five minutes.
	Times > 10 minutes make travis timeout."
	self doTestProcessEventuallyFinishesForSeconds: 300 second