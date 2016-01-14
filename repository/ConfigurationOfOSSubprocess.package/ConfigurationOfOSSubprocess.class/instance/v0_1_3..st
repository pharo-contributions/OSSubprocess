versions
v0_1_3: spec
	<version: 'v0.1.3'>
	
	spec
		for: #'common'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://marianopeck/OSSubprocess:v0.1.3/repository' ];
				import: 'OSSubprocess' ].