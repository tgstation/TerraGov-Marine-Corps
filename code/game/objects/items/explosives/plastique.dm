/obj/item/explosive/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "plastic-explosive_off"
	item_state = "plasticx"
	flags_item = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	var/armed = FALSE
	var/timer = 10
	var/detonation_pending
	var/atom/plant_target = null //which atom the plastique explosive is planted on

/obj/item/explosive/plastique/Destroy()
	plant_target = null
	return ..()

/obj/item/explosive/plastique/attack_self(mob/user)
	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = 2 SECONDS
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	if(newtime > 60)
		newtime = 60
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
	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = 5 SECONDS
		if(!do_after(user, fumbling_time, TRUE, target, BUSY_ICON_UNSKILLED))
			return
	user.visible_message(span_warning("[user] is trying to plant [name] on [target]!"),
	span_warning("You are trying to plant [name] on [target]!"))

	if(do_after(user, 5 SECONDS, TRUE, target, BUSY_ICON_HOSTILE))
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

/obj/item/explosive/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/explosive/plastique/attack_hand(mob/living/user)
	if(armed)
		to_chat(user, "<font color='warning'>Disarm [src] first to remove it!</font>")
		return
	return ..()

/obj/item/explosive/plastique/attackby(obj/item/I, mob/user, params)
	if(ismultitool(I) && armed)
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
			user.visible_message(span_notice("[user] fumbles around figuring out how to disarm [src]."),
			span_notice("You fumble around figuring out how to disarm [src]."))
			var/fumbling_time = 3 SECONDS
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

		if(!do_after(user, 5 SECONDS, TRUE, plant_target, BUSY_ICON_HOSTILE))
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
	plant_target.ex_act(EXPLODE_DEVASTATE)
	qdel(src)
