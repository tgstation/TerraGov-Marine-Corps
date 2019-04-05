/obj/item/explosive/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "plastic-explosive_off"
	item_state = "plasticx"
	flags_item = NOBLUDGEON
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/timer = 10
	var/atom/plant_target = null //which atom the plstique explosive is planted on

/obj/item/explosive/plastique/Destroy()
	plant_target = null
	. = ..()

/obj/item/explosive/plastique/attack_self(mob/user)
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use [src].</span>",
		"<span class='notice'>You fumble around figuring out how to use [src].</span>")
		var/fumbling_time = 20
		if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
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
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use [src].</span>",
		"<span class='notice'>You fumble around figuring out how to use [src].</span>")
		var/fumbling_time = 50
		if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
			return
	if(istype(target, /obj/item) || isopenturf(target))
		return FALSE
	if(isobj(target))
		var/obj/O = target
		if(CHECK_MULTIPLE_BITFIELDS(O.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			return FALSE
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		if(W.hull)
			return FALSE
	if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if(!W.damageable)
			to_chat(user, "<span class='warning'>[W] is much too tough for you to do anything to it with [src]</span>.")
			return FALSE

	user.visible_message("<span class='warning'>[user] is trying to plant [name] on [target]!</span>",
	"<span class='warning'>You are trying to plant [name] on [target]!</span>")
	bombers += "[key_name(user)] attached C4 to [target.name]."

	if(do_mob(user, target, 50, BUSY_ICON_HOSTILE))
		user.drop_held_item()
		plant_target = target
		loc = null
		var/location
		if (isturf(target)) location = target
		if (isobj(target)) location = target.loc

		if(ismob(target))
			log_combat(user, target, "attached [src] to")
			log_game("[key_name(usr)] planted [src.name] on [key_name(target)] with [timer] second fuse.")
			message_admins("[ADMIN_TPMONTY(user)]  planted [src.name] on [ADMIN_TPMONTY(target)] with [timer] second fuse.")
		else
			log_game("[key_name(user)] planted [src.name] on [target.name] at [AREACOORD(target.loc)] with [timer] second fuse.")
			message_admins("[ADMIN_TPMONTY(user)] planted [src.name] on [target.name] at [ADMIN_VERBOSEJMP(target.loc)] with [timer] second fuse.")

		log_explosion("[key_name(user)] planted [src] at [AREACOORD(user.loc)] with [timer] second fuse.")

		target.overlays += image('icons/obj/items/assemblies.dmi', "plastic-explosive_set_armed")
		user.visible_message("<span class='warning'>[user] plants [name] on [target]!</span>",
		"<span class='warning'>You plant [name] on [target]! Timer counting down from [timer].</span>")
		spawn(timer*10)
			if(plant_target && !plant_target.gc_destroyed)
				explosion(location, -1, -1, 3)
				if(istype(plant_target,/turf/closed/wall))
					var/turf/closed/wall/W = plant_target
					W.ChangeTurf(/turf/open/floor/plating)
				else if(istype(plant_target,/obj/machinery/door))
					qdel(plant_target)
				else
					plant_target.ex_act(1)
				if(plant_target && !plant_target.gc_destroyed)
					plant_target.overlays -= image('icons/obj/items/assemblies.dmi', "plastic-explosive_set_armed")
			qdel(src)

/obj/item/explosive/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return
