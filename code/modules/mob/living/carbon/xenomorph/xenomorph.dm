//Xenomorph "generic" parent, does not actually appear in game
//Many of these defines aren't referenced in the castes and so are assumed to be defaulted
//Castes are all merely subchildren of this parent
//Just about ALL the procs are tied to the parent, not to the children
//This is so they can be easily transferred between them without copypasta

/mob/living/carbon/xenomorph/Initialize(mapload)
	setup_verbs()
	. = ..()

	set_datum()
	time_of_birth = world.time
	add_inherent_verbs()
	var/datum/action/minimap/xeno/mini = new
	mini.give_action(src)
	add_abilities()
	create_reagents(1000)
	gender = NEUTER
	// To prevent this xeno from counting in bioscan
	if(!(src.xeno_caste.caste_flags & CASTE_NOT_IN_BIOSCAN))
		switch(stat)
			if(CONSCIOUS)
				GLOB.alive_xeno_list += src
				see_in_dark = xeno_caste.conscious_see_in_dark
			if(UNCONSCIOUS)
				GLOB.alive_xeno_list += src
				see_in_dark = xeno_caste.unconscious_see_in_dark
			if(DEAD)
				see_in_dark = xeno_caste.unconscious_see_in_dark

	GLOB.xeno_mob_list += src
	GLOB.round_statistics.total_xenos_created++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_xenos_created")

	if(is_centcom_level(z) && hivenumber == XENO_HIVE_NORMAL)
		hivenumber = XENO_HIVE_ADMEME //so admins can safely spawn xenos in Thunderdome for tests.

	wound_overlay = new(null, src)
	vis_contents += wound_overlay

	fire_overlay = mob_size == MOB_SIZE_BIG ? new(null, src) : new /atom/movable/vis_obj/xeno_wounds/fire_overlay/small(null, src)
	vis_contents += fire_overlay

	set_initial_hivenumber()

	generate_nicknumber()

	generate_name()

	regenerate_icons()

	hud_set_plasma()
	med_hud_set_health()

	toggle_xeno_mobhud() //This is a verb, but fuck it, it just werks

	update_spits()

	update_action_button_icons()

	if(!job) //It might be setup on spawn.
		setup_job()

	ADD_TRAIT(src, TRAIT_BATONIMMUNE, XENO_TRAIT)
	ADD_TRAIT(src, TRAIT_FLASHBANGIMMUNE, XENO_TRAIT)
	hive.update_tier_limits()
	if(CONFIG_GET(flag/xenos_on_strike))
		replace_by_ai()
	if(z) //Larva are initiated in null space
		SSminimaps.add_marker(src, z, hud_flags = MINIMAP_FLAG_XENO, iconstate = xeno_caste.minimap_icon)
	RegisterSignal(src, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED, .proc/handle_weeds_adjacent_removed)
	RegisterSignal(src, COMSIG_LIVING_WEEDS_AT_LOC_CREATED, .proc/handle_weeds_on_movement)
	handle_weeds_on_movement()

///Change the caste of the xeno. If restore health is true, then health is set to the new max health
/mob/living/carbon/xenomorph/proc/set_datum(restore_health_and_plasma = TRUE)
	if(!caste_base_type)
		CRASH("xeno spawned without a caste_base_type set")
	if(!GLOB.xeno_caste_datums[caste_base_type])
		CRASH("error finding base type")
	if(!GLOB.xeno_caste_datums[caste_base_type][upgrade])
		CRASH("error finding datum")
	if(xeno_caste)
		xeno_caste.on_caste_removed(src)
	var/datum/xeno_caste/X = GLOB.xeno_caste_datums[caste_base_type][upgrade]
	if(!istype(X))
		CRASH("error with caste datum")
	xeno_caste = X
	xeno_caste.on_caste_applied(src)
	maxHealth = xeno_caste.max_health * GLOB.xeno_stat_multiplicator_buff
	if(restore_health_and_plasma)
		// xenos that manage plasma through special means shouldn't gain it for free on aging
		plasma_stored = max(plasma_stored, xeno_caste.plasma_max * xeno_caste.plasma_regen_limit)
		health = maxHealth
	setXenoCasteSpeed(xeno_caste.speed)
	soft_armor = getArmor(arglist(xeno_caste.soft_armor))
	hard_armor = getArmor(arglist(xeno_caste.hard_armor))
	warding_aura = 0 //Resets aura for reapplying armor

