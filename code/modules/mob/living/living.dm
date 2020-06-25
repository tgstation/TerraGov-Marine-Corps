/mob/living/proc/Life()
	if(stat != DEAD)

		handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

		handle_regular_hud_updates()

		handle_organs()

		updatehealth()


//this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	if(no_stun)//anti-chainstun flag for alien tackles
		no_stun = max(0, no_stun - 1) //decrement by 1.

	handle_drugged()
	handle_stuttering()
	handle_slurring()


/mob/living/proc/handle_organs()
	reagent_shock_modifier = 0
	reagent_pain_modifier = 0

/mob/living/proc/handle_stuttering()
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	return stuttering

/mob/living/proc/handle_drugged()
	if(druggy)
		adjust_drugginess(-1)
	return druggy

/mob/living/proc/handle_slurring()
	if(slurring)
		slurring = max(slurring-1, 0)
	return slurring


/mob/living/proc/handle_staminaloss()
	if(world.time < last_staminaloss_dmg + 3 SECONDS)
		return
	if(staminaloss > 0)
		adjustStaminaLoss(-maxHealth * 0.2, TRUE, FALSE)
	else if(staminaloss > -max_stamina_buffer)
		adjustStaminaLoss(-max_stamina_buffer * 0.08, TRUE, FALSE)


/mob/living/proc/handle_regular_hud_updates()
	if(!client)
		return FALSE

/mob/living/proc/add_slowdown(amount)
	return

/mob/living/proc/adjust_stagger(amount)
	return

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat()

/mob/living/update_stat()
	. = ..()
	update_cloak()

/mob/living/Initialize()
	. = ..()
	register_init_signals()
	update_move_intent_effects()
	GLOB.mob_living_list += src
	if(stat != DEAD)
		GLOB.alive_living_list += src
	START_PROCESSING(SSmobs, src)

	set_armor_datum()

/mob/living/Destroy()
	for(var/i in embedded_objects)
		var/obj/item/embedded = i
		if(embedded.embedding.embedded_flags & EMBEDDEED_DEL_ON_HOLDER_DEL)
			qdel(embedded) //This should remove the object from the list via temporarilyRemoveItemFromInventory() => COMSIG_ITEM_DROPPED.
		else
			embedded.unembed_ourself() //This should remove the object from the list directly.
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	GLOB.alive_living_list -= src
	GLOB.mob_living_list -= src
	GLOB.offered_mob_list -= src
	STOP_PROCESSING(SSmobs, src)
	job = null
	return ..()


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return


