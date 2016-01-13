versions
v0_1_0: spec
	<version: 'v0.1.0'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://marianopeck/OSSubprocess:v0.1.0' ];
				import: 'OSSubprocess' ].