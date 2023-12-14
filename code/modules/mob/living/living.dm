/mob/living/proc/Life()
	if(stat == DEAD || notransform || HAS_TRAIT(src, TRAIT_STASIS)) //If we're dead or notransform don't bother processing life
		return

	handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

	handle_regular_hud_updates()

	handle_organs()

	updatehealth()


//this updates all special effects: knockdown, druggy, etc.., DELETE ME!!
/mob/living/proc/handle_status_effects()
	if(no_stun)//anti-chainstun flag for alien tackles
		no_stun = max(0, no_stun - 1) //decrement by 1.

	handle_drugged()
	handle_slowdown()

///Adjusts our stats based on the auras we've received and care about, then cleans out the list for next tick.
/mob/living/proc/finish_aura_cycle()
	received_auras.Cut() //Living, of course, doesn't care about any

///Can we receive this aura? returns bool
/mob/living/proc/can_receive_aura(aura_type, atom/source, datum/aura_bearer/bearer)
	SHOULD_CALL_PARENT(TRUE)
	. = TRUE
	if(faction != bearer.faction)
		return FALSE

///Update what auras we'll receive this life tick if it's either new or stronger than current. aura_type as AURA_ define, strength as number.
/mob/living/proc/receive_aura(aura_type, strength)
	if(received_auras[aura_type] > strength)
		return
	received_auras[aura_type] = strength

///Add a list of auras to our current emitted, update self as needed
/mob/living/proc/add_emitted_auras(source, aura_list)
	SIGNAL_HANDLER
	emitted_auras += aura_list
	update_aura_overlay()

///Remove a list of auras from our current emitted, update self as needed
/mob/living/proc/remove_emitted_auras(source, aura_list)
	SIGNAL_HANDLER
	emitted_auras -= aura_list
	update_aura_overlay()

///Bring however we represent emitted auras up to date. Implemented for human and xenomorph.
/mob/living/proc/update_aura_overlay()
	return

/mob/living/proc/handle_organs()
	reagent_shock_modifier = 0
	reagent_pain_modifier = 0

/mob/living/proc/handle_drugged()
	if(druggy)
		adjust_drugginess(-1)
	return druggy

/mob/living/proc/handle_staminaloss()
	if(world.time < last_staminaloss_dmg + 3 SECONDS)
		return
	if(staminaloss > 0)
		adjustStaminaLoss(-maxHealth * 0.2 * stamina_regen_multiplier, TRUE, FALSE)
	else if(staminaloss > -max_stamina_buffer)
		adjustStaminaLoss(-max_stamina * 0.08 * stamina_regen_multiplier, TRUE, FALSE)


/mob/living/proc/handle_regular_hud_updates()
	if(!client)
		return FALSE

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

/mob/living/Initialize(mapload)
	. = ..()
	register_init_signals()
	update_move_intent_effects()
	GLOB.mob_living_list += src
	if(stat != DEAD)
		GLOB.alive_living_list += src
	SSmobs.start_processing(src)

	set_armor_datum()
	AddElement(/datum/element/gesture)
	AddElement(/datum/element/keybinding_update)

/mob/living/Destroy()
	for(var/datum/status_effect/effect AS in status_effects)
		qdel(effect)
	for(var/i in embedded_objects)
		var/obj/item/embedded = i
		if(embedded.embedding.embedded_flags & EMBEDDED_DEL_ON_HOLDER_DEL)
			qdel(embedded) //This should remove the object from the list via temporarilyRemoveItemFromInventory() => COMSIG_ITEM_DROPPED.
		else
			embedded.unembed_ourself() //This should remove the object from the list directly.
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	GLOB.alive_living_list -= src
	GLOB.mob_living_list -= src
	GLOB.offered_mob_list -= src
	SSmobs.stop_processing(src)
	job = null
	LAZYREMOVE(GLOB.ssd_living_mobs, src)
	GLOB.key_to_time_of_death[key] = world.time
	if(stat != DEAD && job?.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE))//Only some jobs cost you your respawn timer.
		GLOB.key_to_time_of_role_death[key] = world.time
	. = ..()
	hard_armor = null
	soft_armor = null


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return


