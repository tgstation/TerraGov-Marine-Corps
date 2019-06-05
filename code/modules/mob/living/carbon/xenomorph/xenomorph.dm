//Xenomorph "generic" parent, does not actually appear in game
//Many of these defines aren't referenced in the castes and so are assumed to be defaulted
//Castes are all merely subchildren of this parent
//Just about ALL the procs are tied to the parent, not to the children
//This is so they can be easily transferred between them without copypasta

/mob/living/carbon/xenomorph/Initialize()
	verbs += /mob/living/proc/lay_down
	. = ..()

	set_datum()
	//WO GAMEMODE
	if(SSmapping.config.map_name == MAP_WHISKEY_OUTPOST)
		xeno_caste.hardcore = 1 //Prevents healing and queen evolution
	time_of_birth = world.time
	add_inherent_verbs()
	add_abilities()

	ENABLE_BITFIELD(sight, SEE_MOBS)
	ENABLE_BITFIELD(sight, SEE_OBJS)
	ENABLE_BITFIELD(sight, SEE_TURFS)
	see_in_dark = XENO_NIGHTVISION_ENABLED

	create_reagents(1000)
	gender = NEUTER

	GLOB.alive_xeno_list += src
	GLOB.xeno_mob_list += src
	round_statistics.total_xenos_created++

	set_initial_hivenumber()

	generate_nicknumber()

	generate_name()

	regenerate_icons()

	hud_set_plasma()
	med_hud_set_health()

	toggle_xeno_mobhud() //This is a verb, but fuck it, it just werks

	update_spits()

	update_action_button_icons()

/mob/living/carbon/xenomorph/proc/set_datum()
	if(!caste_base_type)
		CRASH("xeno spawned without a caste_base_type set")
	if(!GLOB.xeno_caste_datums[caste_base_type])
		CRASH("error finding base type")
	if(!GLOB.xeno_caste_datums[caste_base_type][upgrade])
		CRASH("error finding datum")
	var/datum/xeno_caste/X = GLOB.xeno_caste_datums[caste_base_type][upgrade]
	if(!istype(X))
		CRASH("error with caste datum")
	xeno_caste = X

	plasma_stored = xeno_caste.plasma_max
	maxHealth = xeno_caste.max_health
	health = maxHealth
	speed = xeno_caste.speed

/mob/living/carbon/xenomorph/proc/generate_nicknumber()
	//We don't have a nicknumber yet, assign one to stick with us
	if(!nicknumber)
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

/mob/living/carbon/xenomorph/proc/tier_as_number()
	switch(tier)
		if(XENO_TIER_ZERO)
			return 0
		if(XENO_TIER_ONE)
			return 1
		if(XENO_TIER_TWO)
			return 2
		if(XENO_TIER_THREE)
			return 3

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
			return XENO_UPGRADE_THREE

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

/mob/living/carbon/xenomorph/examine(mob/user)
	..()
	if(isxeno(user) && xeno_caste.caste_desc)
		to_chat(user, xeno_caste.caste_desc)

	if(stat == DEAD)
		to_chat(user, "It is DEAD. Kicked the bucket. Off to that great hive in the sky.")
	else if(stat == UNCONSCIOUS)
		to_chat(user, "It quivers a bit, but barely moves.")
	else
		var/percent = (health / maxHealth * 100)
		switch(percent)
			if(95 to 101)
				to_chat(user, "It looks quite healthy.")
			if(75 to 94)
				to_chat(user, "It looks slightly injured.")
			if(50 to 74)
				to_chat(user, "It looks injured.")
			if(25 to 49)
				to_chat(user, "It bleeds with sizzling wounds.")
			if(1 to 24)
				to_chat(user, "It is heavily injured and limping badly.")

	if(hivenumber != XENO_HIVE_NORMAL)
		var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
		to_chat(user, "It appears to belong to the [hive.prefix]hive")
	return

/mob/living/carbon/xenomorph/Destroy()
	if(mind) mind.name = name //Grabs the name when the xeno is getting deleted, to reference through hive status later.
	if(is_zoomed) zoom_out()

	GLOB.alive_xeno_list -= src
	GLOB.xeno_mob_list -= src
	GLOB.dead_xeno_list -= src

	remove_from_hive()

	. = ..()



