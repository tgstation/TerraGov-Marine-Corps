/obj/item/explosive/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/det.dmi'
	icon_state = "plastic-explosive"
	item_state = "plasticx"
	flags_item = NOBLUDGEON
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

/obj/item/explosive/plastique/Destroy()
	plant_target = null
	return ..()

/obj/item/explosive/plastique/update_icon_state()
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

/obj/item/explosive/plastique/afterattack(atom/target, mob/user, flag)
	if(!flag)
		return FALSE
	if(istype(target, /obj/item) || isopenturf(target))
		return FALSE
	if(target.resistance_flags & INDESTRUCTIBLE)
		return FALSE
	if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if(!W.damageable)
			to_chat(user, "[span_warning("[W] is much too tough for you to do anything to it with [src]")].")
			return FALSE
	if((locate(/obj/item/detpack) in target) || (locate(/obj/item/explosive/plastique) in target)) //This needs a refactor.
		to_chat(user, "[span_warning("There is already a device attached to [target]")].")
		return FALSE
	user.visible_message(span_warning("[user] is trying to plant [name] on [target]!"),
	span_warning("You are trying to plant [name] on [target]!"))

	if(do_after(user, 2 SECONDS, NONE, target, BUSY_ICON_HOSTILE))
		if((locate(/obj/item/detpack) in target) || (locate(/obj/item/explosive/plastique) in target)) //This needs a refactor.
			to_chat(user, "[span_warning("There is already a device attached to [target]")].")
			return
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

		log_bomber(user, "planted", src, "on [target] with a [timer] second fuse", message_admins = TRUE)

		user.visible_message(span_warning("[user] plants [name] on [target]!"),
		span_warning("You plant [name] on [target]! Timer counting down from [timer]."))

		plant_target = target
		if(ismovableatom(plant_target))
			var/atom/movable/T = plant_target
			T.vis_contents += src
		detonation_pending = addtimer(CALLBACK(src, PROC_REF(warning_sound), target, 'sound/items/countdown.ogg', 20, TRUE), ((timer*10) - 27), TIMER_STOPPABLE)
		update_icon()

/obj/item/explosive/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/explosive/plastique/attack_hand(mob/living/user)
	if(armed)
		if(!do_after(user, 2 SECONDS, NONE, plant_target, BUSY_ICON_HOSTILE))
			return

		if(ismovableatom(plant_target))
			var/atom/movable/T = plant_target
			T.vis_contents -= src

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
		update_icon()
	return ..()

///Handles the actual explosion effects
/obj/item/explosive/plastique/proc/detonate()
	if(QDELETED(plant_target))
		playsound(plant_target, 'sound/weapons/ring.ogg', 100, FALSE, 25)
		explosion(plant_target, flash_range = 1) //todo: place as abuse of explosion
		qdel(src)
		return
	explosion(plant_target, 0, 0, 1, 0, 0, 0, 1, 0, 1)
	playsound(plant_target, sound(get_sfx("explosion_small")), 100, FALSE, 25)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(smokeradius, plant_target, 2)
	smoke.start()
	plant_target.plastique_act()
	qdel(src)

///Triggers a warning beep prior to the actual detonation, while also setting the actual detonation timer
/obj/item/explosive/plastique/proc/warning_sound()
	if(armed)
		playsound(plant_target, 'sound/items/countdown.ogg', 20, TRUE, 5)
		detonation_pending = addtimer(CALLBACK(src, PROC_REF(detonate)), 27, TIMER_STOPPABLE)
		alarm_sounded = TRUE
		update_icon()

///Handles the effect of c4 on the atom - overridden as needed
/atom/proc/plastique_act()
	ex_act(EXPLODE_DEVASTATE)

/obj/item/explosive/plastique/genghis_charge
	name = "EX-62 Genghis incendiary charge"
	desc = "A specialized device for incineration of bulk organic matter, patented Thermal Memory ensuring that all ignition proceeds safely away from the user. Will not attach to plants due to environmental concerns."
	icon_state = "genghis-charge"

/obj/item/explosive/plastique/genghis_charge/afterattack(atom/target, mob/user, flag)
	if(istype(target, /turf/closed/wall/resin))
		return ..()
	if(istype(target, /obj/structure/mineral_door/resin))
		return ..()
	balloon_alert(user, "Insufficient organic matter!")

/obj/item/explosive/plastique/genghis_charge/detonate()
	var/turf/flame_target = get_turf(plant_target)
	if(QDELETED(plant_target))
		playsound(plant_target, 'sound/weapons/ring.ogg', 100, FALSE, 25)
		flame_target.ignite(10, 5)
		qdel(src)
		return
	new /obj/flamer_fire/autospread(flame_target, 17, 31)
	playsound(plant_target, sound(get_sfx("explosion_small")), 100, FALSE, 25)
	qdel(src)

/obj/flamer_fire/autospread
	///Which directions this patch is capable of spreading to, as bitflags
	var/possible_directions = NONE

/obj/flamer_fire/autospread/Initialize(mapload, fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0, inherited_directions = NONE)
	. = ..()

	for(var/direction in GLOB.cardinals)
		if(inherited_directions && !(inherited_directions & direction))
			continue
		var/turf/turf_to_check = get_step(src, direction)
		if(turf_contains_valid_burnable(turf_to_check))
			possible_directions |= direction
			addtimer(CALLBACK(src, PROC_REF(spread_flames), direction, turf_to_check), rand(2, 7))

///Returns TRUE if the supplied turf has something we can ignite on, either a resin wall or door
/obj/flamer_fire/autospread/proc/turf_contains_valid_burnable(turf_to_check)
	if(istype(turf_to_check, /turf/closed/wall/resin))
		return TRUE
	if(locate(/obj/structure/mineral_door/resin) in turf_to_check)
		return TRUE
	return FALSE

///Ignites an adjacent turf or adds our possible directions to an existing flame
/obj/flamer_fire/autospread/proc/spread_flames(direction, turf/turf_to_burn)
	var/spread_directions = possible_directions & ~REVERSE_DIR(direction) //Make sure we can't go backwards
	var/old_flame = locate(/obj/flamer_fire) in turf_to_burn
	if(istype(old_flame, /obj/flamer_fire/autospread))
		var/obj/flamer_fire/autospread/old_spreader = old_flame
		spread_directions |= old_spreader.possible_directions
	if(old_flame)
		qdel(old_flame)
	new /obj/flamer_fire/autospread(turf_to_burn, 17, 31, flame_color, 0, 0, spread_directions)

///Allows the c4 timer to be tweaked on certain atoms as required
/atom/proc/plastique_time_mod(time)
	return time