/mob/living/proc/check_contents_for(A)
	var/list/L = GetAllContents()

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
	return ran_zone(zone_selected, 100)



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
		if(get_dist(src, pulledby) > 1 && (pulledby != moving_from_pull))//separated from our puller
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
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_RESIST))
		return FALSE
	TIMER_COOLDOWN_START(src, COOLDOWN_RESIST, CLICK_CD_RESIST)
	if(pulledby.grab_state >= GRAB_AGGRESSIVE)
		visible_message(span_danger("[src] resists against [pulledby]'s grip!"))
	return resist_grab()


/mob/living/proc/do_move_resist_grab()
	if(restrained(RESTRAINED_NECKGRAB))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_RESIST))
		return FALSE
	TIMER_COOLDOWN_START(src, COOLDOWN_RESIST, CLICK_CD_RESIST)
	if(pulledby.grab_state >= GRAB_AGGRESSIVE)
		visible_message(span_danger("[src] struggles to break free of [pulledby]'s grip!"), null, null, 5)
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
		visible_message(span_danger("[src] has broken free of [pulledby]'s grip!"), null, null, 5)
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

#define NO_SWAP 0
#define SWAPPING 1
#define PHASING 2

/mob/living/Bump(atom/A)
	. = ..()
	if(.) //We are thrown onto something.
		return FALSE
	if(buckled || now_pushing)
		return
	if(isliving(A))
		var/mob/living/L = A

		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				to_chat(src, span_warning("[L] is restrained, you cannot push past."))
			return

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						to_chat(src, span_warning("[L] is restraining [P], you cannot push past."))
					return

		if(!L.buckled && !L.anchored)
			var/mob_swap_mode = NO_SWAP
			//the puller can always swap with its victim if on grab intent
			if(L.pulledby == src && a_intent == INTENT_GRAB)
				mob_swap_mode = SWAPPING
			//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
			else if((L.restrained() || L.a_intent == INTENT_HELP) && (restrained() || a_intent == INTENT_HELP) && L.move_force < MOVE_FORCE_VERY_STRONG)
				mob_swap_mode = SWAPPING
			else if(get_xeno_hivenumber() == L.get_xeno_hivenumber() && (L.pass_flags & PASS_XENO || pass_flags & PASS_XENO))
				mob_swap_mode = PHASING
			else if((move_resist >= MOVE_FORCE_VERY_STRONG || move_resist > L.move_force) && a_intent == INTENT_HELP) //Larger mobs can shove aside smaller ones. Xenos can always shove xenos
				mob_swap_mode = SWAPPING
			///if we're moving diagonally, but the mob isn't on the diagonal destination turf we have no reason to shuffle/push them
			if(moving_diagonally && (get_dir(src, L) in GLOB.cardinals) && get_step(src, dir).Enter(src, loc))
				mob_swap_mode = PHASING
			if(mob_swap_mode)
				//switch our position with L
				if(loc && !loc.Adjacent(L.loc))
					return
				now_pushing = TRUE
				var/oldloc = loc
				var/oldLloc = L.loc

				var/L_passmob = (L.pass_flags & PASS_MOB) // we give PASS_MOB to both mobs to avoid bumping other mobs during swap.
				var/src_passmob = (pass_flags & PASS_MOB)
				L.pass_flags |= PASS_MOB
				pass_flags |= PASS_MOB

				if(!moving_diagonally) //the diagonal move already does this for us
					Move(oldLloc)
				if(mob_swap_mode == SWAPPING)
					L.Move(oldloc)

				if(!src_passmob)
					pass_flags &= ~PASS_MOB
				if(!L_passmob)
					L.pass_flags &= ~PASS_MOB

				now_pushing = FALSE

				return TURF_ENTER_ALREADY_MOVED

		if(mob_size < L.mob_size) //Can't go around pushing things larger than us.
			return

		if(!(L.status_flags & CANPUSH))
			return

	if(ismovableatom(A))
		if(isxeno(src) && ishuman(A))
			var/mob/living/carbon/human/H = A
			if(!COOLDOWN_CHECK(H,  xeno_push_delay))
				return
			COOLDOWN_START(H, xeno_push_delay, XENO_HUMAN_PUSHED_DELAY)
		if(PushAM(A))
			return TURF_ENTER_ALREADY_MOVED


