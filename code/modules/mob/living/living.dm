/mob/living/Life()
	. = ..()

	if(stat != DEAD)

		handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

		handle_regular_hud_updates()

		updatehealth()

//this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	if(no_stun)//anti-chainstun flag for alien tackles
		no_stun = max(0,no_stun - 1) //decrement by 1.

	if(confused)
		confused = max(0, confused - 1)

	handle_stunned()
	handle_knocked_down()
	handle_knocked_out()
	handle_drugged()
	handle_stuttering()
	handle_slurring()
	handle_silent()
	handle_disabilities()

/mob/living/proc/handle_stunned()
	if(stunned)
		AdjustStunned(-1)
		if(!stunned && !no_stun) //anti chain stun
			no_stun = ANTI_CHAINSTUN_TICKS //1 tick reprieve
	return stunned

/mob/living/proc/handle_knocked_down()
	if(knocked_down && client)
		AdjustKnockeddown(-1)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times
		if(!knocked_down && !no_stun) //anti chain stun
			no_stun = ANTI_CHAINSTUN_TICKS //1 tick reprieve
	return knocked_down

/mob/living/proc/handle_stuttering()
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	return stuttering

/mob/living/proc/handle_silent()
	if(silent)
		silent = max(silent-1, 0)
	return silent

/mob/living/proc/handle_drugged()
	if(druggy)
		adjust_drugginess(-1)
	return druggy

/mob/living/proc/handle_slurring()
	if(slurring)
		slurring = max(slurring-1, 0)
	return slurring

/mob/living/proc/handle_disabilities()
	handle_impaired_vision()
	handle_impaired_hearing()

/mob/living/proc/handle_impaired_vision()
	//Eyes
	if(eye_blind)
		adjust_blindness(-1)
	if(eye_blurry)			//blurry eyes heal slowly
		adjust_blurriness(-1)


/mob/living/proc/handle_impaired_hearing()
	//Ears
	if(ear_damage < 100)
		adjustEarDamage(-0.05, -1)	// having ear damage impairs the recovery of ear_deaf

/mob/living/proc/handle_regular_hud_updates()
	if(!client)
		return FALSE

/mob/living/proc/handle_knocked_out()
	if(knocked_out)
		AdjustKnockedout(-1)
	return knocked_out

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat()

/mob/living/update_stat()
	update_cloak()

/mob/living/Initialize()
	. = ..()
	attack_icon = image("icon" = 'icons/effects/attacks.dmi',"icon_state" = "", "layer" = 0)
	GLOB.mob_living_list += src

/mob/living/Destroy()
	if(attack_icon)
		qdel(attack_icon)
		attack_icon = null
	GLOB.mob_living_list -= src
	GLOB.offered_mob_list -= src
	return ..()




