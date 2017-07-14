datum/controller/process/shuttle

datum/controller/process/shuttle/setup()
	name = "Shuttles"
	schedule_interval = 55 //5.5 seconds

	if(!shuttle_controller)
		shuttle_controller = new /datum/shuttle_controller()

datum/controller/process/shuttle/doWork()
	shuttle_controller.process()