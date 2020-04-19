#define CHARGE_SPEED(charger) (min(charger.valid_steps_taken, charger.max_steps_buildup) * charger.speed_per_step)
#define CHARGE_MAX_SPEED (speed_per_step * max_steps_buildup)

#define CHARGE_CRUSH (1<<0)
#define CHARGE_BULL (1<<1)
#define CHARGE_BULL_HEADBUTT (1<<2)
#define CHARGE_BULL_GORE (1<<3)

#define STOP_CRUSHER_ON_DEL (1<<0)

// ***************************************
// *********** Charge
// ***************************************

/datum/action/xeno_action/ready_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	mechanics_text = "Toggles the movement-based charge on and off."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_CHARGE
	var/charge_type = CHARGE_CRUSH
	var/next_move_limit = 0
	var/turf/lastturf = null
	var/charge_dir = null
	var/charge_ability_on = FALSE
	var/valid_steps_taken = 0
	var/crush_sound = "punch"
	var/speed_per_step = 0.15
	var/steps_for_charge = 7
	var/max_steps_buildup = 14
	var/crush_living_damage = 10
	var/next_special_attack = 0 //Little var to keep track on special attack timers.


/datum/action/xeno_action/ready_charge/give_action(mob/living/L)
	. = ..()
	action_activate()


/datum/action/xeno_action/ready_charge/Destroy()
	if(charge_ability_on)
		charge_off()
	return ..()


/datum/action/xeno_action/ready_charge/remove_action(mob/living/L)
	if(charge_ability_on)
		charge_off()
	return ..()


/datum/action/xeno_action/ready_charge/action_activate()
	if(charge_ability_on)
		charge_off()
		return
	charge_on()


/datum/action/xeno_action/ready_charge/proc/charge_on(verbose = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.legcuffed)
		if(verbose)
			to_chat(owner, "<span class='warning'>We can't charge with that thing on our leg!</span>")
		return
	charge_ability_on = TRUE
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, .proc/update_charging)
	RegisterSignal(charger, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)
	RegisterSignal(charger, COMSIG_LIVING_LEGCUFFED, .proc/on_legcuffed)
	if(verbose)
		to_chat(charger, "<span class='xenonotice'>We will charge when moving, now.</span>")


/datum/action/xeno_action/ready_charge/proc/charge_off(verbose = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging != CHARGE_OFF)
		do_stop_momentum()
	UnregisterSignal(charger, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_LEGCUFFED))
	if(verbose)
		to_chat(charger, "<span class='xenonotice'>We will no longer charge when moving.</span>")
	valid_steps_taken = 0
	charge_ability_on = FALSE


/datum/action/xeno_action/ready_charge/proc/on_dir_change(datum/source, old_dir, new_dir)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging == CHARGE_OFF)
		return
	if(old_dir == new_dir)
		return
	do_stop_momentum()


/datum/action/xeno_action/ready_charge/proc/on_legcuffed(datum/source)
	if(!charge_ability_on)
		return
	to_chat(owner, "<span class='xenodanger'>We can't charge with that thing on our leg!</span>")
	charge_off(FALSE)


/datum/action/xeno_action/ready_charge/proc/update_charging(datum/source, atom/oldloc, direction, Forced)
	if(Forced)
		return

	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.throwing || oldloc == charger.loc)
		return

	if(charger.is_charging == CHARGE_OFF)
		if(charger.dir != direction) //It needs to move twice in the same direction, at least, to begin charging.
			return
		charge_dir = direction
		if(!check_momentum(direction))
			charge_dir = null
			return
		charger.is_charging = CHARGE_BUILDINGUP
		handle_momentum()
		return

	if(!check_momentum(direction))
		do_stop_momentum()
		return

	handle_momentum()


/datum/action/xeno_action/ready_charge/proc/do_start_crushing()
	var/mob/living/carbon/xenomorph/charger = owner
	RegisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE), .proc/do_crush)
	charger.is_charging = CHARGE_ON
	charger.update_icons()


/datum/action/xeno_action/ready_charge/proc/do_stop_crushing()
	var/mob/living/carbon/xenomorph/charger = owner
	UnregisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE))
	if(valid_steps_taken > 0) //If this is false, then do_stop_momentum() should have it handled already.
		charger.is_charging = CHARGE_BUILDINGUP
		charger.update_icons()


