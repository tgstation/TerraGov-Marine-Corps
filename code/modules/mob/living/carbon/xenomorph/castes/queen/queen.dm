/mob/living/carbon/xenomorph/queen
	caste_base_type = /mob/living/carbon/xenomorph/queen
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	amount_grown = 0
	max_grown = 10
	plasma_stored = 300
	speed = 0.6
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_FOUR //Queen doesn't count towards population limit.
	upgrade = XENO_UPGRADE_ZERO
	job = ROLE_XENO_QUEEN

	var/breathing_counter = 0
	var/ovipositor = FALSE //whether the Queen is attached to an ovipositor
	var/ovipositor_cooldown = 0
	var/queen_ability_cooldown = 0
	var/mob/living/carbon/xenomorph/observed_xeno //the Xenomorph the queen is currently overwatching
	var/egg_amount = 0 //amount of eggs inside the queen
	var/last_larva_time = 0
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/claw_toggle,
		/mob/living/carbon/xenomorph/queen/proc/set_orders,
		/mob/living/carbon/xenomorph/queen/proc/hive_Message,
		/mob/living/carbon/xenomorph/proc/calldown_dropship
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/queen/Initialize()
	RegisterSignal(src, COMSIG_HIVE_BECOME_RULER, .proc/on_becoming_ruler)
	. = ..()
	hive.RegisterSignal(src, COMSIG_HIVE_XENO_DEATH, /datum/hive_status.proc/on_queen_death)
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0)


/mob/living/carbon/xenomorph/queen/Destroy()
	. = ..()
	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/queen/handle_decay()
	if(prob(20+abs(3*upgrade_as_number())))
		use_plasma(min(rand(1,2), plasma_stored))

/mob/living/carbon/xenomorph/queen/Life()
	. = ..()

	if(stat == DEAD)
		return

	if(observed_xeno)
		if(observed_xeno.stat == DEAD || observed_xeno.gc_destroyed)
			set_queen_overwatch(observed_xeno, TRUE)

	if(!ovipositor || incapacitated(TRUE))
		return

	hive?.on_queen_life(src)

	egg_amount += 0.07 //one egg approximately every 30 seconds
	if(egg_amount < 1)
		return

	if(!isturf(loc))
		return

	var/turf/T = loc
	if(T.contents.len > 25) //so we don't end up with a million object on that turf.
		return

	egg_amount--
	var/obj/item/xeno_egg/newegg = new /obj/item/xeno_egg(loc)
	newegg.hivenumber = hivenumber

// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/queen/update_canmove()
	. = ..()
	if(ovipositor)
		lying = FALSE
		density = TRUE
		canmove = FALSE
		return canmove

/mob/living/carbon/xenomorph/queen/reset_perspective(atom/A)
	if (!client)
		return

	if(ovipositor && observed_xeno && !stat)
		client.perspective = EYE_PERSPECTIVE
		client.eye = observed_xeno
		return

	if (ismovableatom(A))
		client.perspective = EYE_PERSPECTIVE
		client.eye = A
		return

	if (isturf(loc))
		client.eye = client.mob
		client.perspective = MOB_PERSPECTIVE
		return

	client.perspective = EYE_PERSPECTIVE
	client.eye = loc

// ***************************************
// *********** Name
// ***************************************
/mob/living/carbon/xenomorph/queen/generate_name()
	switch(upgrade)
		if(XENO_UPGRADE_ZERO) 
			name = "[hive.prefix]Queen"			 //Young
		if(XENO_UPGRADE_ONE) 
			name = "[hive.prefix]Elder Queen"	 //Mature
		if(XENO_UPGRADE_TWO) 
			name = "[hive.prefix]Elder Empress"	 //Elder
		if(XENO_UPGRADE_THREE) 
			name = "[hive.prefix]Ancient Empress" //Ancient

	real_name = name
	if(mind) 
		mind.name = name 

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/queen/handle_special_state()
	if(ovipositor)
		icon = 'icons/Xeno/Ovipositor.dmi'
		icon_state = "Queen Ovipositor"
		return TRUE
	icon = initial(icon)
	return FALSE

/mob/living/carbon/xenomorph/queen/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["watch_xeno_number"])
		if(!check_state())
			return
		if(!ovipositor)
			return
		var/xeno_num = text2num(href_list["watch_xeno_number"])
		for(var/Y in hive.get_watchable_xenos())
			var/mob/living/carbon/xenomorph/X = Y
			if(X.nicknumber != xeno_num)
				continue
			if(observed_xeno == X)
				set_queen_overwatch(X, TRUE)
			else
				set_queen_overwatch(X)
			break


// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/queen/gib()
	death(1) //we need the body to show the queen's name at round end.

/mob/living/carbon/xenomorph/queen/death_cry()
	playsound(loc, 'sound/voice/alien_queen_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/queen/xeno_death_alert()
	return

/mob/living/carbon/xenomorph/queen/death(gibbed)
	. = ..()
	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)
	if(ovipositor)
		dismount_ovipositor(TRUE)


// ***************************************
// *********** Larva Mother
// ***************************************

/mob/living/carbon/xenomorph/queen/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	if(!incapacitated(TRUE))
		mothers += src //Adding us to the list.