/mob/living/carbon/xenomorph/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/living/carbon/xenomorph/handle_knocked_out()
	if(knocked_out)
		AdjustKnockedout(-2)
	return knocked_out

/mob/living/carbon/xenomorph/start_pulling(atom/movable/AM, no_msg)
	if(!isliving(AM))
		return FALSE
	var/mob/living/L = AM
	if(L.buckled)
		return FALSE //to stop xeno from pulling marines on roller beds.
	if(ishuman(L))
		pull_speed += XENO_DEADHUMAN_DRAG_SLOWDOWN
	SEND_SIGNAL(src, COMSIG_XENOMORPH_GRAB)
	return ..()

/mob/living/carbon/xenomorph/stop_pulling()
	if(pulling && ishuman(pulling))
		pull_speed -= XENO_DEADHUMAN_DRAG_SLOWDOWN
	return ..()

/mob/living/carbon/xenomorph/pull_response(mob/puller)
	var/mob/living/carbon/human/H = puller
	if(stat == CONSCIOUS && H.species?.count_human) // If the Xeno is conscious, fight back against a grab/pull
		H.KnockDown(rand(xeno_caste.tacklemin,xeno_caste.tacklemax))
		playsound(H.loc, 'sound/weapons/pierce.ogg', 25, 1)
		H.visible_message("<span class='warning'>[H] tried to pull [src] but instead gets a tail swipe to the head!</span>")
		H.stop_pulling()
		return FALSE
	return TRUE

/mob/living/carbon/xenomorph/resist_grab(moving_resist)
	if(pulledby.grab_level)
		visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>", null, null, 5)
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
	var/datum/atom_hud/MH = GLOB.huds[DATA_HUD_XENO_INFECTION]
	MH.add_hud_to(src)



/mob/living/carbon/xenomorph/point_to_atom(atom/A, turf/T)
	//xeno leader get a bit arrow and less cooldown
	if(queen_chosen_lead || isxenoqueen(src))
		recently_pointed_to = world.time + 10
		new /obj/effect/overlay/temp/point/big(T)
	else
		recently_pointed_to = world.time + 50
		new /obj/effect/overlay/temp/point(T)
	visible_message("<b>[src]</b> points to [A]")
	return 1

/mob/living/carbon/xenomorph/get_permeability_protection()
	return XENO_PERM_COEFF

/mob/living/carbon/xenomorph/get_eye_protection()
	return 2

/mob/living/carbon/xenomorph/need_breathe()
	return FALSE

/mob/living/carbon/xenomorph/vomit()
	return

/mob/living/carbon/xenomorph/reagent_check(datum/reagent/R) //For the time being they can't metabolize chemicals.
	return TRUE

/mob/living/carbon/xenomorph/update_leader_tracking(mob/living/carbon/xenomorph/X)
	if(!hud_used?.locate_leader)
		return

	var/obj/screen/LL_dir = hud_used.locate_leader
	if(xeno_caste.caste_flags & CASTE_IS_INTELLIGENT)
		LL_dir.icon_state = "trackoff"
		return

	if(X.z != src.z || get_dist(src,X) < 1 || src == X)
		LL_dir.icon_state = "trackondirect"
	else
		var/area/A = get_area(src.loc)
		var/area/QA = get_area(X.loc)
		if(A.fake_zlevel == QA.fake_zlevel)
			LL_dir.icon_state = "trackon"
			LL_dir.setDir(get_dir(src, X))
		else
			LL_dir.icon_state = "trackondirect"

/mob/living/carbon/xenomorph/clear_leader_tracking()
	if(!hud_used?.locate_leader)
		return

	var/obj/screen/LL_dir = hud_used.locate_leader
	LL_dir.icon_state = "trackoff"

/mob/living/carbon/xenomorph/begin_away()
	. = ..()
	addtimer(CALLBACK(src, .proc/handle_afk_takeover), XENO_AFK_TIMER)


/mob/living/carbon/xenomorph/Moved(atom/newloc, direct)
	if(is_zoomed)
		zoom_out()
	return ..()