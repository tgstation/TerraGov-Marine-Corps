//Supplies are dropped onto the map for both factions to fight over
/datum/round_event_control/santa_visit
	name = "Santa Visit"
	typepath = /datum/round_event/santa_visit
	weight = 12
	earliest_start = 50 MINUTES
	max_occurrences = 1

	gamemode_blacklist = list("Crash")

/datum/round_event/santa_visit
	///upper limits of how many presents we spawn
	var/maxpresents = 30
	announce_when = 0
	///used to hold location of christmas tree for spawning purposes
	var/turf/targetturf
	///how many santas we should spawn, normally set to 1
	var/maxsanta = 1
	///how many elves we should attempt to spawn, note due to prob in elf spawning function this number won't always be hit, it's just the max
	var/maxelves = 4

/datum/round_event_control/santa_visit/can_spawn_event(players_amt, gamemode)
	var/list/eligible_targets = list()
	for(var/mob/living/carbon/human/possible_target in GLOB.alive_human_list)
		if(HAS_TRAIT(possible_target, TRAIT_SANTA_CLAUS)) ///avoid duplicate santas
			return FALSE
	if(!length(eligible_targets))
		return //everyone is dead or evac'd

/datum/round_event/santa_visit/start()
	for(var/obj/structure/flora/tree/pine/xmas/presents/christmastree)
		if(christmastree.unlimited)
			continue
		else
			targetturf = christmastree
	populate_presents()
	place_santa()
	place_elves()
	/* for(var/z in z_levels)
		while(!target_turf)
			var/turf/potential_turf = locate(rand(0, world.maxx), rand(0,world.maxy), z)
			if(isclosedturf(potential_turf) || isspaceturf(potential_turf))
				continue
			target_turf = potential_turf
			set_target(target_turf)
			return
		*/

/datum/round_event/santa_visit/announce()
	var/alert = pick( "Excessive Christmas cheer detected, please check all equipment for the prescence of magical creatures",
		"Radar has picked up eight unidentified signatures landing near the Christmas tree.",
		"Attention crew: unidentified festive entities spotted shipside. Please proceed with caution, and be on the lookout for unexpected gifts and seasonal cheer.",
		"Caution: Eggnog spill detected shipside. Investigate immediately for possible Santa sightings and confirm the presence of tinsel in all ventilation systems.",
		"Deck the halls with caution signs: Reports of tinsel entanglement shipside. Proceed with care, and be on the lookout for wayward ornaments.",
	)
	priority_announce(alert)

/datum/round_event/santa_visit/proc/populate_presents()
	for(var/placedpresents = 1 to maxpresents)
		var/turf/target = locate(targetturf.x + rand(-3, 3), targetturf.y + rand(-3, 3), targetturf.z)
		if(is_blocked_turf(target))
			continue
		else if(prob(25))
			new /obj/item/a_gift(target)

///proc for spawning santa(s) around christmas tree
/datum/round_event/santa_visit/proc/place_santa()
	for(var/placedsanta = 1 to maxsanta)
		var/turf/target = locate(targetturf.x + rand(-3, 3), targetturf.y + rand(-3, 3), targetturf.z)
		var/mob/living/carbon/human/spawnedhuman = new /mob/living/carbon/human(target)
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa/eventspawn)
		spawnedhuman.name = "Santa Claus"
		spawnedhuman.real_name = spawnedhuman.name
		spawnedhuman.apply_assigned_role_to_spawn(J)
		spawnedhuman.set_nutrition(NUTRITION_OVERFED * 2)
		spawnedhuman.grant_language(/datum/language/xenocommon)
		ADD_TRAIT(spawnedhuman, TRAIT_SANTA_CLAUS, TRAIT_SANTA_CLAUS)
		var/datum/action/innate/summon_present/present_spawn = new(spawnedhuman)
		present_spawn.give_action(spawnedhuman)
		spawnedhuman.offer_mob()

///proc for spawning elves around christmas tree
/datum/round_event/santa_visit/proc/place_elves()
	for(var/placedelves = 1 to maxelves)
		if(prob(25))
			return
		var/turf/target = locate(targetturf.x + rand(-3, 3), targetturf.y + rand(-3, 3), targetturf.z)
		var/mob/living/carbon/human/spawnedhuman = new /mob/living/carbon/human(target)
		spawnedhuman.name = "Elf [rand(1,999)]"
		spawnedhuman.real_name = spawnedhuman.name
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa)
		spawnedhuman.apply_assigned_role_to_spawn(J)
		spawnedhuman.offer_mob()