/datum/action/xeno_action/ready_charge/proc/do_stop_momentum(message = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	if(message && valid_steps_taken >= steps_for_charge) //Message now happens without a stun condition
		charger.visible_message("<span class='danger'>[charger] skids to a halt!</span>",
		"<span class='xenowarning'>We skid to a halt.</span>", null, 5)
	valid_steps_taken = 0
	next_move_limit = 0
	lastturf = null
	charge_dir = null
	charger.remove_movespeed_modifier(MOVESPEED_ID_XENO_CHARGE)
	if(charger.is_charging >= CHARGE_ON)
		do_stop_crushing()
	charger.is_charging = CHARGE_OFF
	charger.update_icons()


/datum/action/xeno_action/ready_charge/proc/check_momentum(newdir)
	var/mob/living/carbon/xenomorph/charger = owner
	if(ISDIAGONALDIR(newdir) || charge_dir != newdir)
		return FALSE

	if(next_move_limit && world.time > next_move_limit)
		return FALSE

	if(charger.pulling)
		return FALSE

	if(charger.incapacitated())
		return FALSE

	if(charge_dir != charger.dir || charger.moving_diagonally)
		return FALSE

	if(charger.pulledby)
		return FALSE

	if(lastturf && (!isturf(lastturf) || isspaceturf(lastturf) || (charger.loc == lastturf))) //Check if the Crusher didn't move from his last turf, aka stopped
		return FALSE

	if(charger.plasma_stored < CHARGE_MAX_SPEED)
		return FALSE

	return TRUE


/datum/action/xeno_action/ready_charge/proc/handle_momentum()
	var/mob/living/carbon/xenomorph/charger = owner

	if(charger.pulling && valid_steps_taken)
		charger.stop_pulling()

	next_move_limit = world.time + 0.5 SECONDS

	if(++valid_steps_taken <= max_steps_buildup)
		if(valid_steps_taken == steps_for_charge)
			do_start_crushing()
		else if(valid_steps_taken == max_steps_buildup)
			charger.is_charging = CHARGE_MAX
			charger.emote("roar")
		charger.add_movespeed_modifier(MOVESPEED_ID_XENO_CHARGE, TRUE, 100, NONE, TRUE, -CHARGE_SPEED(src))

	if(valid_steps_taken > steps_for_charge)
		charger.plasma_stored -= round(CHARGE_SPEED(src)) //Eats up plasma the faster you go.

		switch(charge_type)
			if(CHARGE_CRUSH) //Xeno Crusher
				if(MODULUS(valid_steps_taken, 4) == 0)
					playsound(charger, "alien_charge", 50)
				var/shake_dist = min(round(CHARGE_SPEED(src) * 5), 8)
				for(var/mob/living/carbon/victim in range(shake_dist, charger))
					if(isxeno(victim))
						continue
					if(victim.stat == DEAD)
						continue
					if(victim.client)
						shake_camera(victim, 1, 1)
					if(victim.loc != charger.loc || !victim.lying_angle || isnestedhost(victim))
						continue
					charger.visible_message("<span class='danger'>[charger] runs [victim] over!</span>",
						"<span class='danger'>We run [victim] over!</span>", null, 5)
					victim.take_overall_damage(CHARGE_SPEED(src) * 10, blocked = victim.run_armor_check("chest", "melee"))
					animation_flash_color(victim)
			if(CHARGE_BULL, CHARGE_BULL_HEADBUTT, CHARGE_BULL_GORE) //Xeno Bull
				if(MODULUS(valid_steps_taken, 4) == 0)
					playsound(charger, "alien_footstep_large", 50)

	lastturf = charger.loc


/datum/action/xeno_action/ready_charge/proc/speed_down(amt)
	if(valid_steps_taken == 0)
		return
	valid_steps_taken -= amt
	if(valid_steps_taken <= 0)
		valid_steps_taken = 0
		do_stop_momentum()
	else if(valid_steps_taken < steps_for_charge)
		do_stop_crushing()

#define PRECRUSH_STOPPED -1
#define PRECRUSH_PLOWED -2
#define PRECRUSH_ENTANGLED -3

/proc/precrush2signal(precrush)
	switch(precrush)
		if(PRECRUSH_STOPPED)
			return COMPONENT_MOVABLE_PREBUMP_STOPPED
		if(PRECRUSH_PLOWED)
			return COMPONENT_MOVABLE_PREBUMP_PLOWED
		if(PRECRUSH_ENTANGLED)
			return COMPONENT_MOVABLE_PREBUMP_ENTANGLED
		else
			return NONE

// Charge is divided into two acts: before and after the crushed thing taking damage, as that can cause it to be deleted.
/datum/action/xeno_action/ready_charge/proc/do_crush(datum/source, atom/crushed)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.incapacitated() || charger.now_pushing)
		return NONE

	if(charge_type & (CHARGE_BULL|CHARGE_BULL_HEADBUTT|CHARGE_BULL_GORE) && !isliving(crushed))
		do_stop_momentum()
		return COMPONENT_MOVABLE_PREBUMP_STOPPED

	var/precrush = crushed.pre_crush_act(charger, src) //Negative values are codes. Positive ones are damage to deal.
	switch(precrush)
		if(null)
			CRASH("[crushed] returned null from do_crush()")
		if(PRECRUSH_STOPPED)
			return COMPONENT_MOVABLE_PREBUMP_STOPPED //Already handled, no need to continue.
		if(PRECRUSH_PLOWED)
			return COMPONENT_MOVABLE_PREBUMP_PLOWED
		if(PRECRUSH_ENTANGLED)
			. = COMPONENT_MOVABLE_PREBUMP_ENTANGLED

	var/preserved_name = crushed.name

	if(isliving(crushed))
		var/mob/living/crushed_living = crushed

		playsound(crushed_living.loc, crush_sound, 25, 1)
		if(crushed_living.buckled)
			crushed_living.buckled.unbuckle_mob(crushed_living)
		animation_flash_color(crushed_living)

		if(precrush > 0)
			log_combat(charger, crushed_living, "xeno charged")
			crushed_living.apply_damage(precrush, BRUTE, "chest", updating_health = TRUE) //There is a chance to do enough damage here to gib certain mobs. Better update immediately.
			if(QDELETED(crushed_living))
				charger.visible_message("<span class='danger'>[charger] anihilates [preserved_name]!</span>",
				"<span class='xenodanger'>We anihilate [preserved_name]!</span>")
				return COMPONENT_MOVABLE_PREBUMP_PLOWED

		return precrush2signal(crushed_living.post_crush_act(charger, src))

	if(isobj(crushed))
		var/obj/crushed_obj = crushed
		playsound(crushed_obj.loc, "punch", 25, 1)
		var/crushed_behavior = crushed_obj.crushed_special_behavior()
		crushed_obj.take_damage(precrush)
		if(QDELETED(crushed_obj))
			charger.visible_message("<span class='danger'>[charger] crushes [preserved_name]!</span>",
			"<span class='xenodanger'>We crush [preserved_name]!</span>")
			if(crushed_behavior & STOP_CRUSHER_ON_DEL)
				return COMPONENT_MOVABLE_PREBUMP_STOPPED
			else
				return COMPONENT_MOVABLE_PREBUMP_PLOWED

		return precrush2signal(crushed_obj.post_crush_act(charger, src))

	if(isturf(crushed))
		var/turf/crushed_turf = crushed
		switch(precrush)
			if(1 to 3)
				crushed_turf.ex_act(precrush)

		if(QDELETED(crushed_turf))
			charger.visible_message("<span class='danger'>[charger] plows straight through [preserved_name]!</span>",
			"<span class='xenowarning'>We plow straight through [preserved_name]!</span>")
			return COMPONENT_MOVABLE_PREBUMP_PLOWED

		charger.visible_message("<span class='danger'>[charger] rams into [crushed_turf] and skids to a halt!</span>",
		"<span class='xenowarning'>We ram into [crushed_turf] and skid to a halt!</span>")
		do_stop_momentum(FALSE)
		return COMPONENT_MOVABLE_PREBUMP_STOPPED


