#define CHARGE_SPEED(charger) (min(charger.valid_steps_taken, charger.max_steps_buildup) * charger.speed_per_step)
#define CHARGE_MAX_SPEED (speed_per_step * max_steps_buildup)

#define CHARGE_CRUSH (1<<0)
#define CHARGE_BULL (1<<1)
#define CHARGE_BULL_HEADBUTT (1<<2)
#define CHARGE_BULL_GORE (1<<3)
#define CHARGE_BEHEMOTH (1<<4)

#define STOP_CRUSHER_ON_DEL (1<<0)

// ***************************************
// *********** Charge
// ***************************************

/datum/action/ability/xeno_action/ready_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	desc = "Toggles the movement-based charge on and off."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_CHARGE,
	)
	action_type = ACTION_TOGGLE
	use_state_flags = ABILITY_USE_LYING
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
	var/crush_living_damage = 20
	var/next_special_attack = 0 //Little var to keep track on special attack timers.
	var/plasma_use_multiplier = 1
	///If this charge should keep momentum on dir change and if it can charge diagonally
	var/agile_charge = FALSE
	/// Whether this ability should be activated when given.
	var/should_start_on = TRUE


/datum/action/ability/xeno_action/ready_charge/give_action(mob/living/L)
	. = ..()
	if(should_start_on)
		action_activate()


/datum/action/ability/xeno_action/ready_charge/Destroy()
	if(charge_ability_on)
		charge_off()
	return ..()


/datum/action/ability/xeno_action/ready_charge/remove_action(mob/living/L)
	if(charge_ability_on)
		charge_off()
	return ..()


/datum/action/ability/xeno_action/ready_charge/action_activate()
	if(charge_ability_on)
		charge_off()
		return
	charge_on()


/datum/action/ability/xeno_action/ready_charge/proc/charge_on(verbose = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	charge_ability_on = TRUE
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, PROC_REF(update_charging))
	RegisterSignal(charger, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	set_toggle(TRUE)
	if(verbose)
		to_chat(charger, span_xenonotice("We will charge when moving, now."))


/datum/action/ability/xeno_action/ready_charge/proc/charge_off(verbose = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging != CHARGE_OFF)
		do_stop_momentum()
	UnregisterSignal(charger, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	if(verbose)
		to_chat(charger, span_xenonotice("We will no longer charge when moving."))
	set_toggle(FALSE)
	valid_steps_taken = 0
	charge_ability_on = FALSE


/datum/action/ability/xeno_action/ready_charge/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging == CHARGE_OFF)
		return
	if(!old_dir || !new_dir || old_dir == new_dir) //Check for null direction from help shuffle signals
		return
	if(agile_charge)
		speed_down(8)
		return
	do_stop_momentum()


/datum/action/ability/xeno_action/ready_charge/proc/update_charging(datum/source, atom/oldloc, direction, Forced, old_locs)
	SIGNAL_HANDLER_DOES_SLEEP
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


/datum/action/ability/xeno_action/ready_charge/proc/do_start_crushing()
	var/mob/living/carbon/xenomorph/charger = owner
	RegisterSignals(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE), PROC_REF(do_crush))
	charger.is_charging = CHARGE_ON
	charger.update_icons()


/datum/action/ability/xeno_action/ready_charge/proc/do_stop_crushing()
	var/mob/living/carbon/xenomorph/charger = owner
	UnregisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE))
	if(valid_steps_taken > 0) //If this is false, then do_stop_momentum() should have it handled already.
		charger.is_charging = CHARGE_BUILDINGUP
		charger.update_icons()


