/obj/item/explosive/grenade/sticky
	name = "\improper M40 adhesive charge grenade"
	desc = "Designed for use against various fast moving drones, this grenade will adhere to its target before detonating. It's fuse is set to 5 seconds."
	icon_state = "grenade_sticky"
	icon_state_mini = "grenade_round_orange"
	worn_icon_state = "grenade_sticky"
	det_time = 5 SECONDS
	light_impact_range = 2
	weak_impact_range = 3
	///Current atom this grenade is attached to, used to remove the overlay.
	var/atom/stuck_to
	///Current image overlay applied to stuck_to, used to remove the overlay after detonation.
	var/image/saved_overlay
	///if this specific grenade should be allowed to self sticky
	var/self_sticky = FALSE

/obj/item/explosive/grenade/sticky/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(!.)
		return
	if(!active || stuck_to || isturf(hit_atom))
		return
	stuck_to(hit_atom)

/obj/item/explosive/grenade/sticky/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(target != user)
		return
	if(!self_sticky)
		return
	user.drop_held_item()
	activate()
	stuck_to(target)

/obj/item/explosive/grenade/sticky/prime()
	if(stuck_to)
		clean_refs()
	return ..()

/obj/item/explosive/grenade/sticky/launched_det_time()
	det_time -= 1 SECONDS

///Cleans references to prevent hard deletes.
/obj/item/explosive/grenade/sticky/proc/clean_refs()
	stuck_to.cut_overlay(saved_overlay)
	SIGNAL_HANDLER
	UnregisterSignal(stuck_to, COMSIG_QDELETING)
	stuck_to = null
	saved_overlay = null

///handles sticky overlay and attaching the grenade itself to the target
/obj/item/explosive/grenade/sticky/proc/stuck_to(atom/hit_atom)
	var/image/stuck_overlay = image(icon, hit_atom, initial(icon_state) + "_stuck")
	stuck_overlay.pixel_x = rand(-5, 5)
	stuck_overlay.pixel_y = rand(-7, 7)
	hit_atom.add_overlay(stuck_overlay)
	forceMove(hit_atom)
	saved_overlay = stuck_overlay
	stuck_to = hit_atom
	RegisterSignal(stuck_to, COMSIG_QDELETING, PROC_REF(clean_refs))

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
	if(stuck_to)
		clean_refs()
	qdel(src)

/obj/item/explosive/grenade/sticky/trailblazer/stuck_to(atom/hit_atom)
	. = ..()
	RegisterSignal(stuck_to, COMSIG_MOVABLE_MOVED, PROC_REF(make_fire))
	var/turf/T = get_turf(src)
	T.ignite(25, 25)

///causes fire tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/trailblazer/proc/make_fire(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	var/turf/T = get_turf(src)
	T.ignite(25, 25)

/obj/item/explosive/grenade/sticky/trailblazer/clean_refs()
	stuck_to.cut_overlay(saved_overlay)
	UnregisterSignal(stuck_to, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/item/explosive/grenade/sticky/cloaker
	name = "\improper M45 Cloaker grenade"
	desc = "Capsule based grenade that sticks to sufficiently hard surfaces, causing a trail of air combustable gel to form. This one creates cloaking smoke! It is set to detonate in 5 seconds."
	icon_state = "grenade_sticky_cloak"
	icon_state_mini = "grenade_stick_green"
	worn_icon_state = "grenade_sticky_cloak"
	det_time = 5 SECONDS
	light_impact_range = 1
	self_sticky = TRUE
	/// smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical
	///radius this smoke grenade will encompass
	var/smokeradius = 1
	///The duration of the smoke
	var/smoke_duration = 8

/obj/item/explosive/grenade/sticky/cloaker/prime()
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(loc, 'sound/effects/smoke_bomb.ogg', 35)
	smoke.set_up(smokeradius, loc, smoke_duration)
	smoke.start()
	if(stuck_to)
		clean_refs()
	qdel(src)

/obj/item/explosive/grenade/sticky/cloaker/stuck_to(atom/hit_atom)
	. = ..()
	RegisterSignal(stuck_to, COMSIG_MOVABLE_MOVED, PROC_REF(make_smoke))

///causes fire tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/cloaker/proc/make_smoke(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(smokeradius, loc, smoke_duration)
	smoke.start()

/obj/item/explosive/grenade/sticky/cloaker/clean_refs()
	stuck_to.cut_overlay(saved_overlay)
	UnregisterSignal(stuck_to, COMSIG_MOVABLE_MOVED)
	return ..()