//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM, force = move_force)
	if(AM.anchored)
		return
	if(now_pushing)
		return
	if(moving_diagonally) // No pushing in diagonal move
		return
	if(!client)
		return
	var/mob/mob_to_push = AM
	if(istype(mob_to_push) && mob_to_push.lying_angle)
		return
	now_pushing = TRUE
	var/dir_to_target = get_dir(src, AM)

	// If there's no dir_to_target then the player is on the same turf as the atom they're trying to push.
	// This can happen when a player is stood on the same turf as a directional window. All attempts to push
	// the window will fail as get_dir will return 0 and the player will be unable to move the window when
	// it should be pushable.
	// In this scenario, we will use the facing direction of the /mob/living attempting to push the atom as
	// a fallback.
	if(!dir_to_target)
		dir_to_target = dir

	var/push_anchored = FALSE
	if((AM.move_resist * MOVE_FORCE_CRUSH_RATIO) <= force)
		if(move_crush(AM, move_force, dir_to_target))
			push_anchored = TRUE
	if((AM.move_resist * MOVE_FORCE_FORCEPUSH_RATIO) <= force) //trigger move_crush and/or force_push regardless of if we can push it normally
		if(force_push(AM, move_force, dir_to_target, push_anchored))
			push_anchored = TRUE
	if(ismob(AM))
		var/atom/movable/mob_buckle = mob_to_push.buckled
		// If we can't pull them because of what they're buckled to, make sure we can push the thing they're buckled to instead.
		// If neither are true, we're not pushing anymore.
		if(mob_buckle && (mob_buckle.buckle_flags & BUCKLE_PREVENTS_PULL || (force < (mob_buckle.move_resist * MOVE_FORCE_PUSH_RATIO))))
			now_pushing = FALSE
			return
	if((AM.anchored && !push_anchored) || (force < (AM.move_resist * MOVE_FORCE_PUSH_RATIO)))
		now_pushing = FALSE
		return

	if(istype(AM, /obj/structure/window))
		var/obj/structure/window/W = AM
		if(W.is_full_window())
			for(var/obj/structure/window/win in get_step(W, dir_to_target))
				now_pushing = FALSE
				return
	if(pulling == AM)
		stop_pulling()
	AM.Move(get_step(AM.loc, dir_to_target), dir_to_target, glide_size)
	now_pushing = FALSE


/mob/living/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	if(!target)
		return 0
	if(pulling && !flying)
		stop_pulling() //being thrown breaks pulls.
	if(pulledby)
		pulledby.stop_pulling()
	return ..()

/**
 * Throw the mob while giving HOVERING to flag_pass and setting layer to FLY_LAYER
 *
 * target : where will the mob be thrown at
 * range : how far the mob will be thrown, in tile
 * speed : how fast will it fly
 */
/mob/living/proc/fly_at(atom/target, range, speed)
	throw_at(target, range, speed, null, 0, TRUE)

/mob/living/proc/offer_mob()
	GLOB.offered_mob_list += src
	notify_ghosts(span_boldnotice("A mob is being offered! Name: [name][job ? " Job: [job.title]" : ""] "), enter_link = "claim=[REF(src)]", source = src, action = NOTIFY_ORBIT)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return LIVING_PERM_COEFF

/mob/proc/flash_act(intensity = 1, bypass_checks, type = /atom/movable/screen/fullscreen/flash, duration)
	return

/mob/living/carbon/flash_act(intensity = 1, bypass_checks, type = /atom/movable/screen/fullscreen/flash, duration = 40)
	if( bypass_checks || (get_eye_protection() < intensity && !(disabilities & BLIND)) )
		overlay_fullscreen_timer(duration, 20, "flash", type)
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
		overlay_fullscreen("tint", /atom/movable/screen/fullscreen/impaired, tinttotal)
		return TRUE
	else
		clear_fullscreen("tint", 0)
		return FALSE

///Modifies the mobs inherent accuracy modifier
/mob/living/proc/adjust_mob_accuracy(accuracy_mod)
	ranged_accuracy_mod += accuracy_mod
	SEND_SIGNAL(src, COMSIG_RANGED_ACCURACY_MOD_CHANGED, accuracy_mod)

///Modifies the mobs inherent scatter modifier
/mob/living/proc/adjust_mob_scatter(scatter_mod)
	ranged_scatter_mod += scatter_mod
	SEND_SIGNAL(src, COMSIG_RANGED_SCATTER_MOD_CHANGED, scatter_mod)