/datum/action/ability/xeno_action/ready_charge/proc/do_stop_momentum(message = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	if(message && valid_steps_taken >= steps_for_charge) //Message now happens without a stun condition
		charger.visible_message(span_danger("[charger] skids to a halt!"),
		span_xenowarning("We skid to a halt."), null, 5)
	valid_steps_taken = 0
	next_move_limit = 0
	lastturf = null
	charge_dir = null
	charger.remove_movespeed_modifier(MOVESPEED_ID_XENO_CHARGE)
	if(charger.is_charging >= CHARGE_ON)
		do_stop_crushing()
	charger.is_charging = CHARGE_OFF
	charger.update_icons()


/datum/action/ability/xeno_action/ready_charge/proc/check_momentum(newdir)
	var/mob/living/carbon/xenomorph/charger = owner
	if((newdir && ISDIAGONALDIR(newdir) || charge_dir != newdir) && !agile_charge) //Check for null direction from help shuffle signals
		return FALSE

	if(next_move_limit && world.time > next_move_limit)
		return FALSE

	if(charger.pulling)
		return FALSE

	if(charger.incapacitated())
		return FALSE

	if(charge_dir != charger.dir && !agile_charge)
		return FALSE

	if(charger.pulledby)
		return FALSE

	if(lastturf && (!isturf(lastturf) || isspaceturf(lastturf) || (charger.loc == lastturf))) //Check if the Crusher didn't move from his last turf, aka stopped
		return FALSE

	if(charger.plasma_stored < CHARGE_MAX_SPEED)
		return FALSE

	return TRUE


/datum/action/ability/xeno_action/ready_charge/proc/handle_momentum()
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
		charger.plasma_stored -= round(CHARGE_SPEED(src) * plasma_use_multiplier) //Eats up plasma the faster you go. //now uses a multiplier

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
					charger.visible_message(span_danger("[charger] runs [victim] over!"),
						span_danger("We run [victim] over!"), null, 5)
					victim.take_overall_damage(CHARGE_SPEED(src) * 10, BRUTE,MELEE, max_limbs = 3)
					animation_flash_color(victim)
			if(CHARGE_BULL, CHARGE_BULL_HEADBUTT, CHARGE_BULL_GORE) //Xeno Bull
				if(MODULUS(valid_steps_taken, 4) == 0)
					playsound(charger, "alien_footstep_large", 50)
			if(CHARGE_BEHEMOTH)
				if(MODULUS(valid_steps_taken, 2) == 0)
					playsound(charger, "behemoth_rolling", 30)

	lastturf = charger.loc


/datum/action/ability/xeno_action/ready_charge/proc/speed_down(amt)
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
/datum/action/ability/xeno_action/ready_charge/proc/do_crush(datum/source, atom/crushed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.incapacitated() || charger.now_pushing)
		return NONE

	if(charge_type & (CHARGE_BULL|CHARGE_BULL_HEADBUTT|CHARGE_BULL_GORE|CHARGE_BEHEMOTH) && !isliving(crushed))
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
			//There is a chance to do enough damage here to gib certain mobs. Better update immediately.
			crushed_living.apply_damage(precrush, BRUTE, BODY_ZONE_CHEST, MELEE, updating_health = TRUE)
			if(QDELETED(crushed_living))
				charger.visible_message(span_danger("[charger] anihilates [preserved_name]!"),
				span_xenodanger("We anihilate [preserved_name]!"))
				return COMPONENT_MOVABLE_PREBUMP_PLOWED

		return precrush2signal(crushed_living.post_crush_act(charger, src))

	if(isobj(crushed))
		var/obj/crushed_obj = crushed
		if(istype(crushed_obj, /obj/structure/xeno/silo) || istype(crushed_obj, /obj/structure/xeno/xeno_turret))
			return precrush2signal(crushed_obj.post_crush_act(charger, src))
		playsound(crushed_obj.loc, "punch", 25, 1)
		var/crushed_behavior = crushed_obj.crushed_special_behavior()
		crushed_obj.take_damage(precrush, BRUTE, MELEE)
		if(QDELETED(crushed_obj))
			charger.visible_message(span_danger("[charger] crushes [preserved_name]!"),
			span_xenodanger("We crush [preserved_name]!"))
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
			charger.visible_message(span_danger("[charger] plows straight through [preserved_name]!"),
			span_xenowarning("We plow straight through [preserved_name]!"))
			return COMPONENT_MOVABLE_PREBUMP_PLOWED

		charger.visible_message(span_danger("[charger] rams into [crushed_turf] and skids to a halt!"),
		span_xenowarning("We ram into [crushed_turf] and skid to a halt!"))
		do_stop_momentum(FALSE)
		return COMPONENT_MOVABLE_PREBUMP_STOPPED


/datum/action/ability/xeno_action/ready_charge/bull_charge
	action_icon_state = "bull_ready_charge"
	charge_type = CHARGE_BULL
	speed_per_step = 0.15
	steps_for_charge = 5
	max_steps_buildup = 10
	crush_living_damage = 15
	plasma_use_multiplier = 2


/datum/action/ability/xeno_action/ready_charge/bull_charge/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOACTION_TOGGLECHARGETYPE, PROC_REF(toggle_charge_type))


/datum/action/ability/xeno_action/ready_charge/bull_charge/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOACTION_TOGGLECHARGETYPE)
	return ..()


