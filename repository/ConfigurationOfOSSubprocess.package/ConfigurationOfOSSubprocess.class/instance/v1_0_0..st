versions
v1_0_0: spec
	<version: '1.0.0'>
	
	spec
		for: #'pharo'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://marianopeck/OSSubprocess:v1.0.0/repository' ];
				import: 'OSSubprocess' ].