/datum/action/xeno_action/ready_charge/bull_charge
	charge_type = CHARGE_BULL
	speed_per_step = 0.1
	steps_for_charge = 5
	max_steps_buildup = 10
	crush_living_damage = 30


/datum/action/xeno_action/ready_charge/bull_charge/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOACTION_TOGGLECHARGETYPE, .proc/toggle_charge_type)


/datum/action/xeno_action/ready_charge/bull_charge/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOACTION_TOGGLECHARGETYPE)
	return ..()


/datum/action/xeno_action/ready_charge/bull_charge/proc/toggle_charge_type(datum/source, new_charge_type = CHARGE_BULL)
	if(charge_type == new_charge_type)
		return

	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging >= CHARGE_ON)
		do_stop_momentum()

	switch(new_charge_type)
		if(CHARGE_BULL)
			charge_type = CHARGE_BULL
			crush_sound = initial(crush_sound)
			to_chat(owner, "<span class='notice'>Now charging normally.</span>")
		if(CHARGE_BULL_HEADBUTT)
			charge_type = CHARGE_BULL_HEADBUTT
			to_chat(owner, "<span class='notice'>Now headbutting on impact.</span>")
		if(CHARGE_BULL_GORE)
			charge_type = CHARGE_BULL_GORE
			crush_sound = "alien_tail_attack"
			to_chat(owner, "<span class='notice'>Now goring on impact.</span>")


