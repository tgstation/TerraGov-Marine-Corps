// ***************************************
// *********** Charge
// ***************************************

/datum/action/xeno_action/ready_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	mechanics_text = "Toggles the Crusher’s movement based charge on and off."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_CHARGE
	var/next_move_limit = 0
	var/charge_speed = 0
	var/turf/lastturf = null
	var/charge_dir = null
	var/charge_ability_on = FALSE


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
	RegisterSignal(charger, COMSIG_LIVING_DO_MOVE_TURFTOTURF, .proc/update_charging)
	RegisterSignal(charger, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)
	RegisterSignal(charger, COMSIG_LIVING_LEGCUFFED, .proc/on_legcuffed)
	if(verbose)
		to_chat(charger, "<span class='xenonotice'>We will charge when moving, now.</span>")


/datum/action/xeno_action/ready_charge/proc/charge_off(verbose = TRUE)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging != CHARGE_OFF)
		do_stop_momentum()
	UnregisterSignal(charger, list(COMSIG_LIVING_DO_MOVE_TURFTOTURF, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_LEGCUFFED))
	if(verbose)
		to_chat(charger, "<span class='xenonotice'>We will no longer charge when moving.</span>")
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


/datum/action/xeno_action/ready_charge/proc/update_charging(datum/source, turf/newloc, newdir)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.throwing)
		return

	if(charger.is_charging == CHARGE_OFF)
		if(charger.dir != newdir) //It needs to move twice in the same direction, at least, to begin charging.
			return
		charge_dir = newdir
		if(!check_momentum(newdir))
			charge_dir = null
			return
		charger.is_charging = CHARGE_BUILDINGUP
		handle_momentum()
		return

	if(!check_momentum(newdir))
		do_stop_momentum()
		return

	handle_momentum()


/datum/action/xeno_action/ready_charge/proc/do_start_crushing()
	var/mob/living/carbon/xenomorph/charger = owner
	RegisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE), .proc/do_crush)
	charger.is_charging = CHARGE_ON
	charger.update_icons()


/datum/action/xeno_action/ready_charge/proc/do_stop_crushing()
	var/mob/living/carbon/xenomorph/charger = owner
	UnregisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE))
	if(charge_speed > 0) //If this is false, then do_stop_momentum() should have it handled already.
		charger.is_charging = CHARGE_BUILDINGUP
		charger.update_icons()


/datum/action/xeno_action/ready_charge/proc/do_stop_momentum()
	var/mob/living/carbon/xenomorph/charger = owner
	if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE) //Message now happens without a stun condition
		charger.visible_message("<span class='danger'>[src] skids to a halt!</span>",
		"<span class='xenowarning'>We skid to a halt.</span>", null, 5)
	next_move_limit = 0
	charge_speed = 0
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

	if(charger.plasma_stored < 5)
		return FALSE
	
	return TRUE


