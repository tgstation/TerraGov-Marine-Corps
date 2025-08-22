/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()

/datum/controller/subsystem/ambience/fire(resumed)
	for(var/client/client_iterator AS in ambience_listening_clients)

		if(isnull(client_iterator) || isnewplayer(client_iterator.mob))
			ambience_listening_clients -= client_iterator
			continue

		if(ambience_listening_clients[client_iterator] > world.time)
			continue //Not ready for the next sound

		if(client_iterator.mob.stat == DEAD && (CHECK_BITFIELD(SSticker.mode.round_type_flags, MODE_NO_GHOSTS)))
			continue

		var/area/current_area = get_area(client_iterator.mob)

		SEND_SOUND(client_iterator.mob, sound(pick(current_area.ambience), repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))

		ambience_listening_clients[client_iterator] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)
