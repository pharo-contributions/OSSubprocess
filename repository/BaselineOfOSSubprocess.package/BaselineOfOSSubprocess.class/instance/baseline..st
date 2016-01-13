baseline
baseline: spec
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: 'OSSubprocess';
				package: 'OSSubprocess-Tests' with: [ spec requires: 'OSSubprocess' ]
				]