///Will multiply the base max health of this xeno by GLOB.xeno_stat_multiplicator_buff while maintaining current health percent.
/mob/living/carbon/xenomorph/proc/apply_health_stat_buff()
	var/new_max_health = max(xeno_caste.max_health * GLOB.xeno_stat_multiplicator_buff, 10)
	var/needed_healing = 0

	if(health < 0) //In crit. Death threshold below 0 doesn't change with stat buff, so we can just apply damage equal to the max health change
		needed_healing = maxHealth - new_max_health //Positive means our max health is going down, so heal to keep parity
	else
		var/current_health_percent = health / maxHealth //We want to keep this fixed so that applying the scalar doesn't heal or harm, relatively.
		var/new_health = current_health_percent * new_max_health //What we're aiming for
		var/new_total_damage = new_max_health - new_health
		var/current_total_damage = maxHealth - health
		needed_healing = current_total_damage - new_total_damage

	var/brute_healing = min(getBruteLoss(), needed_healing)
	adjustBruteLoss(-brute_healing)
	adjustFireLoss(-(needed_healing - brute_healing))

	maxHealth = new_max_health
	updatehealth()

/mob/living/carbon/xenomorph/set_armor_datum()
	return //Handled in set_datum()


/mob/living/carbon/xenomorph/proc/generate_nicknumber()
	//We don't have a nicknumber yet, assign one to stick with us
	if(!nicknumber || nicknumber == "Undefined")
		var/tempnumber = rand(1, 999)
		var/list/xenolist = hive.get_all_xenos(FALSE)
		while(tempnumber in xenolist)
			tempnumber = rand(1, 999)

		nicknumber = tempnumber

//Off-load this proc so it can be called freely
//Since Xenos change names like they change shoes, we need somewhere to hammer in all those legos
//We set their name first, then update their real_name AND their mind name
/mob/living/carbon/xenomorph/proc/generate_name()
	name = "[hive.prefix][xeno_caste.upgrade_name] [xeno_caste.display_name] ([nicknumber])"

	//Update linked data so they show up properly
	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/proc/upgrade_as_number()
	switch(upgrade)
		if(XENO_UPGRADE_INVALID)
			return -1
		if(XENO_UPGRADE_ZERO)
			return 0
		if(XENO_UPGRADE_ONE)
			return 1
		if(XENO_UPGRADE_TWO)
			return 2
		if(XENO_UPGRADE_THREE)
			return 3
		if(XENO_UPGRADE_FOUR)
			return 4

/mob/living/carbon/xenomorph/proc/upgrade_next()
	switch(upgrade)
		if(XENO_UPGRADE_INVALID)
			return XENO_UPGRADE_INVALID
		if(XENO_UPGRADE_ZERO)
			return XENO_UPGRADE_ONE
		if(XENO_UPGRADE_ONE)
			return XENO_UPGRADE_TWO
		if(XENO_UPGRADE_TWO)
			return XENO_UPGRADE_THREE
		if(XENO_UPGRADE_THREE)
			return XENO_UPGRADE_FOUR
		if(XENO_UPGRADE_FOUR)
			return XENO_UPGRADE_FOUR

/mob/living/carbon/xenomorph/proc/upgrade_prev()
	switch(upgrade)
		if(XENO_UPGRADE_INVALID)
			return XENO_UPGRADE_INVALID
		if(XENO_UPGRADE_ZERO)
			return XENO_UPGRADE_ZERO
		if(XENO_UPGRADE_ONE)
			return XENO_UPGRADE_ZERO
		if(XENO_UPGRADE_TWO)
			return XENO_UPGRADE_ONE
		if(XENO_UPGRADE_THREE)
			return XENO_UPGRADE_TWO
		if(XENO_UPGRADE_FOUR)
			return XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/proc/setup_job()
	var/datum/job/xenomorph/xeno_job = SSjob.type_occupations[xeno_caste.job_type]
	if(!xeno_job)
		CRASH("Unemployment has reached to a xeno, who has failed to become a [xeno_caste.job_type]")
	apply_assigned_role_to_spawn(xeno_job)

/mob/living/carbon/xenomorph/proc/grabbed_self_attack()
	SIGNAL_HANDLER
	if(!(xeno_caste.can_flags & CASTE_CAN_RIDE_CRUSHER) || !isxenocrusher(pulling))
		return NONE
	var/mob/living/carbon/xenomorph/crusher/grabbed = pulling
	if(grabbed.stat == CONSCIOUS && stat == CONSCIOUS)
		INVOKE_ASYNC(grabbed, /mob/living/carbon/xenomorph/crusher/proc.carry_xeno, src, TRUE)
		return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK
	return NONE

///Initiate of form changing on the xeno
/mob/living/carbon/xenomorph/proc/change_form()
	return

