/obj/item/explosive/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/det.dmi'
	icon_state = "plastic-explosive"
	worn_icon_state = "plasticx"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	/// whether the plastic explosive is armed or not
	var/armed = FALSE
	/// the time it takes for the c4 to detonate
	var/timer = 10
	/// the plastic explosive has not detonated yet
	var/detonation_pending
	/// Whether we're towards the end of the det timer, for sprite updates
	var/alarm_sounded = FALSE
	/// which atom the plastique explosive is planted on
	var/atom/plant_target = null
	/// smoke type created when the c4 detonates
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	/// radius this smoke will encompass
	var/smokeradius = 1
	///Current/last user of the c4
	var/mob/living/last_user

/obj/item/explosive/plastique/Destroy()
	plant_target = null
	last_user = null
	return ..()

/obj/item/explosive/plastique/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][plant_target ? "_set" : ""]"
	if(armed)
		icon_state = "[icon_state][alarm_sounded ? "_armed" : "_on"]"

/obj/item/explosive/plastique/attack_self(mob/user)
	. = ..()
	var/newtime = tgui_input_number(usr, "Please set the timer.", "Timer", 10, 60, 10)
	if(!newtime)
		return
	timer = newtime
	to_chat(user, "Timer set for [timer] seconds.")

/obj/item/explosive/plastique/ex_act(severity)
	if(QDELETED(src))
		return
	if(severity == EXPLODE_DEVASTATE)
		take_damage(INFINITY, BRUTE, BOMB, 0)

/obj/item/explosive/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/explosive/plastique/afterattack(atom/target, mob/user, flag)
	if(!flag)
		return FALSE
	if(!target.can_plastique(user, src))
		return FALSE
	user.visible_message(span_warning("[user] is trying to plant [name] on [target]!"),
	span_warning("You are trying to plant [name] on [target]!"))

	if(!do_after(user, 2 SECONDS, NONE, target, BUSY_ICON_HOSTILE) || !target.can_plastique(user, src))
		return FALSE

	plant_plastique(target, user)
	return TRUE

/obj/item/explosive/plastique/attack_hand(mob/living/user)
	if(armed)
		remove_plastique(user)
	return ..()

///Plants the c4 on something
/obj/item/explosive/plastique/proc/plant_plastique(atom/target, mob/living/user)
	RegisterSignal(target, COMSIG_ATOM_TRY_PLASTIQUE, PROC_REF(on_target_attempt_plastique))
	//reg sig for target deletion?
	user.drop_held_item()
	var/location
	location = target
	var/user_turf = get_turf(user)
	if(isturf(target) && user_turf != (get_turf(target))) //we position the c4 differently so it can't be seen from the other side of the solid turf we're blowing up
		forceMove(user_turf)
		var/direction_to_target = get_dir(user_turf, target)
		switch(direction_to_target)
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
			if(NORTHEAST)
				pixel_x = 32
				pixel_y = 32
			if(NORTHWEST)
				pixel_x = -32
				pixel_y = 32
			if(SOUTHEAST)
				pixel_x = 32
				pixel_y = -32
			if(SOUTHWEST)
				pixel_x = -32
				pixel_y = -32
	else
		forceMove(location)
	armed = TRUE
	timer = target.plastique_time_mod(timer)
	last_user = user

	log_bomber(user, "planted", src, "on [target] with a [timer] second fuse", message_admins = TRUE)

	user.visible_message(span_warning("[user] plants [name] on [target]!"),
	span_warning("You plant [name] on [target]! Timer counting down from [timer]."))

	plant_target = target
	if(ismovable(plant_target))
		var/atom/movable/mover = plant_target
		mover.vis_contents += src
		layer = ABOVE_ALL_MOB_LAYER
	detonation_pending = addtimer(CALLBACK(src, PROC_REF(warning_sound), target, 'sound/items/countdown.ogg', 20, TRUE), ((timer*10) - 27), TIMER_STOPPABLE)
	update_appearance(UPDATE_ICON)

///Removes from a target
/obj/item/explosive/plastique/proc/remove_plastique(mob/living/user)
	if(!do_after(user, 2 SECONDS, NONE, plant_target, BUSY_ICON_HOSTILE))
		return

	UnregisterSignal(plant_target, COMSIG_ATOM_TRY_PLASTIQUE)

	if(ismovable(plant_target))
		var/atom/movable/T = plant_target
		T.vis_contents -= src
		layer = initial(layer)

	forceMove(get_turf(user))
	pixel_y = 0
	pixel_x = 0
	deltimer(detonation_pending)

	user.visible_message(span_warning("[user] disarmed [src] on [plant_target]!"),
	span_warning("You disarmed [src] on [plant_target]!"))

	if(ismob(plant_target))
		log_combat(user, plant_target, "removed [src] from")
		log_game("[key_name(usr)] disarmed [src] on [key_name(plant_target)].")
	else
		log_game("[key_name(user)] disarmed [src] on [plant_target] at [AREACOORD(plant_target.loc)].")

	armed = FALSE
	alarm_sounded = FALSE
	plant_target = null
	last_user = null
	update_appearance(UPDATE_ICON)

///Lets other c4 know that something is already on a target
/obj/item/explosive/plastique/proc/on_target_attempt_plastique(source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_CANCEL_PLASTIQUE

///Triggers a warning beep prior to the actual detonation, while also setting the actual detonation timer
/obj/item/explosive/plastique/proc/warning_sound()
	if(armed)
		playsound(plant_target, 'sound/items/countdown.ogg', 20, TRUE, 5)
		detonation_pending = addtimer(CALLBACK(src, PROC_REF(detonate)), 27, TIMER_STOPPABLE)
		alarm_sounded = TRUE
		update_appearance(UPDATE_ICON)

///Handles the actual explosion effects
/obj/item/explosive/plastique/proc/detonate()
	if(QDELETED(plant_target))
		playsound(plant_target, 'sound/weapons/ring.ogg', 100, FALSE, 25)
		explosion(plant_target, flash_range = 1) //todo: place as abuse of explosion
		qdel(src)
		return
	explosion(plant_target, 0, 0, 1, 0, 0, 0, 1, 0, 1, explosion_cause=src)
	playsound(plant_target, SFX_EXPLOSION_SMALL, 100, FALSE, 25)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(smokeradius, plant_target, 2)
	smoke.start()
	plant_target.plastique_act(last_user)
	qdel(src)

///Handles the effect of c4 on the atom - overridden as needed
/atom/proc/plastique_act(mob/living/plastique_user)
	ex_act(EXPLODE_DEVASTATE)

///Allows the c4 timer to be tweaked on certain atoms as required
/atom/proc/plastique_time_mod(time)
	return time

///Whether this atom can have c4 or similar attached to it
/atom/proc/can_plastique(mob/user, obj/plastique)
	if(SEND_SIGNAL(src, COMSIG_ATOM_TRY_PLASTIQUE) & COMSIG_ATOM_CANCEL_PLASTIQUE)
		to_chat(user, "[span_warning("There is already a device attached to [src]")].")
		return FALSE
	if(resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "[span_warning("[src] is much too tough for you to do anything to it with [plastique]")].")
		return FALSE
	return TRUE

/obj/item/can_plastique(mob/user, obj/plastique)
	return FALSE

/turf/open/can_plastique(mob/user, obj/plastique)
	return FALSE
