/datum/action/observer_action/can_use_action()
	. = ..()
	if(!.)
		return FALSE
	if(!isobserver(owner))
		return FALSE
	return TRUE


/datum/action/observer_action/crew_manifest
	name = "Show Crew manifest"
	action_icon = 'icons/obj/items/books.dmi'
	action_icon_state = "book"


/datum/action/observer_action/crew_manifest/action_activate()
	if(!can_use_action())
		return FALSE
	var/mob/dead/observer/O = owner
	O.view_manifest()


/datum/action/observer_action/show_hivestatus
	name = "Show Hive status"
	action_icon_state = "watch_xeno"


/datum/action/observer_action/show_hivestatus/action_activate()
	if(!can_use_action())
		return FALSE
	check_hive_status(usr)

/datum/action/observer_action/join_larva_queue
	name = "Join Larva Queue"
	action_icon_state = "larva_queue"

/datum/action/observer_action/join_larva_queue/action_activate()
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(HS.add_to_larva_candidate_queue(owner))
		add_selected_frame()
		return
	remove_selected_frame()

/datum/action/observer_action/take_ssd_mob
	name = "Take SSD mob"
	action_icon_state = "take_ssd"

/datum/action/observer_action/take_ssd_mob/action_activate()
	var/mob/dead/observer/dead_owner = owner
	if(GLOB.key_to_time_of_death[owner.key] + TIME_BEFORE_TAKING_BODY > world.time && !dead_owner.started_as_observer)
		to_chat(owner, span_warning("You died too recently to be able to take a new mob."))
		return

	var/list/mob/living/free_ssd_mobs = list()
	for(var/mob/living/ssd_mob AS in GLOB.ssd_living_mobs)
		if(is_centcom_level(ssd_mob.z) || ssd_mob.afk_status == MOB_RECENTLY_DISCONNECTED)
			continue
		if(isxeno(ssd_mob))
			var/mob/living/carbon/xenomorph/potential_minion = ssd_mob
			if((potential_minion.xeno_caste.caste_flags & CASTE_IS_A_MINION) && !potential_minion.hive.purchases.upgrades_by_name[GHOSTS_CAN_TAKE_MINIONS].times_bought)
				continue
		free_ssd_mobs += ssd_mob

	if(!free_ssd_mobs.len)
		to_chat(owner, span_warning("There aren't any SSD mobs."))
		return FALSE

	var/mob/living/new_mob = tgui_input_list(owner, "Pick a mob", "Available Mobs", free_ssd_mobs)
	if(!istype(new_mob) || !owner.client)
		return FALSE

	if(new_mob.stat == DEAD)
		to_chat(owner, span_warning("You cannot join if the mob is dead."))
		return FALSE

	if(new_mob.client)
		to_chat(owner, span_warning("That mob has been occupied."))
		return FALSE

	if(new_mob.afk_status == MOB_RECENTLY_DISCONNECTED) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(owner, span_warning("That player hasn't been away long enough. Please wait [round(timeleft(new_mob.afk_timer_id) * 0.1)] second\s longer."))
		return FALSE

	if(is_banned_from(owner.ckey, new_mob?.job?.title))
		to_chat(owner, span_warning("You are jobbaned from the [new_mob?.job.title] role."))
		return
	message_admins(span_adminnotice("[owner.key] took control of [new_mob.name] as [new_mob.p_they()] was ssd."))
	log_admin("[owner.key] took control of [new_mob.name] as [new_mob.p_they()] was ssd.")
	new_mob.transfer_mob(owner)
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/H = new_mob
	H.fully_replace_character_name(H.real_name, H.species.random_name(H.gender))
