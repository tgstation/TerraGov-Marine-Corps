datum/controller/process/objects

datum/controller/process/objects/setup()
	name = "Objects"
	schedule_interval = 23 //2.3 seconds
	/*
	world << "\red \b Initializing objects"
	sleep(-1)
	for (var/obj/O in world)
		O.initialize()

datum/controller/process/objects/doWork()
	for (var/obj/O in processing_objects)
		O.process()*/