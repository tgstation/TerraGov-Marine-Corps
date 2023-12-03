//Supplies are dropped onto the map for both factions to fight over
/datum/round_event_control/santa_visit
	name = "Santa Visit"
	typepath = /datum/round_event/santa_visit
	weight = 15
	earliest_start = 30 MINUTES
	max_occurrences = 1

	gamemode_blacklist = list("Crash")

/datum/round_event/santa_visit
	///upper limits of how many presents we spawn
	var/maxpresents = 30
	announce_when = 0
	///used to hold location of christmas tree for spawning purposes
	var/turf/christmastreeturf
	///how many santas we should spawn, normally set to 1
	var/maxsanta = 1
	///how many elves we should attempt to spawn, note due to prob in elf spawning function this number won't always be hit, it's just the max
	var/maxelves = 4
	///The human target for this event
	var/mob/living/carbon/human/hive_target

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
			christmastreeturf = christmastree
	populate_presents()
	place_santa()
	place_elves()

/datum/round_event/santa_visit/announce()
	var/alert = pick( "Excessive Christmas cheer detected, please check all equipment for the prescence of magical creatures",
		"Radar has picked up eight unidentified signatures landing near the Christmas tree.",
		"Attention crew: unidentified festive entities spotted shipside. Please proceed with caution, and be on the lookout for unexpected gifts and seasonal cheer.",
		"Caution: Eggnog spill detected shipside. Investigate immediately for possible Santa sightings and confirm the presence of tinsel in all ventilation systems.",
		"Deck the halls with caution signs: Reports of tinsel entanglement shipside. Proceed with care, and be on the lookout for wayward ornaments.",
	)
	priority_announce(alert)

///randomly places some gifts around christmas tree during santa's arrival
/datum/round_event/santa_visit/proc/populate_presents()
	for(var/placedpresents = 1 to maxpresents)
		var/turf/target = locate(christmastreeturf.x + rand(-3, 3), christmastreeturf.y + rand(-3, 3), christmastreeturf.z)
		if(is_blocked_turf(target))
			continue
		else if(prob(25))
			new /obj/item/a_gift(target)

///proc for spawning santa(s) around christmas tree
/datum/round_event/santa_visit/proc/place_santa()
	for(var/placedsanta = 1 to maxsanta)
		var/turf/target = locate(christmastreeturf.x + rand(-3, 3), christmastreeturf.y + rand(-3, 3), christmastreeturf.z)
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
		var/datum/action/innate/summon_elves/elfsummoning = new(spawnedhuman)
		elfsummoning.give_action(spawnedhuman)
		var/datum/action/innate/elf_swap/swapelf = new(spawnedhuman)
		swapelf.give_action(spawnedhuman)
		var/datum/action/innate/summon_paperwork/summon_contract = new(spawnedhuman)
		summon_contract.give_action(spawnedhuman)
		spawnedhuman.offer_mob()
		spawnedhuman.objectivedatum = /datum/antagonist/event_santa
		set_target(pick(spawnedhuman))

///proc for spawning elves around christmas tree
/datum/round_event/santa_visit/proc/place_elves()
	for(var/placedelves = 1 to maxelves)
		if(prob(25))
			return
		var/turf/target = locate(christmastreeturf.x + rand(-3, 3), christmastreeturf.y + rand(-3, 3), christmastreeturf.z)
		var/mob/living/carbon/human/spawnedhuman = new /mob/living/carbon/human(target)
		ADD_TRAIT(spawnedhuman, TRAIT_CHRISTMAS_ELF, TRAIT_CHRISTMAS_ELF)
		spawnedhuman.name = "Elf [rand(1,999)]"
		spawnedhuman.real_name = spawnedhuman.name
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa/elf/eventspawn)
		spawnedhuman.apply_assigned_role_to_spawn(J)
		spawnedhuman.offer_mob()

///sets the target for this event, and notifies the hive
/datum/round_event/santa_visit/proc/set_target(mob/living/carbon/human/target)
	hive_target = target
	ADD_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target.med_hud_set_status()
	RegisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED, PROC_REF(handle_reward))
	xeno_message("The Queen Mother senses an outpouring of Christmas Spirit on the metal bird, concentrated in a man in red. Psydrain them for the Queen Mother's blessing!", force = TRUE)
	for(var/mob/living/carbon/xenomorph/xeno_sound_reciever in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		SEND_SOUND(xeno_sound_reciever, sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50))


//manages the hive reward and clean up
/datum/round_event/santa_visit/proc/handle_reward(datum/source, mob/living/carbon/xenomorph/drainer)
	SIGNAL_HANDLER
	xeno_message("[drainer] has killed the horrible man in red, ruining Christmas for the tallhosts. The Queen Mother empowers us for our success!", force = TRUE)
	bless_hive(drainer)
	REMOVE_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target.med_hud_set_status()
	hive_target = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED)

///Actually applies the buff to the hive
/datum/round_event/santa_visit/proc/bless_hive(mob/living/carbon/xenomorph/drainer)
	for(var/mob/living/carbon/xenomorph/receiving_xeno AS in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		receiving_xeno.add_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE, TRUE, 0, NONE, TRUE, -0.2)
		receiving_xeno.gain_plasma(receiving_xeno.xeno_caste.plasma_max)
		receiving_xeno.salve_healing()
		if(receiving_xeno == drainer)
			receiving_xeno.evolution_stored = receiving_xeno.xeno_caste.evolution_threshold
			receiving_xeno.upgrade_stored += 1000
	for(var/mob/living/carbon/xenomorph/xeno_sound_reciever in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		SEND_SOUND(xeno_sound_reciever, sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50))
	addtimer(CALLBACK(src, PROC_REF(remove_blessing)), 4 MINUTES)

///debuffs the hive when the blessing expires
/datum/round_event/santa_visit/proc/remove_blessing()
	xeno_message("We feel the Queen Mother's blessing fade", force = TRUE)
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		receiving_xeno.remove_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE)
