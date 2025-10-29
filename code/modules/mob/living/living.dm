/mob/living/proc/Life(seconds_per_tick, times_fired)
	if(stat == DEAD || notransform || HAS_TRAIT(src, TRAIT_STASIS)) //If we're dead or notransform don't bother processing life
		return

	handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

	handle_regular_hud_updates()

	handle_organs()

	updatehealth()

	if(client)
		var/turf/T = get_turf(src)
		if(!T)
			return
		if(registered_z != T.z)
#ifdef TESTING
			message_admins("[ADMIN_LOOKUPFLW(src)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
		return
	if(registered_z)
		log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
		update_z(null)


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
	if(received_auras[aura_type] && received_auras[aura_type] > strength)
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

/// Updates the `health` variable and anything associated with it.
/mob/living/proc/updatehealth()
	SEND_SIGNAL(src, COMSIG_LIVING_UPDATE_HEALTH)
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return FALSE
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat()
	return TRUE

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
	AddElement(/datum/element/directional_attack)

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


/mob/living/Move(atom/newloc, direction, glide_size_override)
	if(buckled)
		if(buckled.loc != newloc) //not updating position
			if(!buckled.anchored)
				return buckled.Move(newloc, direction, glide_size)
			else
				return FALSE
	else if(lying_angle)
		if(direction & EAST)
			set_lying_angle(90)
		else if(direction & WEST)
			set_lying_angle(270)

	. = ..()

	if(pulledby)
		if(get_dist(src, pulledby) > 1 && (pulledby != moving_from_pull))//separated from our puller
			pulledby.stop_pulling()
		else if(isliving(pulledby))
			var/mob/living/living_puller = pulledby
			living_puller.set_pull_offsets(src)

	if(s_active && !(s_active.parent in contents) && !CanReach(s_active.parent))
		s_active.close(src)


/mob/living/Moved(atom/old_loc, movement_dir, forced = FALSE, list/old_locs)
	. = ..()
	update_camera_location(old_loc)


/mob/living/forceMove(atom/destination)
	. = ..()
	//Only bother updating the camera if we actually managed to move
	if(.)
		update_camera_location(destination)
		if(client)
			reset_perspective()

///Updates the mob's registered_z
/mob/living/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z == new_z)
		return
	if(registered_z)
		SSmobs.clients_by_zlevel[registered_z] -= src
	if(isnull(client))
		registered_z = null
		return
	if(new_z)
		SSmobs.clients_by_zlevel[new_z] += src
	registered_z = new_z

/mob/living/proc/do_camera_update(oldLoc)
	return


/mob/living/proc/update_camera_location(oldLoc)
	return

/mob/proc/resist_grab()
	return //returning 1 means we successfully broke free


/mob/living/proc/do_resist_grab()
	if(restrained(RESTRAINED_NECKGRAB))
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_RESIST))
		return FALSE
	TIMER_COOLDOWN_START(src, COOLDOWN_RESIST, CLICK_CD_RESIST)
	if(pulledby.grab_state >= GRAB_AGGRESSIVE)
		visible_message(span_danger("[src] resists against [pulledby]'s grip!"))
	return resist_grab()


/mob/living/proc/do_move_resist_grab()
	if(restrained(RESTRAINED_NECKGRAB))
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_RESIST))
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
			/* If we're moving diagonally, but the mob isn't on the diagonal destination turf and the destination turf is enterable we have no reason to shuffle/push them
			 * However we also do not want mobs of smaller move forces being able to pass us diagonally if our move resist is larger, unless they're the same faction as us
			*/
			if(moving_diagonally && (get_dir(src, L) in GLOB.cardinals) && (L.faction == faction || L.move_resist <= move_force) && get_step(src, dir).Enter(src, loc))
				mob_swap_mode = PHASING
			if(mob_swap_mode)
				//switch our position with L
				if(loc && !loc.Adjacent(L.loc))
					return
				now_pushing = TRUE
				var/oldloc = loc
				var/oldLloc = L.loc

				// we give PASS_MOB to both mobs to avoid bumping other mobs during swap.
				L.add_pass_flags(PASS_MOB, MOVEMENT_SWAP_TRAIT)
				add_pass_flags(PASS_MOB, MOVEMENT_SWAP_TRAIT)

				if(!moving_diagonally) //the diagonal move already does this for us
					Move(oldLloc)
				if(mob_swap_mode == SWAPPING)
					L.Move(oldloc)

				L.remove_pass_flags(PASS_MOB, MOVEMENT_SWAP_TRAIT)
				remove_pass_flags(PASS_MOB, MOVEMENT_SWAP_TRAIT)

				now_pushing = FALSE

				return TURF_ENTER_ALREADY_MOVED

		if(mob_size < L.mob_size) //Can't go around pushing things larger than us.
			return

		if(!(L.status_flags & CANPUSH))
			return

	if(ismovable(A))
		if(isxeno(src) && ishuman(A))
			var/mob/living/carbon/human/H = A
			if(!COOLDOWN_FINISHED(H,  xeno_push_delay))
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
	if(LAZYLEN(buckled_mobs) && !flying)
		unbuckle_all_mobs(force = TRUE)
	if(buckled)
		buckled.unbuckle_mob(src)

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
	notify_ghosts(span_boldnotice("A mob is being offered! Name: [name][job ? " Job: [job.title]" : ""] "), enter_link = "claim=[REF(src)]", source = src, action = NOTIFY_ORBIT, flashwindow = TRUE)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return LIVING_PERM_COEFF

