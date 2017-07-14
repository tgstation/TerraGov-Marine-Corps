datum/controller/process/power

datum/controller/process/power/setup()
	name = "Power Networks"
	schedule_interval = 35 //3.5 seconds

datum/controller/process/power/doWork()
	//for (var/datum/powernet/P in powernets)
		//P.process()