/datum/action/ability/xeno_action/ready_charge/bull_charge/proc/toggle_charge_type(datum/source, new_charge_type = CHARGE_BULL)
	SIGNAL_HANDLER
	if(charge_type == new_charge_type)
		return

	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging >= CHARGE_ON)
		do_stop_momentum()

	switch(new_charge_type)
		if(CHARGE_BULL)
			charge_type = CHARGE_BULL
			crush_sound = initial(crush_sound)
			to_chat(owner, span_notice("Now charging normally."))
		if(CHARGE_BULL_HEADBUTT)
			charge_type = CHARGE_BULL_HEADBUTT
			to_chat(owner, span_notice("Now headbutting on impact."))
		if(CHARGE_BULL_GORE)
			charge_type = CHARGE_BULL_GORE
			crush_sound = "alien_tail_attack"
			to_chat(owner, span_notice("Now goring on impact."))

/datum/action/ability/xeno_action/ready_charge/bull_charge/on_xeno_upgrade()
	var/mob/living/carbon/xenomorph/X = owner
	agile_charge = (X.upgrade == XENO_UPGRADE_PRIMO)

/datum/action/ability/xeno_action/ready_charge/queen_charge
	action_icon_state = "queen_ready_charge"

// ***************************************
// *********** Pre-Crush
// ***************************************

//Anything called here will have failed CanPass(), so it's likely dense.
/atom/proc/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	return //If this happens it will error.


/obj/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if((resistance_flags & (INDESTRUCTIBLE|CRUSHER_IMMUNE)) || charger.is_charging < CHARGE_ON)
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

/obj/vehicle/unmanned/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	return (CHARGE_SPEED(charge_datum) * 10)

/obj/vehicle/sealed/mecha/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	return (CHARGE_SPEED(charge_datum) * 375)

/obj/structure/razorwire/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) || charger.is_charging < CHARGE_ON)
		charge_datum.do_stop_momentum()
		return PRECRUSH_STOPPED
	if(anchored)
		var/charge_damage = (CHARGE_SPEED(charge_datum) * 45)  // 2.1 * 45 = 94.5 max damage to inflict.
		. = charge_damage
		charge_datum.speed_down(3)
		charger.adjust_sunder(10)
		return
	return (CHARGE_SPEED(charge_datum) * 20) //Damage to inflict.

/obj/structure/bed/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	. = ..()
	if(!.)
		return
	if(buckled_bodybag)
		unbuckle_bodybag()


/mob/living/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	return (stat == DEAD ? 0 : CHARGE_SPEED(charge_datum) * charge_datum.crush_living_damage)


//Special override case. May not call the parent.
/mob/living/carbon/xenomorph/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(!issamexenohive(charger))
		return ..()

	if(anchored || (mob_size > charger.mob_size && charger.is_charging <= CHARGE_MAX))
		charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
		span_xenowarning("We ram into [src] and skid to a halt!"))
		charge_datum.do_stop_momentum(FALSE)
		if(!anchored)
			step(src, charger.dir)
		return PRECRUSH_STOPPED

	throw_at(get_step(loc, (charger.dir & (NORTH|SOUTH) ? pick(EAST, WEST) : pick(NORTH, SOUTH))), 1, 1, charger, (mob_size < charger.mob_size))

	charge_datum.speed_down(1) //Lose one turf worth of speed.
	return PRECRUSH_PLOWED


/turf/pre_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(charge_datum.valid_steps_taken >= charge_datum.max_steps_buildup)
		return 2 //Should dismantle, or at least heavily damage it.
	return 3 //Lighter damage.


// ***************************************
// *********** Post-Crush
// ***************************************

/atom/proc/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	return PRECRUSH_STOPPED //By default, if this happens then movement stops. But not necessarily.


/obj/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(anchored) //Did it manage to stop it?
		charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
		span_xenowarning("We ram into [src] and skid to a halt!"))
		if(charger.is_charging > CHARGE_OFF)
			charge_datum.do_stop_momentum(FALSE)
		return PRECRUSH_STOPPED
	var/fling_dir = pick(GLOB.cardinals - ((charger.dir & (NORTH|SOUTH)) ? list(NORTH, SOUTH) : list(EAST, WEST))) //Fling them somewhere not behind nor ahead of the charger.
	var/fling_dist = min(round(CHARGE_SPEED(charge_datum)) + 1, 3)
	if(!step(src, fling_dir) && density)
		charge_datum.do_stop_momentum(FALSE) //Failed to be tossed away and returned, more powerful than ever, to block the charger's path.
		charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
			span_xenowarning("We ram into [src] and skid to a halt!"))
		return PRECRUSH_STOPPED
	if(--fling_dist)
		for(var/i in 1 to fling_dist)
			if(!step(src, fling_dir))
				break
	charger.visible_message("[span_warning("[charger] knocks [src] aside.")]!",
	span_xenowarning("We knock [src] aside.")) //Canisters, crates etc. go flying.
	charge_datum.speed_down(2) //Lose two turfs worth of speed.
	return PRECRUSH_PLOWED


