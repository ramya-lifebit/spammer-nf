
numberRepetitionsForProcessA = params.repsProcessA
numberFilesForProcessA = params.filesProcessA
processAWriteToDiskMb = params.processAWriteToDiskMb
processAInput = Channel.from([1] * numberRepetitionsForProcessA)
processAS3InputFiles = Channel.fromPath("${params.s3Location}/*").take( numberRepetitionsForProcessA )

process processA {
	publishDir "${params.output}/${task.hash}", mode: 'copy'
	echo true

	input:
	val x from processAInput
	file(s3_file) from  processAS3InputFiles

	output:
	val x into processAOutput
	val x into processCInput
	val x into processDInput
	file "*.txt"

	script:
	"""
	# Simulate the time the processes takes to finish
	timeToWait=\$(shuf -i ${params.processATimeRange} -n 1)
	for i in {1..${numberFilesForProcessA}};
	do echo test > file_\${i}.txt
	sleep ${params.processATimeBetweenFileCreationInSecs}
	done;
	sleep \$timeToWait
	echo "\nuname -a: \n"
	uname -a
	echo "\ncontents of PWD"
	ls -Ll
	echo "\ncontents of /etc/ssl:\n"
	ls -l /etc/ssl
	echo "\ncontents of /usr/local/share/ca-certificates:\n"
	ls -l /usr/local/share/ca-certificates
	"""
}

process processB {

	input:
	val x from processAOutput


	"""
    # Simulate the time the processes takes to finish
    timeToWait=\$(shuf -i ${params.processBTimeRange} -n 1)
    sleep \$timeToWait
	dd if=/dev/urandom of=newfile bs=1M count=${params.processBWriteToDiskMb}	
	"""
}

process processC {

	input: 
	val x from processCInput

	"""
    # Simulate the time the processes takes to finish
    timeToWait=\$(shuf -i ${params.processCTimeRange} -n 1)
    sleep \$timeToWait
	"""
}


process processD {

	input: 
	val x from processDInput

	"""
    # Simulate the time the processes takes to finish
    timeToWait=\$(shuf -i ${params.processDTimeRange} -n 1)
    sleep \$timeToWait
	"""
}

