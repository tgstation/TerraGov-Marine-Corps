/obj/item/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	worn_icon_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	atom_flags = CONDUCT
	/// Has the flash burnt out?
	var/broken = FALSE
	// The number of times this has been used recently.
	var/times_used = 0
	/// The last time the flash was used.
	var/last_used = 0

/obj/item/flash/attack_self(mob/user)
	. = ..()
	if(.)
		return

	if(!can_use(user))
		return TRUE

	last_used = world.time
	if(try_break(user))
		return TRUE
	times_used++

	playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1, MEDIUM_SOUND_RANGE)
	flick("flash_flashing", src)
	user.log_message("flashed an area with [key_name(src)]", LOG_ATTACK)

	for(var/mob/living/carbon/human/nearby_human in oviewers(3, null))
		nearby_human.flash_act()

	return TRUE

/obj/item/flash/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(.)
		return

	if(!ismob(target))
		return FALSE

	var/mob/target_mob = target
	log_combat(user, target_mob, "attempted to flash", src)

	if(!can_use(user))
		return TRUE

	last_used = world.time
	if(try_break(user))
		return TRUE
	times_used++

	playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1, MEDIUM_SOUND_RANGE)
	flick("flash_flashing", src)

	if(issilicon(target_mob))
		var/mob/living/silicon/target_silicon = target_mob
		user.visible_message(span_notice("[user] overloads [target_silicon]'s sensors with the flash!"))
		target_silicon.Paralyze(rand(10 SECONDS, 20 SECONDS))
		return TRUE

	if(iscarbon(target_mob) && target_mob.flash_act())
		var/mob/living/carbon/target_carbon = target_mob
		user.visible_message(span_disarm("[user] blinds [target_carbon] with the flash!"))
		target_carbon.Paralyze(20 SECONDS)
		return TRUE

	user.visible_message(span_notice("[user] fails to blind [target_mob] with the flash!"))
	return TRUE

/obj/item/flash/emp_act(severity)
	. = ..()
	if(.)
		return

	if(can_use(null, ignore_uses = TRUE))
		return

	last_used = world.time
	if(try_break(null))
		return
	times_used++

	playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1, MEDIUM_SOUND_RANGE)
	flick("flash_flashing", src)

	if(iscarbon(loc))
		var/mob/living/carbon/carbon_holder = loc
		if(carbon_holder.flash_act())
			carbon_holder.Paralyze(20 SECONDS)
			carbon_holder.visible_message(span_disarm("[carbon_holder] is blinded by the flash!"))

/// Checks if the flash can be used.
/obj/item/flash/proc/can_use(mob/user, ignore_uses = FALSE)
	if(user?.skills.getRating(SKILL_POLICE) < SKILL_POLICE_FLASH)
		to_chat(user, span_warning("You don't seem to know how to use [src]..."))
		return FALSE
	if(broken)
		if(user)
			to_chat(user, span_warning("\The [src] is broken."))
		return FALSE
	if(!ignore_uses)
		flash_recharge()
		if(times_used > 5)
			if(user)
				to_chat(user, span_warning("*click* *click*"))
			return FALSE
	return TRUE

/// Tries to break the flash if it was used too many times recently.
/// Returns TRUE if it broke.
/obj/item/flash/proc/try_break(mob/user)
	if(prob(times_used * 2)) // 5 = 10% maximum
		broken = TRUE
		icon_state = "flash_burnt"
		if(user)
			to_chat(user, span_warning("The bulb has burnt out!"))
		return TRUE
	return FALSE

/// Recharges the flash's uses based on how much time has passed.
/obj/item/flash/proc/flash_recharge()
	for(var/i = 0, i < 3, i++)
		if(last_used + 60 SECONDS > world.time)
			break
		last_used += 60 SECONDS
		times_used -= 2
	last_used = world.time
	times_used = max(0, round(times_used)) // Sanity.

/obj/item/flash/synthetic
	name = "synthetic flash"
	desc = "When a problem arises, SCIENCE is the solution."