// ***************************************
// *********** Pre-Crush
// ***************************************

//Anything called here will have failed CanPass(), so it's likely dense.
/atom/proc/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	return //If this happens it will error.


/obj/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) || charger.is_charging < CHARGE_ON)
		charge_datum.do_stop_momentum()
		return PRECRUSH_STOPPED
	if(anchored)
		if(flags_atom & ON_BORDER)
			if(dir == REVERSE_DIR(charger.dir))
				. = (CHARGE_SPEED(charge_datum) * 80) //Damage to inflict.
				charge_datum.speed_down(3)
				return
			else
				. = (CHARGE_SPEED(charge_datum) * 160)
				charge_datum.speed_down(1)
				return
		else
			. = (CHARGE_SPEED(charge_datum) * 240)
			charge_datum.speed_down(2)
			return

	for(var/m in buckled_mobs)
		unbuckle_mob(m)
	return (CHARGE_SPEED(charge_datum) * 20) //Damage to inflict.


/obj/structure/bed/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	. = ..()
	if(!.)
		return
	if(buckled_bodybag)
		unbuckle_bodybag()


/mob/living/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	return (stat == DEAD ? 0 : CHARGE_SPEED(charge_datum) * charge_datum.crush_living_damage)


//Special override case. May not call the parent.
/mob/living/carbon/xenomorph/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(!issamexenohive(charger))
		return ..()

	if(anchored || (mob_size > charger.mob_size && charger.is_charging <= CHARGE_MAX))
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
		"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		charge_datum.do_stop_momentum(FALSE)
		if(!anchored)
			step(src, charger.dir)
		return PRECRUSH_STOPPED

	throw_at(get_step(loc, (charger.dir & (NORTH|SOUTH) ? pick(EAST, WEST) : pick(NORTH, SOUTH))), 1, 1, charger, (mob_size < charger.mob_size))

	charge_datum.speed_down(1) //Lose one turf worth of speed.
	return PRECRUSH_PLOWED


/turf/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(charge_datum.valid_steps_taken >= charge_datum.max_steps_buildup)
		return 2 //Should dismantle, or at least heavily damage it.
	return 3 //Lighter damage.


// ***************************************
// *********** Post-Crush
// ***************************************

/atom/proc/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	return PRECRUSH_STOPPED //By default, if this happens then movement stops. But not necessarily.


/obj/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(anchored) //Did it manage to stop it?
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
		"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		if(charger.is_charging > CHARGE_OFF)
			charge_datum.do_stop_momentum(FALSE)
		return PRECRUSH_STOPPED
	var/fling_dir = pick(GLOB.cardinals - ((charger.dir & (NORTH|SOUTH)) ? list(NORTH, SOUTH) : list(EAST, WEST))) //Fling them somewhere not behind nor ahead of the charger.
	var/fling_dist = min(round(CHARGE_SPEED(charge_datum)) + 1, 3)
	if(!step(src, fling_dir) && density)
		charge_datum.do_stop_momentum(FALSE) //Failed to be tossed away and returned, more powerful than ever, to block the charger's path.
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
			"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		return PRECRUSH_STOPPED
	if(--fling_dist)
		for(var/i in 1 to fling_dist)
			if(!step(src, fling_dir))
				break
	charger.visible_message("<span class='warning'>[charger] knocks [src] aside.</span>!",
	"<span class='xenowarning'>We knock [src] aside.</span>") //Canisters, crates etc. go flying.
	charge_datum.speed_down(2) //Lose two turfs worth of speed.
	return PRECRUSH_PLOWED


/obj/structure/razorwire/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(!anchored)
		return ..()
	razorwire_tangle(charger, RAZORWIRE_ENTANGLE_DELAY * 0.5) //entangled for only half as long
	charger.visible_message("<span class='danger'>The barbed wire slices into [charger]!</span>",
	"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
	charger.Paralyze(20)
	charger.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_MED), BRUTE, ran_zone(), 0, TRUE) //Armor is being ignored here.
	UPDATEHEALTH(charger)
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	update_icon()
	return PRECRUSH_ENTANGLED //Let's return this so that the charger may enter the turf in where it's entangled, if it survived the wounds without gibbing.