/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		for(var/obj/item/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += contents
		for(var/obj/item/storage/S in contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/gift/G in contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L


/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/O in L)
		if(O.type == A)
			return TRUE
	return FALSE


/mob/living/proc/set_armor_datum()
	if(islist(soft_armor))
		soft_armor = getArmor(arglist(soft_armor))
	else if (!soft_armor)
		soft_armor = getArmor()
	else if (!istype(soft_armor, /datum/armor))
		stack_trace("Invalid type [soft_armor.type] found in .soft_armor during [type] Initialize()")

	if(islist(hard_armor))
		hard_armor = getArmor(arglist(hard_armor))
	else if (!hard_armor)
		hard_armor = getArmor()
	else if (!istype(hard_armor, /datum/armor))
		stack_trace("Invalid type [hard_armor.type] found in .hard_armor during [type] Initialize()")


/mob/living/proc/get_limbzone_target()
	return ran_zone(zone_selected)



/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/InCritical()
	return (health <= get_crit_threshold() && stat == UNCONSCIOUS)


/mob/living/Move(atom/newloc, direct)
	if(buckled)
		if(buckled.loc != newloc) //not updating position
			if(!buckled.anchored)
				return buckled.Move(newloc, direct)
			else
				return FALSE
	else if(lying_angle)
		if(direct & EAST)
			set_lying_angle(90)
		else if(direct & WEST)
			set_lying_angle(270)

	. = ..()

	if(pulledby)
		if(moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1 && (pulledby != moving_from_pull))//separated from our puller and not in the middle of a diagonal move.
			pulledby.stop_pulling()
		else if(isliving(pulledby))
			var/mob/living/living_puller = pulledby
			living_puller.set_pull_offsets(src)

	if(s_active && !(s_active in contents) && !CanReach(s_active))
		s_active.close(src)


/mob/living/Moved(oldLoc, dir)
	. = ..()
	update_camera_location(oldLoc)


/mob/living/forceMove(atom/destination)
	. = ..()
	//Only bother updating the camera if we actually managed to move
	if(.)
		update_camera_location(destination)
		if(client)
			reset_perspective()


/mob/living/proc/do_camera_update(oldLoc)
	return


/mob/living/proc/update_camera_location(oldLoc)
	return


/mob/living/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Add Language"] = "?_src_=vars;[HrefToken()];addlanguage=[REF(src)]"
	.["Remove Language"] = "?_src_=vars;[HrefToken()];remlanguage=[REF(src)]"


/mob/proc/resist_grab()
	return //returning 1 means we successfully broke free


/mob/living/proc/do_resist_grab()
	if(restrained(RESTRAINED_NECKGRAB))
		return FALSE
	if(COOLDOWN_CHECK(src, COOLDOWN_RESIST))
		return FALSE
	COOLDOWN_START(src, COOLDOWN_RESIST, CLICK_CD_RESIST)
	if(pulledby.grab_state >= GRAB_AGGRESSIVE)
		visible_message("<span class='danger'>[src] resists against [pulledby]'s grip!</span>")
	return resist_grab()


/mob/living/proc/do_move_resist_grab()
	if(restrained(RESTRAINED_NECKGRAB))
		return FALSE
	if(COOLDOWN_CHECK(src, COOLDOWN_RESIST))
		return FALSE
	COOLDOWN_START(src, COOLDOWN_RESIST, CLICK_CD_RESIST)
	if(pulledby.grab_state >= GRAB_AGGRESSIVE)
		visible_message("<span class='danger'>[src] struggles to break free of [pulledby]'s grip!</span>", null, null, 5)
	return resist_grab()


/mob/living/resist_grab()
	if(!pulledby.grab_state)
		grab_resist_level = 0 //zero it out.
		pulledby.stop_pulling()
		return TRUE
	if(++grab_resist_level < pulledby.grab_state)
		return FALSE
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)
	if(pulledby.grab_state >= GRAB_AGGRESSIVE)
		visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>", null, null, 5)
	pulledby.stop_pulling()
	grab_resist_level = 0 //zero it out.
	return TRUE


/mob/living/stop_pulling()
	if(ismob(pulling))
		reset_pull_offsets(pulling)
		var/mob/M = pulling
		if(M.client)
			//resist_grab uses long movement cooldown durations to prevent message spam
			//so we must undo it here so the victim can move right away
			M.client.move_delay = world.time

		if(isliving(pulling))
			var/mob/living/L = pulling
			L.grab_resist_level = 0 //zero it out
			DISABLE_BITFIELD(L.restrained_flags, RESTRAINED_NECKGRAB)

	. = ..()

	if(istype(r_hand, /obj/item/grab))
		temporarilyRemoveItemFromInventory(r_hand)
	else if(istype(l_hand, /obj/item/grab))
		temporarilyRemoveItemFromInventory(l_hand)

	if(hud_used?.pull_icon)
		hud_used.pull_icon.icon_state = "pull0"

	update_pull_movespeed()


/mob/living/is_injectable(allowmobs = TRUE)
	return (allowmobs && can_inject())

/mob/living/is_drawable(allowmobs = TRUE)
	return (allowmobs && can_inject())