/obj/structure/razorwire/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(!anchored)
		return ..()
	razorwire_tangle(charger, RAZORWIRE_ENTANGLE_DELAY * 0.10) //entangled for only 10% as long or 0.5 seconds
	charger.visible_message(span_danger("The barbed wire slices into [charger]!"),
	span_danger("The barbed wire slices into you!"), null, 5)
	charger.Paralyze(0.5 SECONDS)
	charger.apply_damage(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, BRUTE, sharp = TRUE, updating_health = TRUE) //Armor is being ignored here.
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	update_icon()
	return PRECRUSH_ENTANGLED //Let's return this so that the charger may enter the turf in where it's entangled, if it survived the wounds without gibbing.


/obj/structure/mineral_door/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(!anchored)
		return ..()
	if(!open)
		toggle_state(charger)
	if(density)
		return PRECRUSH_STOPPED
	charger.visible_message(span_danger("[charger] slams [src] open!"),
	span_xenowarning("We slam [src] open!"))
	return PRECRUSH_PLOWED


/obj/machinery/vending/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(!anchored)
		return ..()
	tip_over()
	if(density)
		return PRECRUSH_STOPPED
	charger.visible_message(span_danger("[charger] slams [src] into the ground!"),
	span_xenowarning("We slam [src] into the ground!"))
	return PRECRUSH_PLOWED

/obj/vehicle/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	take_damage(charger.xeno_caste.melee_damage * charger.xeno_melee_damage_modifier, BRUTE, MELEE)
	if(density && charger.move_force <= move_resist)
		charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
		span_xenowarning("We ram into [src] and skid to a halt!"))
		charge_datum.do_stop_momentum(FALSE)
		return PRECRUSH_STOPPED
	charge_datum.speed_down(2) //Lose two turfs worth of speed.
	return NONE

/mob/living/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/ability/xeno_action/ready_charge/charge_datum)
	if(density && ((mob_size == charger.mob_size && charger.is_charging <= CHARGE_MAX) || mob_size > charger.mob_size))
		charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
		span_xenowarning("We ram into [src] and skid to a halt!"))
		charge_datum.do_stop_momentum(FALSE)
		step(src, charger.dir)
		return PRECRUSH_STOPPED

	switch(charge_datum.charge_type)
		if(CHARGE_CRUSH)
			Paralyze(CHARGE_SPEED(charge_datum) * 2 SECONDS)
		if(CHARGE_BULL_HEADBUTT)
			Paralyze(CHARGE_SPEED(charge_datum) * 2.5 SECONDS)

	if(anchored)
		charge_datum.do_stop_momentum(FALSE)
		charger.visible_message(span_danger("[charger] rams into [src] and skids to a halt!"),
			span_xenowarning("We ram into [src] and skid to a halt!"))
		return PRECRUSH_STOPPED

	switch(charge_datum.charge_type)
		if(CHARGE_CRUSH, CHARGE_BULL, CHARGE_BEHEMOTH)
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

			charger.visible_message(span_danger("[charger] rams [src]!"),
			span_xenodanger("We ram [src]!"))
			charge_datum.speed_down(1) //Lose one turf worth of speed.
			GLOB.round_statistics.bull_crush_hit++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "bull_crush_hit")
			return PRECRUSH_PLOWED

		if(CHARGE_BULL_GORE)
			if(world.time > charge_datum.next_special_attack)
				charge_datum.next_special_attack = world.time + 2 SECONDS
				attack_alien_harm(charger, charger.xeno_caste.melee_damage * charger.xeno_melee_damage_modifier, charger.zone_selected, FALSE, TRUE, TRUE) //Free gore attack.
				emote_gored()
				var/turf/destination = get_step(loc, charger.dir)
				if(destination)
					throw_at(destination, 1, 1, charger, FALSE)
				charger.visible_message(span_danger("[charger] gores [src]!"),
					span_xenowarning("We gore [src] and skid to a halt!"))
				GLOB.round_statistics.bull_gore_hit++
				SSblackbox.record_feedback("tally", "round_statistics", 1, "bull_gore_hit")


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

			charger.visible_message(span_danger("[charger] rams into [src] and flings [p_them()] away!"),
				span_xenowarning("We ram into [src] and skid to a halt!"))
			GLOB.round_statistics.bull_headbutt_hit++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "bull_headbutt_hit")

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
