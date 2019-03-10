/var/global/sent_spiders_to_station = 0

/datum/event/spider_infestation
	announceWhen	= 400
	oneShot			= 1

	var/spawncount = 1


/datum/event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(8, 12)	//spiderlings only have a 50% chance to grow big and strong
	sent_spiders_to_station = 0

/datum/event/spider_infestation/announce()
	command_announcement.Announce("Unidentified lifesigns detected.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')


/datum/event/spider_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(is_mainship_or_low_orbit_level(temp_vent.loc.z) && !temp_vent.welded && temp_vent.parents)
			if(temp_vent.parents.members.len > 50)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		new /obj/effect/spider/spiderling(vent.loc)
		vents -= vent
		spawncount--
