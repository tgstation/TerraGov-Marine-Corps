datum/controller/process/events

datum/controller/process/events/setup()
	name = "Events"
	schedule_interval = 75 //7.5 seconds

datum/controller/process/events/doWork()
	for (var/datum/event/E in events)
		E.process()

	checkEvent()