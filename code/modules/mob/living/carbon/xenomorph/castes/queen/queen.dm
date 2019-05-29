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
	xeno_explosion_resistance = 3 //some resistance against explosion stuns.
	job = ROLE_XENO_QUEEN

	var/breathing_counter = 0
	var/ovipositor = FALSE //whether the Queen is attached to an ovipositor
	var/ovipositor_cooldown = 0
	var/queen_ability_cooldown = 0
	var/mob/living/carbon/xenomorph/observed_xeno //the Xenomorph the queen is currently overwatching
	var/egg_amount = 0 //amount of eggs inside the queen
	var/last_larva_time = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/grow_ovipositor,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid,
		// /datum/action/xeno_action/activable/gut, We're taking this out for now.
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/larva_growth,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/claw_toggle,
		/mob/living/carbon/xenomorph/queen/proc/set_orders,
		/mob/living/carbon/xenomorph/queen/proc/hive_Message
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/queen/Initialize()
	. = ..()
	if(!is_centcom_level(z))//so admins can safely spawn Queens in Thunderdome for tests.
		hive.update_queen()
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
//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/xenomorph/queen/Bump(atom/A, yes)
	set waitfor = 0

	//if(charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE || !is_charging) return ..()

	if(stat || !A || !istype(A) || A == src || !yes) return FALSE

	if(now_pushing) return FALSE//Just a plain ol turf, let's return.

	/*if(dir != charge_dir) //We aren't facing the way we're charging.
		stop_momentum()
		return ..()

	if(!handle_collision(A))
		if(!A.charge_act(src)) //charge_act is depricated and only here to handle cases that have not been refactored as of yet.
			return ..()*/

	var/turf/T = get_step(src, dir)
	if(!T || !get_step_to(src, T)) //If it still exists, try to push it.
		return ..()

	lastturf = null //Reset this so we can properly continue with momentum.
	return TRUE

/mob/living/carbon/xenomorph/queen/update_canmove()
	. = ..()
	if(ovipositor)
		lying = FALSE
		density = TRUE
		canmove = FALSE
		return canmove

/mob/living/carbon/xenomorph/queen/reset_view(atom/A)
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
	if (href_list["watch_xeno_number"])
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
		return
	..()

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
