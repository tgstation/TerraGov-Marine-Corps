datum/controller/process/ticker

datum/controller/process/ticker/setup()
	name = "Ticker"
	schedule_interval = 5 //0.5 seconds

	if(!ticker)
		ticker = new /datum/controller/gameticker()

	spawn(1)
		ticker.pregame()

datum/controller/process/ticker/doWork()
	ticker.process()