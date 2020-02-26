
numberRepetitionsForProcessA = params.repsProcessA
processAInput = Channel.from([1] * numberRepetitionsForProcessA)

process processA {
	input:
	val x from processAInput

	output:
	val x into processAOutput

	script:
	"""
	# Simulate the time the processes takes to finish
	timeToWait=\$(shuf -i ${params.processATimeRange} -n 1)
	sleep \$timeToWait
	"""
}


process processB {

	tag "One tag to rule them all"

	input:
	val x from processAOutput

	script:
	"""
    # Simulate the time the processes takes to finish
    timeToWait=\$(shuf -i ${params.processBTimeRange} -n 1)
    sleep \$timeToWait
	dd if=/dev/urandom of=newfile bs=1M count=${params.processBWriteToDiskMb}	
	"""
}