/mob/living/Bump(atom/A)
	. = ..()
	if(.) //We are thrown onto something.
		return
	if(buckled || now_pushing)
		return
	if(isliving(A))
		var/mob/living/L = A

		if(mob_size < L.mob_size) //Can't go around pushing things larger than us.
			return


		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			return

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						to_chat(src, "<span class='warning'>[L] is restraining [P], you cannot push past.</span>")
					return

		if(moving_diagonally)//no mob swap during diagonal moves.
			return

		if(!L.buckled && !L.anchored)
			var/mob_swap = FALSE
			//the puller can always swap with its victim if on grab intent
			if(L.pulledby == src && a_intent == INTENT_GRAB)
				mob_swap = TRUE
			//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
			else if((L.restrained() || L.a_intent == INTENT_HELP) && (restrained() || a_intent == INTENT_HELP))
				mob_swap = TRUE
			else if(mob_size > L.mob_size && a_intent == INTENT_HELP) //Larger mobs can shove aside smaller ones.
				mob_swap = TRUE
			if(mob_swap)
				//switch our position with L
				if(loc && !loc.Adjacent(L.loc))
					return
				now_pushing = TRUE
				var/oldloc = loc
				var/oldLloc = L.loc

				var/L_passmob = (L.flags_pass & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
				var/src_passmob = (flags_pass & PASSMOB)
				L.flags_pass |= PASSMOB
				flags_pass |= PASSMOB

				var/move_failed = FALSE
				if(!L.Move(oldloc) || !Move(oldLloc))
					L.forceMove(oldLloc)
					forceMove(oldloc)
					move_failed = TRUE

				if(!src_passmob)
					flags_pass &= ~PASSMOB
				if(!L_passmob)
					L.flags_pass &= ~PASSMOB

				now_pushing = FALSE

				if(!move_failed)
					return

		if(!(L.status_flags & CANPUSH))
			return

	if(ismovableatom(A))
		PushAM(A)


//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(AM.anchored)
		return TRUE
	if(now_pushing)
		return TRUE
	if(moving_diagonally)// no pushing during diagonal moves.
		return TRUE
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	now_pushing = TRUE
	var/t = get_dir(src, AM)
	if(istype(AM, /obj/structure/window))
		var/obj/structure/window/W = AM
		if(W.is_full_window())
			for(var/obj/structure/window/win in get_step(W,t))
				now_pushing = FALSE
				return
	if(pulling == AM)
		stop_pulling()
	AM.Move(get_step(AM.loc, t), t, glide_size)
	now_pushing = FALSE


/mob/living/throw_at(atom/target, range, speed, thrower, spin)
	if(!target || !src)
		return 0
	if(pulling)
		stop_pulling() //being thrown breaks pulls.
	if(pulledby)
		pulledby.stop_pulling()
	return ..()


/mob/living/proc/offer_mob()
	GLOB.offered_mob_list += src
	notify_ghosts("<span class='boldnotice'>A mob is being offered! Name: [name][job ? " Job: [job.title]" : ""] </span>", enter_link = "claim=[REF(src)]", source = src, action = NOTIFY_ORBIT)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return LIVING_PERM_COEFF

/mob/proc/flash_act(intensity = 1, bypass_checks, type = /obj/screen/fullscreen/flash)
	return

/mob/living/carbon/flash_act(intensity = 1, bypass_checks, type = /obj/screen/fullscreen/flash)
	if( bypass_checks || (get_eye_protection() < intensity && !(disabilities & BLIND)) )
		overlay_fullscreen_timer(40, 20, "flash", type)
		return TRUE

/mob/living/proc/disable_lights(armor = TRUE, guns = TRUE, flares = TRUE, misc = TRUE, sparks = FALSE, silent = FALSE)
	return FALSE


/mob/living/proc/adjust_tinttotal(tint_amount)
	tinttotal += tint_amount
	update_tint()


/mob/living/proc/update_tint()
	if(tinttotal >= TINT_BLIND)
		blind_eyes(1)
		return TRUE
	else if(eye_blind == 1)
		adjust_blindness(-1)
	if(tinttotal)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, tinttotal)
		return TRUE
	else
		clear_fullscreen("tint", 0)
		return FALSE

/mob/living/proc/adjust_mob_accuracy(accuracy_mod)
	ranged_accuracy_mod += accuracy_mod


/mob/living/proc/smokecloak_on()

	if(smokecloaked)
		return

	alpha = 5 // bah, let's make it better, it's a disposable device anyway

	if(!isxeno(src)||!isanimal(src))
		var/datum/atom_hud/security/SA = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		SA.remove_from_hud(src)
		var/datum/atom_hud/xeno_infection/XI = GLOB.huds[DATA_HUD_XENO_INFECTION]
		XI.remove_from_hud(src)

	smokecloaked = TRUE

/mob/living/proc/smokecloak_off()

	if(!smokecloaked)
		return

	alpha = initial(alpha)

	if(!isxeno(src)|| !isanimal(src))
		var/datum/atom_hud/security/SA = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		SA.add_to_hud(src)
		var/datum/atom_hud/xeno_infection/XI = GLOB.huds[DATA_HUD_XENO_INFECTION]
		XI.add_to_hud(src)

	smokecloaked = FALSE

/mob/living/proc/update_cloak()
	if(!smokecloaked)
		return

	var/obj/effect/particle_effect/smoke/tactical/S = locate() in loc
	if(S)
		return
	else
		smokecloak_off()

/mob/living/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude/3, amplitude/3)
	var/final_pixel_x = initial(pixel_x)
	var/final_pixel_y = initial(pixel_y)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)


/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy
value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/