//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(ishuman(src))
		//to_chat(world, "DEBUG: burn_skin(), mutations=[mutations]")
		if(mShock in src.mutations) //shockproof
			return 0
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.limbs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/limb/affecting in H.limbs)
			if(!affecting)	continue
			if(affecting.take_damage_limb(0, divided_damage + extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(ismonkey(src))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(isAI(src))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(ishuman(src))
//		to_chat(world, "[src] ~ [src.bodytemperature] ~ [temperature]")
	return temperature



/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/storage/Storage = null)
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


/mob/living/proc/get_limbzone_target()
	return ran_zone(zone_selected)



/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(CONFIG_GET(flag/allow_metadata))
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return


/mob/living/Move(NewLoc, direct)
	if (buckled && buckled.loc != NewLoc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(NewLoc, direct)
		else
			return 0

	var/atom/movable/pullee = pulling
	if(pullee && get_dist(src, pullee) > 1)
		stop_pulling()
	var/turf/T = loc
	. = ..()
	if(. && pulling && pulling == pullee) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
			return

		var/pull_dir = get_dir(src, pulling)
		if(get_dist(src, pulling) > 1 || ((pull_dir - 1) & pull_dir)) //puller and pullee more than one tile away or in diagonal position
			pulling.Move(T, get_dir(pulling, T)) //the pullee tries to reach our previous position
			if(pulling && get_dist(src, pulling) > 1) //the pullee couldn't keep up
				stop_pulling()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)





/mob/proc/resist_grab(moving_resist)
	return //returning 1 means we successfully broke free

/mob/living/resist_grab(moving_resist)
	if(pulledby.grab_level)
		if(prob(30/pulledby.grab_level))
			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>", null, null, 5)
			pulledby.stop_pulling()
			return 1
		if(moving_resist && client) //we resisted by trying to move
			visible_message("<span class='danger'>[src] struggles to break free of [pulledby]'s grip!</span>", null, null, 5)
			client.next_movement = world.time + (10*pulledby.grab_level) + client.move_delay
	else
		pulledby.stop_pulling()
		return 1


/mob/living/movement_delay()

	. = ..()

	if (do_bump_delay)
		. += 10
		do_bump_delay = 0

	if (drowsyness > 0)
		. += 6

	if(pulling && pulling.drag_delay && !ignore_pull_delay())	//Dragging stuff can slow you down a bit.
		var/pull_delay = pulling.drag_delay
		if(ismob(pulling))
			var/mob/M = pulling
			if(M.buckled) //if the pulled mob is buckled to an object, we use that object's drag_delay.
				pull_delay = M.buckled.drag_delay
		. += max(pull_speed + pull_delay + 3*grab_level, 0) //harder grab makes you slower

//whether we are slowed when dragging things
/mob/living/proc/ignore_pull_delay()
	return FALSE

/mob/living/carbon/human/ignore_pull_delay()
	return FALSE

/mob/living/is_injectable(allowmobs = TRUE)
	return (allowmobs && can_inject())

/mob/living/is_drawable(allowmobs = TRUE)
	return (allowmobs && can_inject())

/mob/living/Bump(atom/movable/AM, yes)
	if(buckled || !yes || now_pushing)
		return
	now_pushing = 1
	if(isliving(AM))
		var/mob/living/L = AM

		//Leaping mobs just land on the tile, no pushing, no anything.
		if(status_flags & LEAPING)
			loc = L.loc
			status_flags &= ~LEAPING
			now_pushing = 0
			return

		if(isxeno(L) && !isxenolarva(L)) //Handling pushing Xenos in general, but big Xenos can still push small Xenos
			var/mob/living/carbon/Xenomorph/X = L
			if((ishuman(src) && X.mob_size == MOB_SIZE_BIG) || (isxeno(src) && X.mob_size == MOB_SIZE_BIG))
				if(!isxeno(src) && client)
					do_bump_delay = 1
				now_pushing = 0
				return

		if(isxeno(src) && !isxenolarva(src) && ishuman(L)) //We are a Xenomorph and pushing a human
			var/mob/living/carbon/Xenomorph/X = src
			if(X.mob_size == MOB_SIZE_BIG)
				L.do_bump_delay = 1

		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			now_pushing = 0
			return

 		if(L.pulling)
 			if(ismob(L.pulling))
 				var/mob/P = L.pulling
 				if(P.restrained())
 					if(!(world.time % 5))
 						to_chat(src, "<span class='warning'>[L] is restraining [P], you cannot push past.</span>")
					now_pushing = 0
					return

		if(ishuman(L))

			if(HULK in L.mutations)
				if(prob(70))
					to_chat(usr, "<span class='danger'>You fail to push [L]'s fat ass out of the way.</span>")
					now_pushing = 0
					return
			if(!(L.status_flags & CANPUSH))
				now_pushing = 0
				return

		if(moving_diagonally)//no mob swap during diagonal moves.
			now_pushing = 0
			return

		if(!L.buckled && !L.anchored)
			var/mob_swap
			//the puller can always swap with its victim if on grab intent
			if(L.pulledby == src && a_intent == INTENT_GRAB)
				mob_swap = 1
			//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
			else if((L.restrained() || L.a_intent == INTENT_HELP) && (restrained() || a_intent == INTENT_HELP))
				mob_swap = 1
			if(mob_swap)
				//switch our position with L
				if(loc && !loc.Adjacent(L.loc))
					now_pushing = 0
					return
				var/oldloc = loc
				var/oldLloc = L.loc


				var/L_passmob = (L.flags_pass & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
				var/src_passmob = (flags_pass & PASSMOB)
				L.flags_pass |= PASSMOB
				flags_pass |= PASSMOB

				L.Move(oldloc)
				Move(oldLloc)

				if(!src_passmob)
					flags_pass &= ~PASSMOB
				if(!L_passmob)
					L.flags_pass &= ~PASSMOB

				now_pushing = 0
				return

		if(!(L.status_flags & CANPUSH))
			now_pushing = 0
			return

	now_pushing = 0
	..()
	if (!ismovableatom(AM))
		return
	if (!( now_pushing ))
		now_pushing = 1
		if (!( AM.anchored ))
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window))
				var/obj/structure/window/W = AM
				if(W.is_full_window())
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
			step(AM, t)
		now_pushing = 0



/mob/living/throw_at(atom/target, range, speed, thrower)
	if(!target || !src)	return 0
	if(pulling) stop_pulling() //being thrown breaks pulls.
	if(pulledby) pulledby.stop_pulling()
	set_frozen(TRUE) //can't move while being thrown
	update_canmove()
	. = ..()
	set_frozen(FALSE)
	update_canmove()