/datum/action/xeno_action/ready_charge/proc/handle_momentum()
	var/mob/living/carbon/xenomorph/charger = owner

	if(charger.pulling && charge_speed > CHARGE_SPEED_BUILDUP)
		charger.stop_pulling()

	charger.plasma_stored -= round(charge_speed) //Eats up plasma the faster you go, up to 0.5 per tile at max speed
	next_move_limit = world.time + 0.5 SECONDS

	if(charge_speed < CHARGE_SPEED_MAX)
		charge_speed += CHARGE_SPEED_BUILDUP //Speed increases each step taken. Caps out at 14 tiles
		if(charge_speed == CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
			do_start_crushing()
		else if(charge_speed >= CHARGE_SPEED_MAX)
			charger.is_charging = CHARGE_MAX
			charger.emote("roar")
		charger.add_movespeed_modifier(MOVESPEED_ID_XENO_CHARGE, TRUE, 100, NONE, TRUE, -charge_speed)

	if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		if(!MODULUS(charge_speed, (CHARGE_SPEED_BUILDUP * 4)))
			playsound(charger.loc, "alien_charge", 50)

		var/shake_dist = min(round(charge_speed * 5), 8)
		for(var/mob/living/carbon/victim in range(shake_dist, charger))
			if(isxeno(victim))
				continue
			if(victim.stat == DEAD)
				continue
			if(victim.client)
				shake_camera(victim, 1, 1)
			if(victim.loc != charger.loc || !victim.lying || isnestedhost(victim))
				continue
			charger.visible_message("<span class='danger'>[charger] runs [victim] over!</span>",
				"<span class='danger'>We run [victim] over!</span>", null, 5)
			victim.take_overall_damage(charge_speed * 10)
			animation_flash_color(victim)
	
	lastturf = charger.loc


/datum/action/xeno_action/ready_charge/proc/speed_down(amt)
	if(charge_speed == 0)
		return
	charge_speed -= amt
	if(charge_speed <= 0)
		charge_speed = 0
		do_stop_momentum()
	else if(charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		do_stop_crushing()


/datum/action/xeno_action/ready_charge/proc/do_crush(datum/source, atom/crushed)
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.incapacitated() || charger.now_pushing)
		return NONE
	var/preserved_name = crushed.name
	var/crushed_type = (isobj(crushed) ? "obj" : (isliving(crushed) ? "living" : (isturf(crushed) ? "turf" : "wha")))
	. = crushed.crush_act(charger, src)
	if(QDELETED(crushed))
		switch(crushed_type)
			if("obj")
				charger.visible_message("<span class='danger'>[charger] crushes [preserved_name]!</span>",
				"<span class='xenodanger'>We crush [preserved_name]!</span>")
			if("living")
				charger.visible_message("<span class='danger'>[charger] anihilates [preserved_name]!</span>",
				"<span class='xenodanger'>We anihilate [preserved_name]!</span>")
			if("turf")
				charger.visible_message("<span class='danger'>[charger] plows straight through [preserved_name]!</span>",
				"<span class='xenowarning'>We plow straight through [preserved_name]!</span>")
		return COMPONENT_MOVABLE_PREBUMP_PLOWED


// ***************************************
// *********** Crush
// ***************************************

//Anything called here will have failed CanPass(), so it's likely dense.
/atom/proc/crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	return //Pass through and enter the Bump() line if undefined.


/obj/crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) || charger.is_charging < CHARGE_ON)
		charge_datum.do_stop_momentum()
		return COMPONENT_MOVABLE_PREBUMP_STOPPED
	if(anchored)
		charge_datum.speed_down(CHARGE_SPEED_BUILDUP * 3) //Lose three turfs worth of speed
		take_damage(charge_datum.charge_speed * 80)
		if(anchored && !QDELETED(src)) //Did it manage to stop us?
			charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
			"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
			if(charger.is_charging > CHARGE_OFF)
				charge_datum.do_stop_momentum()
			return post_crush_act(charger) //Some objects may want the charger to stop before entering, some after.
		charger.visible_message("<span class='danger'>[charger] crushes [src]!</span>",
		"<span class='xenodanger'>We crush [src]!</span>")
		return

	if(buckled_mob)
		unbuckle()
	playsound(loc, "punch", 25, 1)
	take_damage(charge_datum.charge_speed * 20)
	if(QDELETED(src))
		return
	var/fling_dir = pick(GLOB.cardinals - ((charger.dir & (NORTH|SOUTH)) ? list(NORTH, SOUTH) : list(EAST, WEST))) //Fling them somewhere not behind nor ahead of the charger.
	var/fling_dist = min(round(charge_datum.charge_speed) + 1, 3)
	if(!step(src, fling_dir) && density)
		charge_datum.do_stop_momentum() //Failed to be tossed away and returned, more powerful than ever, to block the charger's path.
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
			"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		return COMPONENT_MOVABLE_PREBUMP_STOPPED
	if(--fling_dist)
		for(var/i in 1 to fling_dist)
			if(!step(src, fling_dir))
				break
	charger.visible_message("<span class='warning'>[charger] knocks [src] aside.</span>!",
	"<span class='xenowarning'>We knock [src] aside.</span>") //Canisters, crates etc. go flying.
	charge_datum.speed_down(CHARGE_SPEED_BUILDUP * 2) //Lose two turfs worth of speed
	return COMPONENT_MOVABLE_PREBUMP_PLOWED


