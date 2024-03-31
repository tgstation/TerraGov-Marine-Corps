/datum/round_event_control/rogue/haunts
	name = "Haunted Streets"
	typepath = /datum/round_event/rogue/haunts
	weight = 10
	max_occurrences = 999
	min_players = 0
	req_omen = TRUE
	todreq = list("night")

/datum/round_event/rogue/haunts
	announceWhen	= 50
	var/spawncount = 5
	var/list/starts

/datum/round_event_control/rogue/haunts/canSpawnEvent()
	if(!LAZYLEN(GLOB.hauntstart))
		return FALSE
	. = ..()

/datum/round_event/rogue/haunts/start()
	if(LAZYLEN(GLOB.hauntstart))
		for(var/i in 1 to spawncount)
			var/obj/effect/landmark/events/haunts/_T = pick_n_take(GLOB.hauntstart)
			if(_T)
				_T = get_turf(_T)
				if(isfloorturf(_T))
					new /obj/structure/bonepile(_T)

	return