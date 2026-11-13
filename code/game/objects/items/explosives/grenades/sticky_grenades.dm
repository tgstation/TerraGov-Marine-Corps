/obj/item/explosive/grenade/sticky
	name = "\improper M40 adhesive charge grenade"
	desc = "Designed for use against various fast moving drones, this grenade will adhere to its target before detonating. It's fuse is set to 5 seconds."
	icon_state = "grenade_sticky"
	icon_state_mini = "grenade_round_orange"
	worn_icon_state = "grenade_sticky"
	det_time = 5 SECONDS
	light_impact_range = 2
	weak_impact_range = 3

	///if this specific grenade should be allowed to self sticky
	var/self_sticky = FALSE

/obj/item/explosive/grenade/sticky/Initialize(mapload)
	. = ..()
	give_component()

/obj/item/explosive/grenade/sticky/can_stick_to(atom/hit_atom)
	if(!active || isturf(hit_atom))
		return FALSE
	return TRUE

/obj/item/explosive/grenade/sticky/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(target != user)
		return
	if(!self_sticky)
		return
	user.drop_held_item()
	activate()
	stuck_to(target)

/obj/item/explosive/grenade/sticky/launched_det_time()
	det_time -= 1 SECONDS

/// Handles giving the appropriate component to the grenade. Exists because Initialize is forced to call parent, and subtypes don't want to have both components
/obj/item/explosive/grenade/sticky/proc/give_component()
	AddComponent(/datum/component/sticky_item, icon, initial(icon_state) + "_stuck")

/obj/item/explosive/grenade/sticky/trailblazer
	name = "\improper M45 Trailblazer grenade"
	desc = "Capsule based grenade that sticks to sufficiently hard surfaces, causing a trail of air combustable gel to form. It is set to detonate in 5 seconds."
	icon_state = "grenade_sticky_fire"
	icon_state_mini = "grenade_stick_orange"
	worn_icon_state = "grenade_sticky_fire"
	det_time = 5 SECONDS
	self_sticky = TRUE

/obj/item/explosive/grenade/sticky/trailblazer/prime()
	flame_radius(0.5, get_turf(src))
	playsound(loc, SFX_INCENDIARY_EXPLOSION, 35)
	qdel(src)

/obj/item/explosive/grenade/sticky/trailblazer/give_component()
	AddComponent(/datum/component/sticky_item/move_behaviour, icon, initial(icon_state) + "_stuck")

/obj/item/explosive/grenade/sticky/trailblazer/stuck_to(atom/target)
	. = ..()
	var/turf/T = get_turf(src)
	T.ignite(25, 25)

///causes fire tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/trailblazer/on_move_sticky()
	var/turf/T = get_turf(src)
	T.ignite(25, 25)

/obj/item/explosive/grenade/sticky/cloaker
	name = "\improper M45 Cloaker grenade"
	desc = "Capsule based grenade that sticks to sufficiently hard surfaces, causing a trail of air combustable gel to form. This one creates cloaking smoke! It is set to detonate in 5 seconds."
	icon_state = "grenade_sticky_cloak"
	icon_state_mini = "grenade_stick_green"
	worn_icon_state = "grenade_sticky_cloak"
	det_time = 5 SECONDS
	light_impact_range = 1
	self_sticky = TRUE

/obj/item/explosive/grenade/sticky/cloaker/give_component()
	AddComponent(/datum/component/sticky_item/move_behaviour, icon, initial(icon_state) + "_stuck")

/obj/item/explosive/grenade/sticky/cloaker/prime()
	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread/tactical()
	playsound(loc, 'sound/effects/smoke_bomb.ogg', 35)
	smoke.set_up(1, loc, 8)
	smoke.start()
	qdel(src)

///causes fire tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/cloaker/on_move_sticky()
	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread/tactical()
	smoke.set_up(1, loc, 8)
	smoke.start()

/obj/item/explosive/grenade/sticky/pmc
	name = "\improper M50 adhesive charge grenade"
	desc = "Designed for use against various fast moving drones, this grenade will adhere to its target before detonating. Produced for private security firms. It's fuse is set to 3 seconds."
	icon_state = "grenade_sticky_pmc"
	icon_state_mini = "grenade_round_blue"
	worn_icon_state = "grenade_sticky_pmc"
	det_time = 3 SECONDS
	light_impact_range = 3
