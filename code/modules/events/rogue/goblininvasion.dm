/datum/round_event_control/rogue/gobinvade
	name = "Gob Invasion"
	typepath = /datum/round_event/rogue/gobinvade
	weight = 10
	max_occurrences = 999
	min_players = 0
	req_omen = TRUE
	earliest_start = 35 MINUTES
	todreq = list("night", "dawn", "day", "dusk")

/datum/round_event/rogue/gobinvade
	announceWhen	= 50
	var/spawncount = 5
	var/list/starts

/datum/round_event_control/rogue/gobinvade/canSpawnEvent()
	if(!LAZYLEN(GLOB.hauntstart))
		return FALSE
	. = ..()

/datum/round_event/rogue/gobinvade/start()
	var/list/spawn_locs = GLOB.hauntstart.Copy()
	if(LAZYLEN(spawn_locs))
		for(var/i in 1 to spawncount)
			var/obj/effect/landmark/events/haunts/_T = pick_n_take(spawn_locs)
			if(_T)
				_T = get_turf(_T)
				if(isfloorturf(_T))
					var/obj/structure/gob_portal/G = locate() in _T
					if(G)
						continue
					new /obj/structure/gob_portal(_T)
	return

