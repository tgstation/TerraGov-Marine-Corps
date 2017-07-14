datum/controller/process/events

datum/controller/process/events/setup()
	name = "Events"
	schedule_interval = 75 //7.5 seconds

datum/controller/process/events/doWork()

	var/i = 1
	while(i<=events.len)
		var/datum/event/Event = events[i]
		if(Event)
			Event.process()
			i++
			continue
		events.Cut(i,i+1)
	checkEvent()