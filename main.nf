// If gs:// or s3:// or https://, else it's local
fileSystem = params.dataLocation.contains(':') ? params.dataLocation.split(':')[0] : 'local'

// Header log info
log.info "\nPARAMETERS SUMMARY"
log.info "mainScript                            : ${params.mainScript}"
log.info "defaultBranch                         : ${params.defaultBranch}"
log.info "config                                : ${params.config}"
log.info "fileSystem                            : ${fileSystem}"
log.info "dataLocation                          : ${params.dataLocation}"
log.info "fileSuffix                            : ${params.fileSuffix}"
log.info "repsProcessA                          : ${params.repsProcessA}"
log.info "processAWriteToDiskMb                 : ${params.processAWriteToDiskMb}"
log.info "processATimeRange                     : ${params.processATimeRange}"
log.info "filesProcessA                         : ${params.filesProcessA}"
log.info "processATimeBetweenFileCreationInSecs : ${params.processATimeBetweenFileCreationInSecs}"
log.info "processBTimeRange                     : ${params.processBTimeRange}"
log.info "processBWriteToDiskMb                 : ${params.processBWriteToDiskMb}"
log.info "processCTimeRange                     : ${params.processCTimeRange}"
log.info "processDTimeRange                     : ${params.processDTimeRange}"
log.info "output                                : ${params.output}"
log.info "echo                                  : ${params.echo}"
log.info "cpus                                  : ${params.cpus}"
log.info "processA_cpus                         : ${params.processA_cpus}"
log.info "errorStrategy                         : ${params.errorStrategy}"
log.info "container                             : ${params.container}"
log.info "maxForks                              : ${params.maxForks}"
log.info "queueSize                             : ${params.queueSize}"
log.info "executor                              : ${params.executor}"
log.info ""

numberRepetitionsForProcessA = params.repsProcessA
numberFilesForProcessA = params.filesProcessA
processAWriteToDiskMb = params.processAWriteToDiskMb
processAInput = Channel.from([1] * numberRepetitionsForProcessA)
processAInputFiles = Channel.fromPath("${params.dataLocation}/*${params.fileSuffix}").take( numberRepetitionsForProcessA )

process processA {
	publishDir "${params.output}/${task.hash}", mode: 'copy'
	tag "cpus: ${task.cpus}, cloud storage: ${cloud_storage_file}"

	input:
	val x from processAInput
	file(a_file) from processAInputFiles

	output:
	val x into processAOutput
	val x into processCInput
	val x into processDInput
	file "*.txt"

	script:
	"""
	# Simulate the time the processes takes to finish
	pwd=`basename \${PWD} | cut -c1-6`
	echo \$pwd
	timeToWait=\$(shuf -i ${params.processATimeRange} -n 1)
	for i in {1..${numberFilesForProcessA}};
	do echo test > "\${pwd}"_file_\${i}.txt
	sleep ${params.processATimeBetweenFileCreationInSecs}
	done;
	sleep \$timeToWait
	echo "task cpus: ${task.cpus}"
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

