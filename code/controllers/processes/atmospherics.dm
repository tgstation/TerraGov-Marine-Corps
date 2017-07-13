datum/controller/process/atmospherics

datum/controller/process/atmospherics/setup()
	name = "Atmospherics"
	schedule_interval = 25 // 2.5 seconds

	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()

datum/controller/process/atmospherics/doWork()
	air_master.Tick()