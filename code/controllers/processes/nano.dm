datum/controller/process/nano

datum/controller/process/nano/setup()
	name = "Nano UI"
	schedule_interval = 60 //6 seconds

datum/controller/process/nano/doWork()

	var/i = 1
	while(i<=nanomanager.processing_uis.len)
		var/datum/nanoui/ui = nanomanager.processing_uis[i]
		if(ui)
			ui.process()
			i++
			continue
		nanomanager.processing_uis.Cut(i,i+1)