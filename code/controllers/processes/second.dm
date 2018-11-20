/datum/controller/process/second

/datum/controller/process/second/setup()
	name = "Second"
	schedule_interval = 10 //1 second

/datum/controller/process/second/doWork()

	var/i = 1
	while(i<=processing_second.len)
		var/obj/Object = processing_second[i]
		if(Object)
			Object.process()
			i++
			continue
		processing_objects.Cut(i,i+1)