/mob/living/crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	playsound(loc, "punch", 25, 1)
	if(buckled)
		buckled.unbuckle()
	animation_flash_color(src)

	if(stat != DEAD)
		log_combat(charger, src, "xeno charged")
		apply_damage(charge_datum.charge_speed * 40, BRUTE)
		if(QDELETED(src))
			return
		if((mob_size == charger.mob_size && charger.is_charging <= CHARGE_MAX) || mob_size > charger.mob_size)
			charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
			"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
			charge_datum.do_stop_momentum()
			step(src, charger.dir)
			return COMPONENT_MOVABLE_PREBUMP_STOPPED
		knock_down(charge_datum.charge_speed * 4)

	if(anchored)
		charge_datum.do_stop_momentum()
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
			"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		return COMPONENT_MOVABLE_PREBUMP_STOPPED

	var/fling_dir = pick((charger.dir & (NORTH|SOUTH)) ? list(WEST, EAST, charger.dir|WEST, charger.dir|EAST) : list(NORTH, SOUTH, charger.dir|NORTH, charger.dir|SOUTH)) //Fling them somewhere not behind nor ahead of the charger.
	var/fling_dist = min(round(charge_datum.charge_speed) + 1, 3)	
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
	charge_datum.speed_down(CHARGE_SPEED_BUILDUP) //Lose one turf worth of speed
	return COMPONENT_MOVABLE_PREBUMP_PLOWED


//Special override case. May not call the parent.
/mob/living/carbon/xenomorph/crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(!issamexenohive(charger))
		return ..()

	playsound(loc, "punch", 25, 1)
	if(buckled)
		buckled.unbuckle()
	animation_flash_color(src)

	if(anchored || (mob_size > charger.mob_size && charger.is_charging <= CHARGE_MAX))
		charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
		"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
		charge_datum.do_stop_momentum()
		if(!anchored)
			step(src, charger.dir)
		return COMPONENT_MOVABLE_PREBUMP_STOPPED
	
	throw_at(get_step(loc, (charger.dir & (NORTH|SOUTH) ? pick(EAST, WEST) : pick(NORTH, SOUTH))), 1, 1, charger, (mob_size < charger.mob_size))

	charge_datum.speed_down(CHARGE_SPEED_BUILDUP) //Lose one turf worth of speed
	return COMPONENT_MOVABLE_PREBUMP_PLOWED


/turf/crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	if(charge_datum.charge_speed >= CHARGE_SPEED_MAX)
		ex_act(2) //Should dismantle, or at least heavily damage it.
	else
		ex_act(3) //Lighter damage.
	if(QDELETED(src))
		return

	charger.visible_message("<span class='danger'>[charger] rams into [src] and skids to a halt!</span>",
	"<span class='xenowarning'>We ram into [src] and skid to a halt!</span>")
	charge_datum.do_stop_momentum()
	return COMPONENT_MOVABLE_PREBUMP_STOPPED

//POST CRUSHING

/atom/proc/post_crush_act(mob/living/carbon/xenomorph/charger)
	return FALSE //By default, if this happens then movement stops. But not necessarily.


/obj/structure/razorwire/post_crush_act(mob/living/carbon/xenomorph/charger)
	razorwire_tangle(charger, RAZORWIRE_ENTANGLE_DELAY * 0.5) //entangled for only half as long
	charger.visible_message("<span class='danger'>The barbed wire slices into [charger]!</span>",
	"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
	charger.knock_down(1)
	charger.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_MED), BRUTE, ran_zone(), null, null, 1)
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	update_icon()
	return COMPONENT_MOVABLE_PREBUMP_ENTANGLED //Let's return this so that the charger may enter the turf in where it's entangled, if it survived the wounds without gibbing.


/obj/structure/mineral_door/post_crush_act(mob/living/carbon/xenomorph/charger)
	TryToSwitchState(charger)
	if(density)
		return COMPONENT_MOVABLE_PREBUMP_STOPPED
	charger.visible_message("<span class='danger'>[charger] slams [src] open!</span>",
	"<span class='xenowarning'>We slam [src] open!</span>")
	return COMPONENT_MOVABLE_PREBUMP_PLOWED


/obj/machinery/vending/post_crush_act(mob/living/carbon/xenomorph/charger)
	tip_over()
	if(density)
		return COMPONENT_MOVABLE_PREBUMP_STOPPED
	charger.visible_message("<span class='danger'>[charger] slams [src] into the ground!</span>",
	"<span class='xenowarning'>We slam [src] into the ground!</span>")
	return COMPONENT_MOVABLE_PREBUMP_PLOWED