//to make an attack sprite appear on top of the target atom.
/mob/living/proc/flick_attack_overlay(atom/target, attack_icon_state)
	set waitfor = 0

	attack_icon.icon_state = attack_icon_state
	attack_icon.pixel_x = -target.pixel_x
	attack_icon.pixel_y = -target.pixel_y
	target.overlays += attack_icon
	var/old_icon = attack_icon.icon_state
	var/old_pix_x = attack_icon.pixel_x
	var/old_pix_y = attack_icon.pixel_y
	sleep(4)
	if(target)
		var/new_icon = attack_icon.icon_state
		var/new_pix_x = attack_icon.pixel_x
		var/new_pix_y = attack_icon.pixel_x
		attack_icon.icon_state = old_icon //necessary b/c the attack_icon can change sprite during the sleep.
		attack_icon.pixel_x = old_pix_x
		attack_icon.pixel_y = old_pix_y

		target.overlays -= attack_icon

		attack_icon.icon_state = new_icon
		attack_icon.pixel_x = new_pix_x
		attack_icon.pixel_y = new_pix_y


/mob/living/proc/offer_mob()
	GLOB.offered_mob_list += src
	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/O = i
		to_chat(O, "<br><hr><span class='boldnotice'>A mob is being offered! Name: [name][job ? " Job: [job]" : ""] \[<a href='byond://?src=[REF(O)];claim=[REF(src)]'>CLAIM</a>\] \[<a href='byond://?src=[REF(O)];track=[REF(src)]'>FOLLOW</a>\]</span><hr><br>")


//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return LIVING_PERM_COEFF

/mob/proc/flash_eyes()
	return

/mob/living/flash_eyes(intensity = 1, bypass_checks, type = /obj/screen/fullscreen/flash)
	if( bypass_checks || (get_eye_protection() < intensity && !(disabilities & BLIND)) )
		overlay_fullscreen_timer(40, 20, "flash", type)
		return TRUE

/mob/living/proc/disable_lights(armor = TRUE, guns = TRUE, flares = TRUE, misc = TRUE, sparks = FALSE, silent = FALSE)
	return FALSE

/mob/living/update_tint()
	tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		blind_eyes(1)
		return TRUE
	else if(eye_blind == 1)
		adjust_blindness(-1)
	if(tinttotal == TINT_HEAVY)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
		return TRUE
	else
		clear_fullscreen("tint", 0)
		return FALSE

/mob/living/proc/get_total_tint()
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(src in C.stomach_contents)
			. = TINT_BLIND

/mob/living/proc/smokecloak_on()

	if(smokecloaked)
		return

	alpha = 5 // bah, let's make it better, it's a disposable device anyway

	if(!isxeno(src)||!isanimal(src))
		var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
		SA.remove_from_hud(src)
		var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
		XI.remove_from_hud(src)

	smokecloaked = TRUE

/mob/living/proc/smokecloak_off()

	if(!smokecloaked)
		return

	alpha = initial(alpha)

	if(!isxeno(src)|| !isanimal(src))
		var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
		SA.add_to_hud(src)
		var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
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
	var/final_pixel_x = get_standard_pixel_x_offset(lying)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy
value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/

/mob/living/carbon/Dizzy(var/amount)
	dizziness = CLAMP(dizziness + amount, 0, 1000)

	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()

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


/mob/living/proc/equip_preference_gear(client/C)
	if(!C?.prefs || !istype(back, /obj/item/storage/backpack))
		return

	var/datum/preferences/P = C.prefs
	var/list/gear = P.gear

	if(!length(gear))
		return

	for(var/i in GLOB.gear_datums)
		var/datum/gear/G = GLOB.gear_datums[i]
		if(!G || !gear.Find(i))
			continue
		equip_to_slot_or_del(new G.path, SLOT_IN_BACKPACK)

/mob/living/proc/vomit()
	return


/mob/living/proc/take_over(mob/M, bypass)
	if(!M.mind)
		to_chat(M, "<span class='warning'>You don't have a mind.</span>")
		return
	if(!bypass && (key || ckey))
		to_chat(M, "<span class='warning'>That mob has already been taken.</span>")
		return
	if(!bypass && job && (is_banned_from(M.ckey, job) || jobban_isbanned(M, job)))
		to_chat(M, "<span class='warning'>You are jobbanned from that job.</span>")
		return

	M.mind.transfer_to(src, TRUE)
	fully_replace_character_name(M.real_name, real_name)
	GLOB.offered_mob_list -= src

	log_admin("[key_name(M)] has taken [key_name_admin(src)].")
	message_admins("[key_name_admin(M)] has taken [ADMIN_TPMONTY(src)].")