/// Returns the overall SOFT acid protection of a mob.
/mob/living/proc/get_soft_acid_protection()
	return soft_armor?.getRating(ACID)/100

/// Returns the overall HARD acid protection of a mob.
/mob/living/proc/get_hard_acid_protection()
	return hard_armor?.getRating(ACID)

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
		set_invis_see(SEE_INVISIBLE_OBSERVER)
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
	set category = "IC.Object"

	if(istype(AM) && Adjacent(AM))
		start_pulling(AM)
	else
		stop_pulling()

/mob/living/can_interact_with(datum/D)
	return D == src || D.Adjacent(src)

/mob/living/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	if(!same_z_layer && new_turf?.z) // we moved to null z
		set_jump_component()
	. = ..()
	update_z(new_turf?.z)

/**
 * We want to relay the zmovement to the buckled atom when possible
 * and only run what we can't have on buckled.zMove() or buckled.can_z_move() here.
 * This way we can avoid esoteric bugs, copypasta and inconsistencies.
 */
/mob/living/zMove(dir, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(buckled)
		if(buckled.currently_z_moving)
			return FALSE
		if(!(z_move_flags & ZMOVE_ALLOW_BUCKLED))
			buckled.unbuckle_mob(src, force = TRUE, can_fall = FALSE)
		else
			if(!target)
				target = can_z_move(dir, get_turf(src), null, z_move_flags, src)
				if(!target)
					return FALSE
			return buckled.zMove(dir, target, z_move_flags) // Return value is a loc.
	return ..()

/mob/living/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if(z_move_flags & ZMOVE_INCAPACITATED_CHECKS && incapacitated())
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, span_warning("[rider ? src : "You"] can't do that right now!"))
		return FALSE
	if(!buckled || !(z_move_flags & ZMOVE_ALLOW_BUCKLED))
		if(!(z_move_flags & ZMOVE_FALL_CHECKS) && (status_flags & INCORPOREAL) && (!rider || rider.status_flags & INCORPOREAL))
			//An incorporeal mob will ignore obstacles unless it's a potential fall (it'd suck hard) or is carrying corporeal mobs.
			//Coupled with flying/floating, this allows the mob to move up and down freely.
			//By itself, it only allows the mob to move down.
			z_move_flags |= ZMOVE_IGNORE_OBSTACLES
		return ..()
	switch(SEND_SIGNAL(buckled, COMSIG_BUCKLED_CAN_Z_MOVE, direction, start, destination, z_move_flags, src))
		if(COMPONENT_RIDDEN_ALLOW_Z_MOVE) // Can be ridden.
			return buckled.can_z_move(direction, start, destination, z_move_flags, src)
		if(COMPONENT_RIDDEN_STOP_Z_MOVE) // Is a ridable but can't be ridden right now. Feedback messages already done.
			return FALSE
		else
			if(!(z_move_flags & ZMOVE_CAN_FLY_CHECKS) && !buckled.anchored)
				return buckled.can_z_move(direction, start, destination, z_move_flags, src)
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(src, span_warning("Unbuckle from [buckled] first."))
			return FALSE

/mob/set_currently_z_moving(value)
	if(buckled)
		return buckled.set_currently_z_moving(value)
	return ..()

/mob/living/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	if(!isgroundlessturf(impacted_turf))
		impact_flags |= ZImpactDamage(impacted_turf, levels)

	return ..()

