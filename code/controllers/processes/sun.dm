datum/controller/process/sun

datum/controller/process/sun/setup()
	name = "Sun"
	schedule_interval = 50 //5 seconds

	if(!sun)
		sun = new /datum/sun()

datum/controller/process/sun/doWork()
	sun.calc_position()