/mob/living/carbon/dizzy(amount)
	dizziness = clamp(dizziness + amount, 0, 1000)

	if(dizziness > 100 && !is_dizzy)
		INVOKE_ASYNC(src, .proc/dizzy_process)

/mob/living/proc/dizzy_process()
	is_dizzy = TRUE
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = FALSE
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

/mob/living/proc/update_action_button_icons()
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()


/mob/living/proc/vomit()
	return


/mob/living/proc/take_over(mob/M, bypass)
	if(!M.mind)
		to_chat(M, "<span class='warning'>You don't have a mind.</span>")
		return FALSE

	if(!bypass)
		if(client)
			to_chat(M, "<span class='warning'>That mob has already been taken.</span>")
			GLOB.offered_mob_list -= src
			return FALSE

		if(job && is_banned_from(M.ckey, job.title))
			to_chat(M, "<span class='warning'>You are jobbanned from that role.</span>")
			return FALSE

		if(stat == DEAD)
			to_chat(M, "<span class='warning'>That mob has died.</span>")
			GLOB.offered_mob_list -= src
			return FALSE

		log_game("[key_name(M)] has taken over [key_name_admin(src)].")
		message_admins("[key_name_admin(M)] has taken over [ADMIN_TPMONTY(src)].")

	M.mind.transfer_to(src, TRUE)
	fully_replace_character_name(M.real_name, real_name)
	GLOB.offered_mob_list -= src
	return TRUE


/mob/living/proc/set_canmove(newcanmove)
	if(canmove == newcanmove)
		return
	. = canmove
	canmove = newcanmove
	SEND_SIGNAL(src, COMSIG_LIVING_SET_CANMOVE, canmove)


/mob/living/proc/update_leader_tracking(mob/living/L)
	return

/mob/living/proc/clear_leader_tracking()
	return

/mob/living/reset_perspective(atom/A)
	. = ..()
	if(!.)
		return

	update_sight()
	if(client.eye && client.eye != src)
		var/atom/AT = client.eye
		AT.get_remote_view_fullscreens(src)
	else
		clear_fullscreen("remote_view", 0)
	update_pipe_vision()


/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(is_centcom_level(T.z)) //dont detect mobs on centcom
		return FALSE
	if(user != null && src == user)
		return FALSE
	if(invisibility || alpha == 0)//cloaked
		return FALSE

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return FALSE

	return TRUE


/mob/living/proc/get_visible_name()
	return name


/mob/living/proc/point_to_atom(atom/A, turf/T)
	var/turf/tile = get_turf(A)
	if (!tile)
		return FALSE
	var/turf/our_tile = get_turf(src)
	//Squad Leaders and above have reduced cooldown and get a bigger arrow
	if(skills.getRating("leadership") < SKILL_LEAD_TRAINED)
		COOLDOWN_START(src, COOLDOWN_POINT, 5 SECONDS)
		var/obj/visual = new /obj/effect/overlay/temp/point(our_tile, invisibility)
		animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + A.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + A.pixel_y, time = 1.7, easing = EASE_OUT)
	else
		COOLDOWN_START(src, COOLDOWN_POINT, 1 SECONDS)
		var/obj/visual = new /obj/effect/overlay/temp/point/big(our_tile, invisibility)
		animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + A.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + A.pixel_y, time = 1.7, easing = EASE_OUT)
	visible_message("<b>[src]</b> points to [A]")
	return TRUE


/mob/living/get_photo_description(obj/item/camera/camera)
	var/holding
	if(l_hand || r_hand)
		if(l_hand)
			holding = "They are holding \a [l_hand]"
		if(r_hand)
			if(holding)
				holding += " and \a [r_hand]"
			else
				holding = "They are holding \a [r_hand]"
		holding += "."
	return "You can also see [src] on the photo[health < (maxHealth * 0.75) ? ", looking a bit hurt" : ""][holding ? ". [holding]" : "."]"