/mob/living/carbon/xenomorph/examine(mob/user)
	. = ..()
	. += xeno_caste.caste_desc

	if(stat == DEAD)
		. += "It is DEAD. Kicked the bucket. Off to that great hive in the sky."
	else if(stat == UNCONSCIOUS)
		. += "It quivers a bit, but barely moves."
	else
		var/percent = (health / maxHealth * 100)
		switch(percent)
			if(95 to 101)
				. += "It looks quite healthy."
			if(75 to 94)
				. += "It looks slightly injured."
			if(50 to 74)
				. += "It looks injured."
			if(25 to 49)
				. += "It bleeds with sizzling wounds."
			if(1 to 24)
				. += "It is heavily injured and limping badly."

	if(hivenumber != XENO_HIVE_NORMAL)
		var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
		. += "It appears to belong to the [hive.prefix]hive"
	return

/mob/living/carbon/xenomorph/Destroy()
	if(mind) mind.name = name //Grabs the name when the xeno is getting deleted, to reference through hive status later.
	if(is_zoomed) zoom_out()
	GLOB.alive_xeno_list -= src
	GLOB.xeno_mob_list -= src
	GLOB.dead_xeno_list -= src

	var/datum/hive_status/hive_placeholder = hive
	remove_from_hive()
	hive_placeholder.update_tier_limits() //Update our tier limits.

	vis_contents -= wound_overlay
	vis_contents -= fire_overlay
	QDEL_NULL(wound_overlay)
	QDEL_NULL(fire_overlay)
	return ..()


/mob/living/carbon/xenomorph/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/living/carbon/xenomorph/start_pulling(atom/movable/AM, suppress_message = TRUE, bypass_crit_delay = FALSE)
	if(!isliving(AM))
		return FALSE
	if(!Adjacent(AM)) //Logic!
		return FALSE
	if(status_flags & INCORPOREAL || AM.status_flags & INCORPOREAL) //Incorporeal things can't grab or be grabbed.
		return FALSE
	var/mob/living/L = AM
	if(L.buckled)
		return FALSE //to stop xeno from pulling marines on roller beds.
	if(ishuman(L))
		if(L.stat == DEAD && (SSticker.mode?.flags_round_type & MODE_DEAD_GRAB_FORBIDDEN)) //Can't drag dead human bodies in distress
			to_chat(usr,span_xenowarning("This looks gross, better not touch it."))
			return FALSE
		do_attack_animation(L, ATTACK_EFFECT_GRAB)
		pull_speed += XENO_DEADHUMAN_DRAG_SLOWDOWN
	SEND_SIGNAL(src, COMSIG_XENOMORPH_GRAB)
	return ..()

/mob/living/carbon/xenomorph/stop_pulling()
	if(ishuman(pulling))
		pull_speed -= XENO_DEADHUMAN_DRAG_SLOWDOWN
	return ..()

/mob/living/carbon/xenomorph/pull_response(mob/puller)
	if(stat != CONSCIOUS) // If the Xeno is unconscious, don't fight back against a grab/pull
		return TRUE
	if(!ishuman(puller))
		return TRUE
	var/mob/living/carbon/human/H = puller
	H.Paralyze(rand(xeno_caste.tacklemin,xeno_caste.tacklemax) * 20)
	playsound(H.loc, 'sound/weapons/pierce.ogg', 25, 1)
	H.visible_message(span_warning("[H] tried to pull [src] but instead gets a tail swipe to the head!"))
	H.stop_pulling()
	return FALSE

/mob/living/carbon/xenomorph/resist_grab()
	if(pulledby.grab_state)
		visible_message(span_danger("[src] has broken free of [pulledby]'s grip!"), null, null, 5)
	pulledby.stop_pulling()
	. = 1



/mob/living/carbon/xenomorph/prepare_huds()
	..()
	//updating all the mob's hud images
	med_hud_set_health()
	hud_set_plasma()
	hud_set_pheromone()
	//and display them
	add_to_all_mob_huds()

	var/datum/atom_hud/hud_to_add = GLOB.huds[DATA_HUD_XENO_INFECTION]
	hud_to_add.add_hud_to(src)

	hud_to_add = GLOB.huds[DATA_HUD_BASIC]
	hud_to_add.add_hud_to(src)

	hud_to_add = GLOB.huds[DATA_HUD_XENO_REAGENTS]
	hud_to_add.add_hud_to(src)
	hud_to_add = GLOB.huds[DATA_HUD_XENO_TACTICAL] //Allows us to see xeno tactical elements clearly via HUD elements
	hud_to_add.add_hud_to(src)
	hud_to_add = GLOB.huds[DATA_HUD_MEDICAL_PAIN]
	hud_to_add.add_hud_to(src)
	hud_to_add = GLOB.huds[DATA_HUD_XENO_DEBUFF]
	hud_to_add.add_hud_to(src)

/mob/living/carbon/xenomorph/get_permeability_protection()
	return XENO_PERM_COEFF

/mob/living/carbon/xenomorph/get_eye_protection()
	return 2

/mob/living/carbon/xenomorph/vomit()
	return

/mob/living/carbon/xenomorph/reagent_check(datum/reagent/R) //For the time being they can't metabolize chemicals.
	return TRUE