/mob/living/proc/smokecloak_on()

	if(smokecloaked)
		return

	if(stat == DEAD)
		return

	alpha = 5 // bah, let's make it better, it's a disposable device anyway

	GLOB.huds[DATA_HUD_SECURITY_ADVANCED].remove_from_hud(src)
	GLOB.huds[DATA_HUD_XENO_INFECTION].remove_from_hud(src)
	GLOB.huds[DATA_HUD_XENO_REAGENTS].remove_from_hud(src)
	GLOB.huds[DATA_HUD_XENO_DEBUFF].remove_from_hud(src)
	GLOB.huds[DATA_HUD_XENO_HEART].remove_from_hud(src)

	smokecloaked = TRUE

/mob/living/proc/smokecloak_off()

	if(!smokecloaked)
		return

	alpha = initial(alpha)

	GLOB.huds[DATA_HUD_SECURITY_ADVANCED].add_to_hud(src)
	GLOB.huds[DATA_HUD_XENO_INFECTION].add_to_hud(src)
	GLOB.huds[DATA_HUD_XENO_REAGENTS].add_to_hud(src)
	GLOB.huds[DATA_HUD_XENO_DEBUFF].add_to_hud(src)
	GLOB.huds[DATA_HUD_XENO_HEART].add_to_hud(src)

	smokecloaked = FALSE

/mob/living/proc/update_cloak()
	if(!smokecloaked)
		return

	var/obj/effect/particle_effect/smoke/tactical/S = locate() in loc
	if(S)
		return
	else
		smokecloak_off()


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
		INVOKE_ASYNC(src, PROC_REF(dizzy_process))

/mob/living/proc/dizzy_process()
	is_dizzy = TRUE
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(0.1 SECONDS)
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
		to_chat(M, span_warning("You don't have a mind."))
		return FALSE

	if(!bypass)
		if(client)
			to_chat(M, span_warning("That mob has already been taken."))
			GLOB.offered_mob_list -= src
			return FALSE

		if(job && is_banned_from(M.ckey, job.title))
			to_chat(M, span_warning("You are jobbanned from that role."))
			return FALSE

		log_game("[key_name(M)] has taken over [key_name_admin(src)].")
		message_admins("[key_name_admin(M)] has taken over [ADMIN_TPMONTY(src)].")

	GLOB.offered_mob_list -= src

	transfer_mob(M)

	fully_replace_character_name(M.real_name, real_name)
	return TRUE


/mob/living/proc/set_canmove(newcanmove)
	if(canmove == newcanmove)
		return
	. = canmove
	canmove = newcanmove
	SEND_SIGNAL(src, COMSIG_LIVING_SET_CANMOVE, canmove)


/mob/living/proc/update_tracking(mob/living/L)
	return

/mob/living/proc/clear_leader_tracking()
	return

/mob/living/reset_perspective(atom/A)
	. = ..()
	if(!.)
		return

	update_sight()
	if (stat == DEAD)
		animate(client, pixel_x = 0, pixel_y = 0)
	if(client.eye && client.eye != src)
		var/atom/AT = client.eye
		AT.get_remote_view_fullscreens(src)
	else
		clear_fullscreen("remote_view", 0)
	update_pipe_vision()

/mob/living/update_sight()
	if(SSticker.current_state == GAME_STATE_FINISHED && !is_centcom_level(z)) //Reveal ghosts to remaining survivors
		see_invisible = SEE_INVISIBLE_OBSERVER
	return ..()

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
	return D == src || D.Adjacent(src)

/mob/living/onTransitZ(old_z, new_z)
	. = ..()
	set_jump_component()

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
	SEND_SIGNAL(src, COMSIG_LIVING_SET_LYING_ANGLE)
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
	switch(.)
		if(CONSCIOUS) //From conscious to unconscious.
			ADD_TRAIT(src, TRAIT_IMMOBILE, STAT_TRAIT)
			ADD_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)
		if(DEAD)
			on_revive()
	switch(stat)
		if(CONSCIOUS) //From unconscious to conscious.
			REMOVE_TRAIT(src, TRAIT_IMMOBILE, STAT_TRAIT)
			REMOVE_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)
		if(DEAD)
			on_death()


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