/**
 * Called when this mob is receiving damage from falling
 *
 * * impacted_turf - the turf we are falling onto
 * * levels - the number of levels we are falling
 */
/mob/living/proc/ZImpactDamage(turf/impacted_turf, levels)
	. = SEND_SIGNAL(src, COMSIG_LIVING_Z_IMPACT, levels, impacted_turf)
	if(. & ZIMPACT_CANCEL_DAMAGE)
		return .
	// multiplier for the damage taken from falling
	var/damage_softening_multiplier = 1

	// If you are incapped, you probably can't brace yourself
	var/can_help_themselves = !incapacitated(TRUE)
	if(levels <= 1 && can_help_themselves)
		if(HAS_TRAIT(src, TRAIT_FREERUNNING)) // the power of parkour or wings allows falling short distances unscathed
			var/graceful_landing = HAS_TRAIT(src, TRAIT_CATLIKE_GRACE)

			if(!graceful_landing)
				Knockdown(levels * 4 SECONDS)
				emote("spin")

			visible_message(
				span_notice("[src] makes a hard landing on [impacted_turf] but remains unharmed from the fall[graceful_landing ? " and stays on [p_their()] feet" : " by tucking in rolling into the landing"]."),
				span_notice("You brace for the fall. You make a hard landing on [impacted_turf], but remain unharmed[graceful_landing ? " while landing on your feet" : " by tucking in and rolling into the landing"]."),
			)
			return . | ZIMPACT_NO_MESSAGE

	var/incoming_damage = (levels * 5) ** 1.5
	// Smaller mobs with catlike grace can ignore damage (EG: cats)
	var/small_surface_area = mob_size <= MOB_SIZE_SMALL
	var/skip_knockdown = FALSE
	if(HAS_TRAIT(src, TRAIT_CATLIKE_GRACE) && can_help_themselves && !lying_angle) // todo should check for broken legs?
		. |= ZIMPACT_NO_MESSAGE|ZIMPACT_NO_SPIN
		skip_knockdown = TRUE
		if(small_surface_area)
			visible_message(
				span_notice("[src] makes a hard landing on [impacted_turf], but lands safely on [p_their()] feet!"),
				span_notice("You make a hard landing on [impacted_turf], but land safely on your feet!"),
			)
			new /obj/effect/temp_visual/leap_dust/small(impacted_turf)
			return .

		incoming_damage *= 1.66
		visible_message(
			span_danger("[src] makes a hard landing on [impacted_turf], landing on [p_their()] feet painfully!"),
			span_userdanger("You make a hard landing on [impacted_turf], and instinctively land on your feet - painfully!"),
		)
		new /obj/effect/temp_visual/leap_dust(impacted_turf)

	if(!lying_angle)
		var/damage_for_each_leg = round((incoming_damage / 2) * damage_softening_multiplier)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_L_LEG)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_R_LEG)
	else
		apply_damage(incoming_damage, BRUTE)

	if(!skip_knockdown)
		Knockdown(levels * 2 SECONDS)
	return .

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
	if(wielded_item && (wielded_item.item_flags & WIELDED)) //this segment checks if the item in your hand is twohanded.
		var/obj/item/weapon/twohanded/offhand/offhand = get_inactive_held_item()
		if(offhand && (offhand.item_flags & WIELDED))
			wielded_item.unwield(src) //Get rid of it.
	hand = !hand
	SEND_SIGNAL(src, COMSIG_LIVING_SWAPPED_HANDS)
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		hud_used.l_hand_hud_object.update_icon()
		hud_used.r_hand_hud_object.update_icon()
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
	log_admin("[key_name(src)] (Job: [(job) ? job.title : "Unassigned"]) has been away for [AFK_TIMER / 600] minutes.")
	message_admins("[ADMIN_TPMONTY(src)] (Job: [(job) ? job.title : "Unassigned"]) has been away for [AFK_TIMER / 600] minutes.")

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
/mob/living/proc/set_jump_component(duration = 0.5 SECONDS, cooldown = 1 SECONDS, cost = 8, height = 16, sound = null, flags = JUMP_SHADOW, jump_pass_flags = PASS_LOW_STRUCTURE|PASS_FIRE|PASS_TANK)
	var/list/arg_list = list(duration, cooldown, cost, height, sound, flags, jump_pass_flags)
	if(SEND_SIGNAL(src, COMSIG_LIVING_SET_JUMP_COMPONENT, arg_list))
		duration = arg_list[1]
		cooldown = arg_list[2]
		cost = arg_list[3]
		height = arg_list[4]
		sound = arg_list[5]
		flags = arg_list[6]
		jump_pass_flags = arg_list[7]

	var/gravity = get_gravity()
	if(gravity < 1) //low grav
		duration *= 2.5 - gravity
		cooldown *= 2 - gravity
		cost *= gravity * 0.5
		height *= 2 - gravity
		if(gravity <= 0.75)
			jump_pass_flags |= PASS_DEFENSIVE_STRUCTURE
	else if(gravity > 1) //high grav
		duration *= gravity * 0.5
		cooldown *= gravity
		cost *= gravity
		height *= gravity * 0.5

	AddComponent(/datum/component/jump, _jump_duration = duration, _jump_cooldown = cooldown, _stamina_cost = cost, _jump_height = height, _jump_sound = sound, _jump_flags = flags, _jumper_allow_pass_flags = jump_pass_flags)

