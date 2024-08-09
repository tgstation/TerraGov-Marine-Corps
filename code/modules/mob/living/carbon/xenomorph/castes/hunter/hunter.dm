/mob/living/carbon/xenomorph/hunter
	caste_base_type = /datum/xeno_caste/hunter
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/castes/hunter.dmi'
	icon_state = "Hunter Running"
	bubble_icon = "alien"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/hunter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)

/mob/living/carbon/xenomorph/hunter/weapon_x
	caste_base_type = /datum/xeno_caste/hunter/weapon_x

/mob/living/carbon/xenomorph/hunter/weapon_x/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(terminate_specimen))

///Removed the xeno after the mission ends
/mob/living/carbon/xenomorph/hunter/weapon_x/proc/terminate_specimen()
	SIGNAL_HANDLER
	qdel(src)

/mob/living/carbon/xenomorph/hunter/assassin
	icon_state = "Assassin Hunter Running"
	caste_base_type = /datum/xeno_caste/hunter/assassin


/mob/living/carbon/xenomorph/hunter/assassin/change_form()
	if(!loc_weeds_type)
		to_chat(src, span_xenowarning("We need to be on weeds for us to shift again."))
		return
	wound_overlay.icon_state = "none"
	if(do_after(src, 3 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_BAR, NONE, PROGRESS_GENERIC)) //dont move
		do_change_form()

///Finish the form changing of the hunter and give the needed stats
/mob/living/carbon/xenomorph/hunter/assassin/proc/do_change_form()
	playsound(get_turf(src), 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	if(status_flags & INCORPOREAL)
		var/turf/whereweat = get_turf(src)
		if(whereweat.get_lumcount() == 0) //is it a lit turf
			adjust_stagger(6 SECONDS) //think xenos get like half times on stuns due some multiplier, maybe less.
			adjust_slowdown(6 SECONDS)
		for(var/obj/machinery/light/lightie in range(rand(5,7), whereweat))
			lightie.set_flicker(rand(3 SECONDS, 5 SECONDS), 3, 6)
		status_flags = initial(status_flags)
		resistance_flags = initial(resistance_flags)
		pass_flags = initial(pass_flags)
		density = TRUE
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, src)
		alpha = 255
		color = initial(color)
		xeno_caste.speed = initial(xeno_caste.speed)
		update_wounds()
		update_icon()
		update_action_buttons()
	else
		var/turf/whereweat = get_turf(src)
		for(var/obj/machinery/light/lightie in range(rand(5,7), whereweat))
			lightie.set_flicker(rand(3 SECONDS, 5 SECONDS), 3, 6)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, src)
		status_flags = INCORPOREAL
		alpha = 15 //like a shadow
		color = "#4a003a"
		xeno_caste.speed *= 0.5
		resistance_flags = BANISH_IMMUNE
		pass_flags = PASS_MOB|PASS_XENO
		density = FALSE
		update_wounds()
		update_icon()
		update_action_buttons()
