
numberRepetitionsForProcessA = params.repsProcessA
numberFilesForProcessA = params.filesProcessA
processAWriteToDiskMb = params.processAWriteToDiskMb
processAInput = Channel.from([1] * numberRepetitionsForProcessA)

process processA {
	publishDir "${params.output}/${task.hash}", mode: 'copy'

	input:
	val x from processAInput

	output:
	val x into processAOutput
	file "*.txt"

	script:
	"""
	# Simulate the time the processes takes to finish
	timeToWait=\$(shuf -i ${params.processATimeRange} -n 1)
	for i in {1..${numberFilesForProcessA}};
	do dd if=/dev/urandom of=newfile_\${i}.txt bs=1M count=${params.processAWriteToDiskMb}
	sleep ${params.processATimeBetweenFileCreationInSecs}
	done;
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
