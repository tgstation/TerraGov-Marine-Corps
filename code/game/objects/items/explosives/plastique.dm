/obj/item/explosive/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "plastic-explosive_off"
	item_state = "plasticx"
	flags_item = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	/// whether the plastic explosive is armed or not
	var/armed = FALSE
	/// the time it takes for the c4 to detonate
	var/timer = 10
	/// the plastic explosive has not detonated yet
	var/detonation_pending
	/// which atom the plastique explosive is planted on
	var/atom/plant_target = null
	/// smoke type created when the c4 detonates
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	/// radius this smoke will encompass
	var/smokeradius = 1

/obj/item/explosive/plastique/Destroy()
	plant_target = null
	return ..()

/obj/item/explosive/plastique/attack_self(mob/user)
	var/newtime = tgui_input_number(usr, "Please set the timer.", "Timer", 10, 60, 10)
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

	if(do_after(user, 2 SECONDS, TRUE, target, BUSY_ICON_HOSTILE))
		if((locate(/obj/item/detpack) in target) || (locate(/obj/item/explosive/plastique) in target)) //This needs a refactor.
			to_chat(user, "[span_warning("There is already a device attached to [target]")].")
			return
		user.drop_held_item()
		var/location
		location = target
		forceMove(location)
		armed = TRUE

		log_combat(user, target, "attached [src] to")
		message_admins("[ADMIN_TPMONTY(user)] planted [src] on [target] at [ADMIN_VERBOSEJMP(target.loc)] with [timer] second fuse.")
		log_explosion("[key_name(user)] planted [src] at [AREACOORD(user.loc)] with [timer] second fuse.")

		user.visible_message(span_warning("[user] plants [name] on [target]!"),
		span_warning("You plant [name] on [target]! Timer counting down from [timer]."))

		plant_target = target
		if(ismovableatom(plant_target))
			var/atom/movable/T = plant_target
			T.vis_contents += src
		detonation_pending = addtimer(CALLBACK(src, .proc/detonate), timer*10, TIMER_STOPPABLE)
		var/beeping_timer = ((timer*10) - 27)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(target), 'sound/items/countdown.ogg', 40, TRUE), beeping_timer)


/obj/item/explosive/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/explosive/plastique/attack_hand(mob/living/user)
	if(armed)
		to_chat(user, "<font color='warning'>Disarm [src] first to remove it!</font>")
		return
	return ..()

/obj/item/explosive/plastique/attackby(obj/item/I, mob/user, params)
	if(ismultitool(I) && armed)
		if(!do_after(user, 2 SECONDS, TRUE, plant_target, BUSY_ICON_HOSTILE))
			return

		if(ismovableatom(plant_target))
			var/atom/movable/T = plant_target
			T.vis_contents -= src
			forceMove(plant_target.loc)
		else
			forceMove(plant_target)

		deltimer(detonation_pending)

		user.visible_message(span_warning("[user] disarmed [src] on [plant_target]!"),
		span_warning("You disarmed [src] on [plant_target]!"))

		if(ismob(plant_target))
			log_combat(user, plant_target, "removed [src] from")
			log_game("[key_name(usr)] disarmed [src] on [key_name(plant_target)].")
		else
			log_game("[key_name(user)] disarmed [src] on [plant_target] at [AREACOORD(plant_target.loc)].")

		armed = FALSE
		plant_target = null

/obj/item/explosive/plastique/proc/detonate()
	if(QDELETED(plant_target))
		playsound(loc, 'sound/weapons/ring.ogg', 200, FALSE)
		explosion(plant_target, 0, 0, 0, 1)
		qdel(src)
		return
	explosion(plant_target, 0, 0, 1, 0, 0, 1, 0, 1)
	playsound(loc, pick('sound/effects/explosion_small1.ogg','sound/effects/explosion_small2.ogg','sound/effects/explosion_small3.ogg' ), 200, FALSE)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(smokeradius, loc, 2)
	smoke.start()
	plant_target.ex_act(EXPLODE_DEVASTATE)
	qdel(src)
