versions
v0_2_5: spec
	<version: '0.2.5'>
	
	spec
		for: #'pharo'
		do: [ 
			spec
				baseline: 'OSSubprocess'
					with: [ spec repository: 'github://marianopeck/OSSubprocess:v0.2.5/repository' ];
				import: 'OSSubprocess' ].