/mob/living/carbon/xenomorph/update_tracking(mob/living/carbon/xenomorph/X) //X is unused, but we keep that function so it can be called with marines one
	if(!hud_used?.locate_leader)
		return
	var/obj/screen/LL_dir = hud_used.locate_leader
	if(!tracked)
		if(hive.living_xeno_ruler)
			set_tracked(hive.living_xeno_ruler)
		else
			LL_dir.icon_state = "trackoff"
			return

	if(tracked == src) // No need to track ourselves
		LL_dir.icon_state = "trackoff"
		return
	if(tracked.z != z || get_dist(src, tracked) < 1)
		LL_dir.icon_state = "trackondirect"
		return
	var/area/A = get_area(loc)
	var/area/QA = get_area(tracked.loc)
	if(A.fake_zlevel == QA.fake_zlevel)
		LL_dir.icon_state = "trackon"
		LL_dir.setDir(get_dir(src, tracked))
		return

	LL_dir.icon_state = "trackondirect"
	return


/mob/living/carbon/xenomorph/clear_leader_tracking()
	if(!hud_used?.locate_leader)
		return

	var/obj/screen/LL_dir = hud_used.locate_leader
	LL_dir.icon_state = "trackoff"


/mob/living/carbon/xenomorph/Moved(atom/old_loc, movement_dir)
	if(is_zoomed)
		zoom_out()
	handle_weeds_on_movement()
	return ..()

/mob/living/carbon/xenomorph/set_stat(new_stat)
	. = ..()
	if(isnull(.))
		return
	switch(stat)
		if(UNCONSCIOUS)
			see_in_dark = xeno_caste.unconscious_see_in_dark
		if(DEAD, CONSCIOUS)
			if(. == UNCONSCIOUS)
				see_in_dark = xeno_caste.conscious_see_in_dark

///Kick the player from this mob, replace it by a more competent ai
/mob/living/carbon/xenomorph/proc/replace_by_ai()
	to_chat(src, span_warning("Sorry, your skill level was deemed too low by our automatic skill check system. Your body has as such been given to a more capable brain, our state of the art AI technology piece. Do not hesitate to take back your body after you've improved!"))
	ghostize(TRUE)//Can take back its body
	GLOB.offered_mob_list -= src
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)
	a_intent = INTENT_HARM

/// Handles logic for weeds nearby the xeno getting removed
/mob/living/carbon/xenomorph/proc/handle_weeds_adjacent_removed(datum/source)
	SIGNAL_HANDLER
	var/obj/alien/weeds/found_weed = locate(/obj/alien/weeds) in loc
	if(!QDESTROYING(found_weed))
		return
	loc_weeds_type = null

/// Handles logic for the xeno moving to a new weeds tile
/mob/living/carbon/xenomorph/proc/handle_weeds_on_movement(datum/source)
	SIGNAL_HANDLER
	var/obj/alien/weeds/found_weed = locate(/obj/alien/weeds) in loc
	loc_weeds_type = found_weed?.type

#define BURROW_FIRE_RESIST_MODIFIER 20

/// Burrow code for xenomorphs
/mob/living/carbon/xenomorph/proc/xeno_burrow()
	SIGNAL_HANDLER
	if(!(src.xeno_caste.can_flags & CASTE_CAN_BURROW))
		return
	if(!burrowed)
		to_chat(src, span_xenowarning("We start burrowing into the ground"))
		INVOKE_ASYNC(src, .proc/xeno_burrow_doafter, src)
		return
	if(burrowed)
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		fire_resist_modifier += BURROW_FIRE_RESIST_MODIFIER
		icon_state = initial(icon_state)
		mouse_opacity = initial(mouse_opacity)
		density = TRUE
		throwpass = FALSE
		burrowed = FALSE
		canmove = TRUE
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, src)

/// Called by xeno_burrow only when burrowing
/mob/living/carbon/xenomorph/proc/xeno_burrow_doafter()
	if(!do_after(src, 3 SECONDS, TRUE, null, BUSY_ICON_DANGER))
		return
	to_chat(src, span_xenowarning("We have burrowed ourselves, we are hidden from the enemy"))
	// This part here actually burrows the xeno
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = FALSE
	throwpass = TRUE
	burrowed = TRUE
	icon_state = "[xeno_caste.caste_name] Burrowed" // We set it here so we dont wait for life
	wound_overlay.icon_state = "none" // We set it here so we dont wait for life
	// Here we prevent the xeno from moving or attacking or using abilities untill they unburrow by clicking the ability
	fire_resist_modifier -= BURROW_FIRE_RESIST_MODIFIER // This makes the xeno immune to fire while burrowed, even if burning beforehand
	canmove = FALSE
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, src)
	// We register for movement so that we unburrow if bombed
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/xeno_burrow)
