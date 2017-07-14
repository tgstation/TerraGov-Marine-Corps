datum/controller/process/nano

datum/controller/process/nano/setup()
	name = "Nano UI"
	schedule_interval = 60 //6 seconds

datum/controller/process/nano/doWork()
	for (var/datum/nanoui/N in nanomanager.processing_uis)
		N.process()