///Set the remote_control and reset the perspective
/mob/living/proc/set_remote_control(atom/movable/controlled)
	remote_control = controlled
	reset_perspective(controlled)

///Swap the active hand
/mob/living/proc/swap_hand()
	var/obj/item/wielded_item = get_active_held_item()
	if(wielded_item && (wielded_item.flags_item & WIELDED)) //this segment checks if the item in your hand is twohanded.
		var/obj/item/weapon/twohanded/offhand/offhand = get_inactive_held_item()
		if(offhand && (offhand.flags_item & WIELDED))
			wielded_item.unwield(src) //Get rid of it.
	hand = !hand
	SEND_SIGNAL(src, COMSIG_CARBON_SWAPPED_HANDS)
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		hud_used.l_hand_hud_object.update_icon(hand)
		hud_used.r_hand_hud_object.update_icon(!hand)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.add_overlay("hand_active")
		else
			hud_used.r_hand_hud_object.add_overlay("hand_active")
	return

///Swap to the hand clicked on the hud
/mob/living/proc/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

///Set the afk status of the mob
/mob/living/proc/set_afk_status(new_status, afk_timer)
	switch(new_status)
		if(MOB_CONNECTED, MOB_DISCONNECTED)
			if(afk_timer_id)
				deltimer(afk_timer_id)
				afk_timer_id = null
		if(MOB_RECENTLY_DISCONNECTED)
			if(afk_status == MOB_RECENTLY_DISCONNECTED)
				if(timeleft(afk_timer_id) <= afk_timer)
					return
				deltimer(afk_timer_id) //We'll go with the shorter timer.
			afk_timer_id = addtimer(CALLBACK(src, PROC_REF(on_sdd_grace_period_end)), afk_timer, TIMER_STOPPABLE)
	afk_status = new_status
	SEND_SIGNAL(src, COMSIG_CARBON_SETAFKSTATUS, new_status, afk_timer)

///Set the mob as afk after AFK_TIMER
/mob/living/proc/on_sdd_grace_period_end()
	if(stat == DEAD)
		return FALSE
	if(isclientedaghost(src))
		return FALSE
	set_afk_status(MOB_DISCONNECTED)
	return TRUE

/mob/living/carbon/human/on_sdd_grace_period_end()
	. = ..()
	if(!.)
		return
	log_admin("[key_name(src)] (Job: [(job) ? job.title : "Unassigned"]) has been away for [AFK_TIMER] minutes.")
	message_admins("[ADMIN_TPMONTY(src)] (Job: [(job) ? job.title : "Unassigned"]) has been away for [AFK_TIMER] minutes.")

///Transfer the candidate mind into src
/mob/living/proc/transfer_mob(mob/candidate)
	if(QDELETED(src))
		stack_trace("[candidate] was put into a qdeleted mob [src]")
		return
	candidate.mind.transfer_to(src, TRUE)

/mob/living/carbon/xenomorph/transfer_mob(mob/candidate)
	. = ..()
	if(is_ventcrawling)  //If we are in a vent, fetch a fresh vent map
		add_ventcrawl(loc)
		get_up()

///Sets up the jump component for the mob. Proc args can be altered so different mobs have different 'default' jump settings
/mob/living/proc/set_jump_component(duration = 0.5 SECONDS, cooldown = 1 SECONDS, cost = 8, height = 16, sound = null, flags = JUMP_SHADOW, flags_pass = PASS_LOW_STRUCTURE|PASS_FIRE)
	var/gravity = get_gravity()
	if(gravity < 1) //low grav
		duration *= 2.5 - gravity
		cooldown *= 2 - gravity
		cost *= gravity * 0.5
		height *= 2 - gravity
		if(gravity <= 0.75)
			flags_pass |= PASS_DEFENSIVE_STRUCTURE
	else if(gravity > 1) //high grav
		duration *= gravity * 0.5
		cooldown *= gravity
		cost *= gravity
		height *= gravity * 0.5

	AddComponent(/datum/component/jump, _jump_duration = duration, _jump_cooldown = cooldown, _stamina_cost = cost, _jump_height = height, _jump_sound = sound, _jump_flags = flags, _jumper_allow_pass_flags = flags_pass)