/obj/structure/mineral_door/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(!anchored)
		return ..()
	TryToSwitchState(charger)
	if(density)
		return PRECRUSH_STOPPED
	charger.visible_message("<span class='danger'>[charger] slams [src] open!</span>",
	"<span class='xenowarning'>We slam [src] open!</span>")
	return PRECRUSH_PLOWED


/obj/machinery/vending/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(!anchored)
		return ..()
	tip_over()
	if(density)
		return PRECRUSH_STOPPED
	charger.visible_message("<span class='danger'>[charger] slams [src] into the ground!</span>",
	"<span class='xenowarning'>We slam [src] into the ground!</span>")
	return PRECRUSH_PLOWED


/mob/living/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(density && ((mob_size == charger.mob_size && charger.is_charging <= CHARGE_MAX) || mob_size > charger.mob_size))
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
		"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		charge_datum.do_stop_momentum(FALSE)
		step(src, charger.dir)
		return PRECRUSH_STOPPED

	switch(charge_datum.charge_type)
		if(CHARGE_CRUSH)
			Paralyze(CHARGE_SPEED(charge_datum) * 20)
		if(CHARGE_BULL_HEADBUTT)
			Paralyze(CHARGE_SPEED(charge_datum) * 60)

	if(anchored)
		charge_datum.do_stop_momentum(FALSE)
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
			"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		return PRECRUSH_STOPPED

	switch(charge_datum.charge_type)
		if(CHARGE_CRUSH, CHARGE_BULL)
			var/fling_dir = pick((charger.dir & (NORTH|SOUTH)) ? list(WEST, EAST, charger.dir|WEST, charger.dir|EAST) : list(NORTH, SOUTH, charger.dir|NORTH, charger.dir|SOUTH)) //Fling them somewhere not behind nor ahead of the charger.
			var/fling_dist = min(round(CHARGE_SPEED(charge_datum)) + 1, 3)
			var/turf/destination = loc
			var/turf/temp

			for(var/i in 1 to fling_dist)
				temp = get_step(destination, fling_dir)
				if(!temp)
					break
				destination = temp
			if(destination != loc)
				throw_at(destination, fling_dist, 1, charger, TRUE)

			charger.visible_message("<span class='danger'>[charger] rams [src]!</span>",
			"<span class='xenodanger'>We ram [src]!</span>")
			charge_datum.speed_down(1) //Lose one turf worth of speed.
			return PRECRUSH_PLOWED

		if(CHARGE_BULL_GORE)
			if(world.time > charge_datum.next_special_attack)
				charge_datum.next_special_attack = world.time + 2 SECONDS
				attack_alien(charger,  0, "chest", FALSE, FALSE, FALSE, INTENT_HARM) //Free gore attack.
				emote_gored()
				var/turf/destination = get_step(loc, charger.dir)
				if(destination)
					throw_at(destination, 1, 1, charger, FALSE)
				charger.visible_message("<span class='danger'>[charger] gores [src]!</span>",
					"<span class='xenowarning'>We gore [src] and skid to a halt!</span>")

		if(CHARGE_BULL_HEADBUTT)
			var/fling_dir = charger.a_intent == INTENT_HARM ? charger.dir : REVERSE_DIR(charger.dir)
			var/fling_dist = min(round(CHARGE_SPEED(charge_datum)) + 1, 3)
			var/turf/destination = loc
			var/turf/temp

			for(var/i in 1 to fling_dist)
				temp = get_step(destination, fling_dir)
				if(!temp)
					break
				destination = temp
			if(destination != loc)
				throw_at(destination, fling_dist, 1, charger, TRUE)

			charger.visible_message("<span class='danger'>[charger] rams into [src] and flings [p_them()] away!</span>",
				"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")

	charge_datum.do_stop_momentum(FALSE)
	return PRECRUSH_STOPPED


/mob/living/proc/emote_gored()
	return


/mob/living/carbon/human/emote_gored()
	if(species.species_flags & NO_PAIN)
		return
	emote("gored")


/mob/living/carbon/xenomorph/emote_gored()
	emote(prob(70) ? "hiss" : "roar")


/obj/proc/crushed_special_behavior()
	return NONE


/obj/structure/window/framed/crushed_special_behavior()
	if(window_frame)
		return STOP_CRUSHER_ON_DEL
	else ..()


#undef CHARGE_SPEED
#undef CHARGE_MAX_SPEED

#undef STOP_CRUSHER_ON_DEL

#undef PRECRUSH_STOPPED
#undef PRECRUSH_PLOWED
#undef PRECRUSH_ENTANGLED