/atom/movable/looking_holder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = RESIST_ALL
	///the direction we are operating in
	var/look_direction
	///actual atom on the turf, usually the owner
	var/atom/movable/container
	///the actual owner who is "looking"
	var/mob/living/owner

/atom/movable/looking_holder/Initialize(mapload, mob/living/owner, direction)
	. = ..()
	look_direction = direction
	src.owner = owner
	update_container()

/atom/movable/looking_holder/Destroy()
	owner = null
	return ..()

///called to find and set the atom on the actual turf to be the container and all relevant effects
/atom/movable/looking_holder/proc/update_container()
	SIGNAL_HANDLER
	var/new_container = get_atom_on_turf(owner)
	if(new_container == container)
		return
	if(container != owner)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	if(container)
		UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

	container = new_container

	RegisterSignal(new_container, COMSIG_MOVABLE_MOVED, PROC_REF(mirror_move))
	if(new_container != owner)
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(update_container))

/atom/movable/looking_holder/proc/mirror_move(mob/living/source, atom/oldloc, direction, Forced, old_locs)
	SIGNAL_HANDLER
	if(!isturf(owner.loc))
		update_container()
	set_glide_size(container.glide_size)
	var/turf/looking_turf = owner.get_looking_turf(look_direction)
	if(!looking_turf)
		owner.end_look()
		return
	abstract_move(looking_turf)

///Checks if the user is incapacitated or on cooldown.
/mob/living/proc/can_look_up()
	if(next_move > world.time)
		return FALSE
	if(incapacitated(TRUE))
		return FALSE
	return TRUE

/mob/living/proc/end_look()
	reset_perspective()
	looking_vertically = NONE
	QDEL_NULL(looking_holder)


/**
 * look_up Changes the perspective of the mob to any openspace turf above the mob
 *
 * This also checks if an openspace turf is above the mob before looking up or resets the perspective if already looking up
 *
 */
/mob/living/proc/look_up()
	if(looking_vertically == UP)
		return
	if(looking_vertically == DOWN)
		end_look()
		return
	if(!can_look_up())
		return
	changeNext_move(CLICK_CD_LOOK_UP)
	var/turf/above_turf = get_looking_turf(UP)
	if(!above_turf)
		return
	looking_vertically = UP
	looking_holder = new(above_turf, src, UP)
	reset_perspective(looking_holder)

/mob/living/proc/get_looking_turf(direction)
	//down needs to check this floor
	var/turf/check_turf = get_step_multiz(src, direction == DOWN ? NONE : direction)
	if(!get_step_multiz(src, direction)) //We are at the edge z-level.
		to_chat(src, span_warning("There's nothing interesting there."))
		return
	else if(!istransparentturf(check_turf)) //There is no turf we can look through above us
		var/turf/front_hole = get_step(check_turf, dir)
		if(istransparentturf(front_hole))
			check_turf = front_hole
		else
			for(var/turf/checkhole in TURF_NEIGHBORS(check_turf))
				if(istransparentturf(checkhole))
					check_turf = checkhole
					break
		if(!istransparentturf(check_turf))
			to_chat(src, span_warning("You can't see through the floor [direction == DOWN ? "below" : "above"] you."))
			return
	return direction == DOWN ? get_step_multiz(check_turf, DOWN) : check_turf

/**
 * look_down Changes the perspective of the mob to any openspace turf below the mob
 *
 * This also checks if an openspace turf is below the mob before looking down or resets the perspective if already looking up
 *
 */