/mob/living/proc/set_pull_offsets(mob/living/pulled_mob)
	if(pulled_mob.buckled)
		return //don't make them change direction or offset them if they're buckled into something.
	if(pulled_mob.loc == loc)
		reset_pull_offsets(pulled_mob)
		return
	var/offset = 0
	switch(grab_state)
		if(GRAB_PASSIVE)
			offset = GRAB_PIXEL_SHIFT_PASSIVE
		if(GRAB_AGGRESSIVE)
			offset = GRAB_PIXEL_SHIFT_AGGRESSIVE
		if(GRAB_NECK)
			offset = GRAB_PIXEL_SHIFT_NECK
		if(GRAB_KILL)
			offset = GRAB_PIXEL_SHIFT_NECK
	pulled_mob.setDir(get_dir(pulled_mob, src))
	switch(pulled_mob.dir)
		if(NORTH)
			animate(pulled_mob, pixel_x = 0, pixel_y = offset, 0.3 SECONDS)
		if(SOUTH)
			animate(pulled_mob, pixel_x = 0, pixel_y = -offset, 0.3 SECONDS)
		if(EAST)
			if(pulled_mob.lying_angle == 270) //update the dragged dude's direction if we've turned
				pulled_mob.set_lying_angle(90)
			animate(pulled_mob, pixel_x = offset, pixel_y = 0, 0.3 SECONDS)
		if(WEST)
			if(pulled_mob.lying_angle == 90)
				pulled_mob.set_lying_angle(270)
			animate(pulled_mob, pixel_x = -offset, pixel_y = 0, 0.3 SECONDS)

/mob/living/proc/reset_pull_offsets(mob/living/pulled_mob, override)
	if(!override && pulled_mob.buckled)
		return
	animate(pulled_mob, pixel_x = initial(pulled_mob.pixel_x), pixel_y = initial(pulled_mob.pixel_y), 0.1 SECONDS)


//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && Adjacent(AM))
		start_pulling(AM)
	else
		stop_pulling()


/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("maxHealth")
			if(!isnum(var_value) || var_value <= 0)
				return FALSE
		if("stat")
			if((stat == DEAD) && (var_value < DEAD))//Bringing the dead back to life
				GLOB.dead_mob_list -= src
				GLOB.alive_living_list += src
			if((stat < DEAD) && (var_value == DEAD))//Kill he
				GLOB.alive_living_list -= src
				GLOB.dead_mob_list += src
	. = ..()
	switch(var_name)
		if("eye_blind")
			set_blindness(var_value)
		if("eye_blurry")
			set_blurriness(var_value)
		if("maxHealth")
			updatehealth()
		if("resize")
			update_transform()
		if("lighting_alpha")
			sync_lighting_plane_alpha()


/mob/living/can_interact_with(datum/D)
	return D.Adjacent(src)

/**
  * Changes the inclination angle of a mob, used by humans and others to differentiate between standing up and prone positions.
  *
  * In BYOND-angles 0 is NORTH, 90 is EAST, 180 is SOUTH and 270 is WEST.
  * This usually means that 0 is standing up, 90 and 270 are horizontal positions to right and left respectively, and 180 is upside-down.
  * Mobs that do now follow these conventions due to unusual sprites should require a special handling or redefinition of this proc, due to the density and layer changes.
  * The return of this proc is the previous value of the modified lying_angle if a change was successful (might include zero), or null if no change was made.
  */
/mob/living/proc/set_lying_angle(new_lying)
	if(new_lying == lying_angle)
		return
	. = lying_angle
	lying_angle = new_lying
	update_transform()
	lying_prev = lying_angle

	if(lying_angle)
		density = FALSE
		drop_all_held_items()
		if(layer == initial(layer)) //to avoid things like hiding larvas.
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	else
		density = TRUE
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)


/mob/living/set_stat(new_stat)
	. = ..()
	if(isnull(.))
		return
	if(stat == CONSCIOUS) //From unconscious to conscious.
		REMOVE_TRAIT(src, TRAIT_IMMOBILE, STAT_TRAIT)
		REMOVE_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)
	else if(. == CONSCIOUS) //From conscious to unconscious.
		ADD_TRAIT(src, TRAIT_IMMOBILE, STAT_TRAIT)
		ADD_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)


/mob/living/setGrabState(newstate)
	. = ..()
	if(isnull(.))
		return
	if(grab_state >= GRAB_NECK)
		if(. < GRAB_NECK) //Neckgrabbed.
			ADD_TRAIT(pulling, TRAIT_IMMOBILE, NECKGRAB_TRAIT)
			ADD_TRAIT(pulling, TRAIT_FLOORED, NECKGRAB_TRAIT)
	else if(. >= GRAB_NECK) //Released from neckgrab.
		REMOVE_TRAIT(pulling, TRAIT_IMMOBILE, NECKGRAB_TRAIT)
		REMOVE_TRAIT(pulling, TRAIT_FLOORED, NECKGRAB_TRAIT)
