//Code moved into datum/controller/process/machines
/*
datum/controller/process/power

datum/controller/process/power/setup()
	name = "Power Networks"
	schedule_interval = 35 //3.5 seconds

datum/controller/process/power/doWork()
	var/i = 1
	while(i<=powernets.len)
		var/datum/powernet/Powernet = powernets[i]
		if(Powernet)
			Powernet.process()
			i++
			continue
		powernets.Cut(i,i+1)
*/