/mob/living/proc/look_down()
	if(looking_vertically == UP)
		end_look()
		return
	if(looking_vertically == DOWN)
		return
	if(!can_look_up()) //if we cant look up, we cant look down.
		return
	changeNext_move(CLICK_CD_LOOK_UP)
	var/turf/below_turf = get_looking_turf(DOWN)
	if(!below_turf)
		return
	looking_vertically = DOWN
	looking_holder = new(get_looking_turf(DOWN), src, DOWN)
	reset_perspective(looking_holder)

/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if (NAMEOF(src, maxHealth))
			if (!isnum(var_value) || var_value <= 0)
				return FALSE
		if(NAMEOF(src, health)) //this doesn't work. gotta use procs instead.
			return FALSE
		if(NAMEOF(src, stat))
			if((stat == DEAD) && (var_value < DEAD))//Bringing the dead back to life
				GLOB.dead_mob_list -= src
				GLOB.alive_living_list += src
			if((stat < DEAD) && (var_value == DEAD))//Kill he
				GLOB.alive_living_list -= src
				GLOB.dead_mob_list += src
		if(NAMEOF(src, resting))
			set_resting(var_value)
			. = TRUE
		if(NAMEOF(src, lying_angle))
			set_lying_angle(var_value)
			. = TRUE
		if(NAMEOF(src, eye_blind))
			set_blindness(var_value)
		if(NAMEOF(src, eye_blurry))
			set_blurriness(var_value)
		if(NAMEOF(src, resize))
			if(var_value == 0) //prevents divisions of and by zero.
				return FALSE
			update_transform(var_value/resize)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	. = ..()

	switch(var_name)
		if(NAMEOF(src, maxHealth))
			updatehealth()

/mob/living/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += {"
		<br><font size='1'>[VV_HREF_TARGETREF(refid, VV_HK_GIVE_DIRECT_CONTROL, "[ckey || "no ckey"]")] / [VV_HREF_TARGETREF_1V(refid, VV_HK_BASIC_EDIT, "[real_name || "no real name"]", NAMEOF(src, real_name))]</font>
		<br><font size='1'>
			BRUTE:<font size='1'><a href='byond://?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=brute' id='brute'>[getBruteLoss()]</a>
			FIRE:<font size='1'><a href='byond://?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=fire' id='fire'>[getFireLoss()]</a>
			TOXIN:<font size='1'><a href='byond://?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=toxin' id='toxin'>[getToxLoss()]</a>
			OXY:<font size='1'><a href='byond://?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=oxygen' id='oxygen'>[getOxyLoss()]</a>
			CLONE:<font size='1'><a href='byond://?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=clone' id='clone'>[getCloneLoss()]</a>
			STAMINA:<font size='1'><a href='byond://?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=stamina' id='stamina'>[getStaminaLoss()]</a>
		</font>
	"}

/mob/living/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_ADD_LANGUAGE, "Add Language")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_LANGUAGE, "Remove Language")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_SPEECH_IMPEDIMENT, "Impede Speech (Slurring, stuttering, etc)")

/mob/living/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_ADD_LANGUAGE])
		if(!check_rights(NONE))
			return
		var/choice = tgui_input_list(usr, "Grant which language?", "Languages", GLOB.all_languages)
		if(!choice)
			return
		grant_language(choice)
	if(href_list[VV_HK_REMOVE_LANGUAGE])
		if(!check_rights(NONE))
			return
		var/choice = tgui_input_list(usr, "Remove which language?", "Known Languages", src.language_holder.languages)
		if(!choice)
			return
		remove_language(choice)
	if(href_list[VV_HK_GIVE_SPEECH_IMPEDIMENT])
		if(!check_rights(NONE))
			return
		admin_give_speech_impediment(usr)

/// Admin only proc for giving a certain speech impediment to this mob
/mob/living/proc/admin_give_speech_impediment(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/list/impediments = list()
	for(var/datum/status_effect/possible as anything in typesof(/datum/status_effect/speech))
		if(!initial(possible.id))
			continue

		impediments[initial(possible.id)] = possible

	var/chosen = tgui_input_list(admin, "What speech impediment?", "Impede Speech", impediments)
	if(!chosen || !ispath(impediments[chosen], /datum/status_effect/speech) || QDELETED(src) || !check_rights(NONE))
		return

	var/duration = tgui_input_number(admin, "How long should it last (in seconds)? Max is infinite duration.", "Duration", 0, INFINITY, 0 SECONDS)
	if(!isnum(duration) || duration <= 0 || QDELETED(src) || !check_rights(NONE))
		return

	adjust_timed_status_effect(duration * 1 SECONDS, impediments[chosen])
